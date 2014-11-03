package indian.types.encoding;
import indian.*;
import indian.Indian.*;

/**
	Don't trust this API. It will likely change in the future.
**/
@:unsafe @:dce class Encoding
{
	public static var Utf8(default,null) = new Utf8();
	public static var Utf16(default,null) = new Utf16();
	public static var Utf32(default,null) = new Utf32();

	/**
		Converts `source` (byte array in UTF32 encoding) with exact byte length `byteLength` to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `source` encoded with current encoding to the byte array specified in `out` - encoded in UTF32.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` and encoded with encoding `sourceEncoding` to the byte array specified in `out`,
		and with max length `maxByteLength` and encoded by `this`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromEncoding(source:indian.Buffer,byteLength:Int,sourceEncoding:Encoding, out:indian.Buffer,maxByteLength:Int):Int
	{
		if (this == sourceEncoding || this.name() == sourceEncoding.name())
		{
			if (source != out)
			{
				var outlen = byteLength < 0 ? getByteLength(source) : byteLength;
				outlen -= terminationBytes();
				if (maxByteLen < outlen)
					outlen = maxByteLen;
				Buffer.blit(source,0, out,0, outlen);
				addTermination(out,outlen);
			}
			return byteLength;
		} else if (this.isUtf32()) {
			return sourceEncoding.convertToUtf32(source,0,byteLength, out,0,maxByteLength);
		} else if (sourceEncoding.isUtf32()) {
			return this.convertFromUtf32(source,0,byteLength, out,0,maxByteLength);
		} else {
			//use UTF32 intermediate representation
			var len = sourceEncoding.count(source,byteLength) << 2;
			var written = 0,
					consumed = 0,
					consumedCodepoints = 0;
			var neededBuf = len;
			if (neededBuf > 256)
				neededBuf = 256;
			autofree(buf = $stackalloc(neededBuf), {
				while(written < maxByteLength && consumedCodepoints < len)
				{
					var c2 = sourceEncoding.convertToUtf32(source,consumed,byteLength - consumed, buf,0,neededBuf, false);
					consumed += c2;
					consumedCodepoints += neededBuf >> 2;
					var w2 = this.convertFromUtf32(buf,0,c2, out,written,maxByteLength - written);
					written += w2;
				}
				return consumed;
			});
		}
	}

	/**
		Called internally to get the byte length of unknown length when needed
	 **/
	private function getByteLength(buf:Buffer):Int
	{
		return throw "Not Implemented";
	}

	private function addTermination(buf:Buffer, pos:Int):Void
	{
		throw "Not Implemented";
	}

	private function terminationBytes():Int
	{
		return throw "Not Implemented";
	}
	/**
		Returns the number of unicode code points that exist in `buf` with byte length `byteLength`.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		If the encoding is not unicode, a character mapping will be used so that the returned length is still in unicode code point units.
	 **/
	public function count(buf:Buffer, byteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Gets the byte offset for the unicode code point at position `pos` on buffer `buf`, with length `byteLength`
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		If the encoding is not unicode, a character mapping will be used so that the position count is still in unicode code point units.
	**/
	public function getPosOffset(buf:Buffer, byteLength:Int, pos:Int):Int
	{
		return throw "Not Implemented";
	}

	private function isUtf32():Bool
	{
		return false;
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` and encoded with encoding `sourceEncoding` to the byte array specified in `out`,
		and with max length `maxByteLength` and encoded by `this`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	inline public function convertToEncoding(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int, outEncoding:Encoding):Int
	{
		return outEncoding.convertFromEncoding(source,byteLength,this,out,maxByteLength);
	}

	/**
		Converts `string` (assuming native target enconding) to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.
		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
	**/
	public function convertFromString(string:String, out:indian.Buffer, maxByteLength:Int):Void
	{
		var len = string.length;
		pin(str = $ptr(string), {
#if !(cs || java || js) // UTF-8
			this.convertFromEncoding(str,0,len,Utf8, out,0,maxByteLength);
#else // UTF-16
			this.convertFromEncoding(str,0,len << 1,Utf16, out,0,maxByteLength);
#end
		});
	}

	/**
		Converts `buf`, with byte length `length` into a String enconded on the native target enconding.
		If `length` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
	**/
	public function convertToString(buf:indian.Buffer, length:Int):String
	{
		var ret = new StringBuf();
		// first convert into
		var len = this.count(buf,length) << 2;
		var neededBuf = len;
		if (neededBuf > 256)
			neededBuf = 256;
		var consumedCodepoints = 0;
		autofree(buf = $stackalloc(neededBuf), {
			while(consumedCodepoints < len)
			{
				var c2 = this.convertToUtf32(source,consumed,byteLength - consumed, buf,0,neededBuf, false);
				consumedCodepoints += neededBuf >> 2;
				for (i in 0...(c2 >> 2))
				{
					var cp = buf.getInt32(i<<2);
#if !(cs || java || js) // UTF-8
					if (cp <= 0x7f)
					{
						buf.addChar(cp);
					} else if (cp <= 0x7FF) {
						buf.addChar(0xC0 | (cp >> 6));
						buf.addChar(0x80 | (cp & 0x3F));
					} else if (cp <= 0xFFFF) {
						buf.addChar( 0xE0 | (cp >> 12) );
						buf.addChar( 0x80 | ((cp >> 6) & 0x3F) );
						buf.addChar( 0x80 | (cp & 0x3F) );
					} else {
						buf.addChar( 0xF0 | (cp >> 18) );
						buf.addChar( 0x80 | ((cp >> 12) & 0x3F) );
						buf.addChar( 0x80 | ((cp >> 6) & 0x3F) );
						buf.addChar( 0x80 | (cp & 0x3F) );
					}
#else // UTF-16
					if (cp < 0x10000)
					{
						buf.addChar(cp);
					} else if (cp <= 0x10FFFF) {
						buf.addChar( (cp >> 10) + 0xD7C0 );
						buf.addChar( (cp & 0x3FF) + 0xDC00 );
					} else {
						//invalid - shouldn't happen
						trace('assert');
						buf.addChar(0xFFFD);
					}
#end
				}
			}
		});
		return buf.toString();
	}

	/**
		Returns encoding name
	**/
	public function name():String
	{
		return throw "Not Implemented";
	}

	public function toString()
	{
		return name() + ' Encoding';
	}
}
