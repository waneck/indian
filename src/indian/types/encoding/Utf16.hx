package indian.types.encoding;

@:unsafe @:final @:dce class Utf16 extends Encoding
{
	static inline var replacementChar = 0xFFFD;
	@:extern inline public static function iter(source:indian.Buffer,offset:Int,byteLength:Int, iter:Int->Int->Bool):Void
	{
		var len = byteLength,
				i = -2,
				codepoint = 0,
				surrogate = false;
		while(true)
		{
			i += 2;
			if (byteLength >= 0 && i >= len)
				break;
			var cp = source.getUInt16(offset+i);
			if (byteLength < 0 && cp == 0)
				break;
			if (surrogate)
			{
				surrogate = false;
				if (cp >= 0xDC00 && cp <= 0xDFFF)
				{
					codepoint = (codepoint << 10) | (cp - 0x35FDC00);
				} else {
					codepoint = replacementChar;
					i -= 2;
				}
			} else if (cp >= 0xD800 && cp <= 0xDBFF) {
				surrogate = true;
				codepoint = cp;
				continue;
			}
			if (!iter(codepoint,i))
				break;
		}
	}

	public function new()
	{
	}

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
	override public function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int):Int
	{
		maxByteLength -= 2;
		var start = outoffset,
				i = 0,
				j = -1,
				curj = 0;
		// for (j in 0...(byteLength >> 2))
		while(true)
		{
			++j;
			if (byteLength >= 0 && j >= byteLength)
				break;
			var cp = source.getInt32(srcoffset + j<<2);
			if (byteLength < 0 && cp == 0)
				break;
			if (cp < 0x10000)
			{
				if ((i + 1) << 1 >= maxByteLength)
					break;
				out.setUInt16(start + ((i++) << 1),cp);
			} else if (cp <= 0x10FFFF) {
				if ((i + 1) << 1 >= maxByteLength)
					break;
				out.setUInt16(start + ((i++) << 1), (cp >> 10) + 0xD7C0 );
				out.setUInt16(start + ((i++) << 1), (cp & 0x3FF) + 0xDC00 );
			} else {
				if ((i + 1) << 1 >= maxByteLength)
					break;
				out.setUInt16(start + ((i++) << 1),0xFFFD);
			}
			curj = j;
		}
		if (maxByteLength >= 0)
			out.setUInt16(start+(i<<1), 0);
		return j<<2;
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
	override public function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int):Int
	{
		maxByteLength -= 4;
		var lst = 0,
				i = -1;
		iter(source,srcoffset,byteLength, function(codepoint:Int, curByte:Int) {
			var i2 = (++i) << 2;
			if (maxByteLength - i2 < 0)
			{
				return false;
			} else {
				lst = curByte;
				out.setInt32(i2 + outoffset,codepoint);
				return true;
			}
		});
		if (maxByteLength >= 0)
			out.setInt32(i<<2+outoffset,0);
		return lst;
	}

	/**
		Called internally to get the byte length of unknown length when needed
	 **/
	override private function getByteLength(buf:Buffer):Int
	{
		var i = -2;
		while(true)
		{
			if (buf.getUInt16( (i += 2)) == 0)
				return i;
		}
		return -1;
	}

	override private function addTermination(buf:Buffer, pos:Int):Void
	{
		buf.setUInt16(pos,0);
	}

	override private function terminationBytes():Int
	{
		return 2;
	}
	/**
		Returns the number of unicode code points that exist in `buf` with byte length `byteLength`.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		If the encoding is not unicode, a character mapping will be used so that the returned length is still in unicode code point units.
	 **/
	override public function count(buf:Buffer, byteLength:Int):Int
	{
		var i = 0;
		iter(buf,0,byteLength, function(_,_) {
			i++
			return true;
		});
		return i;
	}

	/**
		Gets the byte offset for the unicode code point at position `pos` on buffer `buf`, with length `byteLength`
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		If the encoding is not unicode, a character mapping will be used so that the position count is still in unicode code point units.
	**/
	override public function getPosOffset(buf:Buffer, byteLength:Int, pos:Int):Int
	{
		var byte = -1;
		iter(buf,0,byteLength, function(_,b) {
			byte = b;
			if (--pos <= 0)
			{
				return false;
			}
		});
		return byte;
	}

#if (cs || java || js)
	override public function convertToString(buf:indian.Buffer, length:Int):String
	{
		// direct copy
		var ret = new StringBuf();
		var i = -2;
		while(true)
		{
			i += 2;
			if (length >= 0 && i > length)
				break;
			var chr = buf.getUInt16(i);
			if (length < 0 && chr == 0)
				break;
			buf.addChar(chr);
		}
		return buf.toString();
	}

	override public function convertFromString(string:String, out:indian.Buffer, maxByteLength:Int):Void
	{
		var chr = -1,
				i = -1;
		maxByteLength -= 2;
		while ( !StringTools.isEof(chr = StringTools.fastCodeAt(string,++i)) && i < maxByteLength )
		{
			out.setUInt16(i << 1, chr);
		}
		if (maxByteLength >= 0)
			out.setUInt16(i << 1, 0);
	}
#end

	/**
		Returns encoding name
	**/
	override public function name():String
	{
		return "UTF-16";
	}
}

