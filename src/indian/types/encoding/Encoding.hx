package indian.types.encoding;
import indian.*;
import indian.Indian.*;

/**
	Don't trust this API. It will likely change in the future.
**/
@:unsafe @:dce class Encoding
{
	public var terminationBytes(default,null):Int;

	/**
		Converts `source` (byte array in UTF32 encoding) with exact byte length `byteLength` to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	private function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int, writtenOut:indian.Buffer):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `source` encoded with current encoding to the byte array specified in `out` - encoded in UTF32.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	private function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int, writtenOut:indian.Buffer):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` and encoded with encoding `sourceEncoding` to the byte array specified in `out`,
		and with max length `maxByteLength` and encoded by `this`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromEncoding(source:indian.Buffer,byteLength:Int,sourceEncoding:Encoding, out:indian.Buffer,maxByteLength:Int, writtenOut:indian.Buffer):Int
	{
		if (this == sourceEncoding || this.name() == sourceEncoding.name())
		{
			if (source != out)
			{
				var outlen = byteLength < 0 ? getByteLength(source) : byteLength;
				if (maxByteLength < outlen)
					outlen = maxByteLength;
				Buffer.blit(source,0, out,0, outlen);
				if (outlen <= (maxByteLength - terminationBytes))
					this.addTermination(out,outlen);
				if (writtenOut != null)
					writtenOut.setInt32(0,outlen);
			}
			return byteLength;
		} else if (this.isUtf32()) {
			return sourceEncoding.convertToUtf32(source,0,byteLength, out,0,maxByteLength, writtenOut);
		} else if (sourceEncoding.isUtf32()) {
			return this.convertFromUtf32(source,0,byteLength, out,0,maxByteLength, writtenOut);
		} else {
			//use UTF32 intermediate representation
			var len = sourceEncoding.count(source,byteLength);
			var written = 0,
					consumed = 0,
					consumedCodepoints = 0;
			var writtenLoc = 0;
			var neededBuf = len << 2;
			if (neededBuf > 256) neededBuf = 256;
			autofree(buf = $stackalloc(neededBuf), {
				var writtenLoc = addr(writtenLoc);
				if (writtenLoc == null) writtenLoc = writtenOut;
				var needsAlloc = writtenLoc == null;
				if (needsAlloc) writtenLoc = alloc(4);

				while(written < maxByteLength && consumedCodepoints < len)
				{
					var c2 = sourceEncoding.convertToUtf32(source,consumed,byteLength - consumed, buf,0,neededBuf, writtenLoc);
					consumed += c2;
					consumedCodepoints += neededBuf >> 2;
					this.convertFromUtf32(buf,0,writtenLoc.getInt32(0), out,written,maxByteLength - written, writtenLoc);
					written += writtenLoc.getInt32(0);
				}
				if (needsAlloc) free(writtenLoc);
			});
			if (writtenOut != null) writtenOut.setInt32(0,written);
			if (written <= (maxByteLength - terminationBytes)) this.addTermination(out,written);
			return consumed;
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

	private function hasTermination(buf:Buffer, pos:Int):Bool
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
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	inline public function convertToEncoding(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int, outEncoding:Encoding, writtenOut:indian.Buffer):Int
	{
		return outEncoding.convertFromEncoding(source,byteLength,this,out,maxByteLength, writtenOut);
	}

	/**
		Returns the needed byte length to convert from string `str`
		If `reserveTermination` is true, an extra space is reserved for the termination bytes.
	**/
	public function neededLength(str:String, reserveTermination:Bool):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `string` (assuming native target enconding) to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.
		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `reserveTermination` is true, an extra space is reserved for the termination bytes. Termination will always be added if there are enough bytes.

		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		@returns the amount of bytes written
	**/
	public function convertFromString(string:String, out:indian.Buffer, maxByteLength:Int, reserveTermination:Bool):Int
	{
		var len = string.length;
		var writtenLoc = 0;
		var origMaxByte = maxByteLength,
				termBytes = terminationBytes;

		if (reserveTermination) maxByteLength -= termBytes;
		if (maxByteLength <= 0)
		{
			if (maxByteLength == 0 && origMaxByte > 0)
			{
				this.addTermination(out,0);
				return termBytes;
			} else {
				return 0;
			}
		}
		var writtenLoc = addr(writtenLoc);
		pin(str = $ptr(string), {
			var wasNull = writtenLoc == null;
			if (wasNull) writtenLoc = alloc(4);
#if !(cs || java || js) // UTF-8
			this.convertFromEncoding(str,len,Utf8.cur, out,maxByteLength, writtenLoc);
#else // UTF-16
			this.convertFromEncoding(str,len << 1,Utf16.cur, out,maxByteLength, writtenLoc);
#end
			var written = writtenLoc.getInt32(0);
			if (written <= (origMaxByte - termBytes))
				this.addTermination(out,written);

			if (wasNull) free(writtenLoc);
			return written;
		});
		throw 'assert';
	}

	/**
		Converts `buf`, with byte length `length` into a String enconded on the native target enconding.
		If `length` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		If `hasTermination` is true, the termination bytes will be discounted from the total length
	**/
	public function convertToString(buf:indian.Buffer, length:Int, hasTermination:Bool):String
	{
		if (length > 0 && hasTermination)
			length -= this.terminationBytes;
		if (length <= 0)
			return '';

		var ret = new StringBuf();
		// first convert into
		var len = (this.count(buf,length)) << 2;
		var neededBuf = len;
		if (neededBuf > 256)
			neededBuf = 256;
		var consumed = 0;
		var writtenLoc = 0;
		autofree(tmp = $stackalloc(neededBuf),  {
			var writtenLoc = addr(writtenLoc);
			var wasNull = writtenLoc == null;
			if (wasNull)
				writtenLoc = alloc(4);

			while(consumed < len)
			{
				var c2 = this.convertToUtf32(buf,consumed,length - consumed, tmp,0,neededBuf, writtenLoc);

				var written = writtenLoc.getInt32(0);
				consumed += written;
				for (i in 0...(written >> 2))
				{
					var cp = tmp.getInt32(i<<2);
#if !(cs || java || js) // UTF-8
					if (cp <= 0x7f)
					{
						ret.addChar(cp);
					} else if (cp <= 0x7FF) {
						ret.addChar(0xC0 | (cp >> 6));
						ret.addChar(0x80 | (cp & 0x3F));
					} else if (cp <= 0xFFFF) {
						ret.addChar( 0xE0 | (cp >> 12) );
						ret.addChar( 0x80 | ((cp >> 6) & 0x3F) );
						ret.addChar( 0x80 | (cp & 0x3F) );
					} else {
						ret.addChar( 0xF0 | (cp >> 18) );
						ret.addChar( 0x80 | ((cp >> 12) & 0x3F) );
						ret.addChar( 0x80 | ((cp >> 6) & 0x3F) );
						ret.addChar( 0x80 | (cp & 0x3F) );
					}
#else // UTF-16
					if (cp < 0x10000)
					{
						ret.addChar(cp);
					} else if (cp <= 0x10FFFF) {
						ret.addChar( (cp >> 10) + 0xD7C0 );
						ret.addChar( (cp & 0x3FF) + 0xDC00 );
					} else {
						//invalid - shouldn't happen
						ret.addChar(0xFFFD);
					}
#end
				}
			}
			if (wasNull) free(writtenLoc);
		});
		return ret.toString();
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
