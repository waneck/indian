package indian.types.encoding;
import indian.*;
import indian.Indian.*;

@:unsafe @:dce class Encoding
{
	public static var Utf8(default,null) = new Utf8();
	public static var Utf16(default,null) = new Utf16();
	public static var Utf32(default,null) = new Utf32();

	/**
		Converts `source` (byte array in UTF8 encoding) with exact byte length `byteLength` to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromUtf8(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `source` encoded with current encoding to the byte array specified in `out` - encoded in UTF8.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertToUtf8(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int):Int
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
	public function convertFromEncoding(source:indian.Buffer, byteLength:Int, sourceEncoding:Encoding, out:indian.Buffer, maxByteLength:Int):Int
	{
		if (this == sourceEncoding || this.name() == sourceEncoding.name())
		{
			if (source != out)
				Buffer.blit(source, 0, out, 0, byteLength);
			return byteLength;
		} else if (this.isUtf8()) {
			return sourceEncoding.convertToUtf8(source,byteLength, out,maxByteLength);
		} else if (sourceEncoding.isUtf8()) {
			return this.convertFromUtf8(source,byteLength, out,maxByteLength);
		} else {
			//use UTF8 intermediate representation
			//use the own output buffer
			var consumed = sourceEncoding.convertToUtf8(source,byteLength, out,maxByteLength, false);
			if (consumed < byteLength)
			{
				// does not fit entirely in the buffer - use a temporary buffer for the rest
				var written = this.convertFromUtf8(out,maxByteLength, out,maxByteLength);
				if (written < maxByteLength)
				{
					var len = this.count(out,maxByteLength);
					return getPosOffset(source, byteLength, len);
				}

				autofree(buf = $stackalloc(256), {
					while(written < maxByteLength && consumed < byteLength)
					{
						var c2 = sourceEncoding.convertToUtf8(source + consumed,byteLength - consumed, buf,256, false);
						consumed += c2;
						var w2 = this.convertFromUtf8(buf,c2, out + written,maxByteLength - written);
						written += w2;
					}
					return consumed;
				});
			} else {
				var len = sourceEncoding.count(source,byteLength),
						pos = Utf8.getPosOffset(out, byteLength, len);

				var written = this.convertFromUtf8(out,pos+1, out,maxByteLength);
				if (written < pos+1)
				{
					var len = this.count(out,maxByteLength);
					return getPosOffset(source, byteLength, len);
				}
				return consumed;
			}
		}
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

	private function isUtf8():Bool
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
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromString(string:String, out:indian.Buffer, maxByteLength:Int):Int
	{
		var len = string.length;
		pin(str = $ptr(string), {
#if !(cs || java || js) // UTF-8
			return this.convertFromUtf8(str,len, out,maxByteLength);
#else // UTF-16
			return this.convertFromEncoding(str,len,Utf16, out,maxByteLength);
#end
		});
	}

	/**
		Converts `buf`, with byte length `length` into a String enconded on the native target enconding.
		If `length` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
	**/
	public function convertToString(buf:indian.Buffer, length:Int):String
	{
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
