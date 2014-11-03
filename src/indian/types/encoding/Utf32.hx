package indian.types.encoding;

@:unsafe @:final @:dce class Utf32 extends Encoding
{
	static inline var replacementChar = 0xFFFD;

	@:extern inline public static function iter(source:indian.Buffer,offset:Int,byteLength:Int, iter:Int->Int->Bool):Void
	{
		var len = byteLength,
				i = -4;
		while(true)
		{
			i += 4;
			if (byteLength >= 0 && i >= len)
				break;
			var cp = source.getUInt16(offset+i);
			if (byteLength < 0 && cp == 0)
				break;
			if (!iter(cp,i))
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
		maxByteLength -= 4;
		var length = byteLength < maxByteLength ? byteLength : maxByteLength;
		if (source == out || maxByteLength < 0)
			return length;

		Buffer.blit(source,srcoffset, out,outoffset, length);
		out.setInt32(outoffset+length,0);
		return length;
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
				i = -4;
		iter(source,srcoffset,byteLength, function(codepoint:Int, curByte:Int) {
			i += 4;
			if (maxByteLength - i < 0)
			{
				return false;
			} else {
				lst = curByte;
				out.setInt32(i + outoffset,codepoint);
				return true;
			}
		});
		if (maxByteLength >= 0)
			out.setInt32(i+outoffset,0);
		return lst;
	}

	/**
		Called internally to get the byte length of unknown length when needed
	 **/
	override private function getByteLength(buf:Buffer):Int
	{
		var i = -4;
		while(true)
		{
			if (buf.getUInt32( (i += 4)) == 0)
				return i;
		}
		return -1;
	}

	override private function addTermination(buf:Buffer, pos:Int):Void
	{
		buf.setUInt32(pos,0);
	}

	override private function terminationBytes():Int
	{
		return 4;
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
		if (byteLength >= 0)
		{
			var ret = pos << 2;
			if (ret > byteLength)
				ret = byteLength;
			return ret;
		}

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

	/**
		Returns encoding name
	**/
	override public function name():String
	{
		return "UTF-32";
	}
}
