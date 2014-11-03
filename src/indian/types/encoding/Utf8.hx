package indian.types.encoding;
import indian.types.*;

@:unsafe @:final @:dce class Utf8 extends Encoding
{
	// Copyright (c) 2008-2009 Bjoern Hoehrmann <bjoern@hoehrmann.de>
	// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.

	static inline var ACCEPT = 0;
	static inline var REJECT = 1;
	static var utf8d:haxe.ds.Vector<UInt8> = haxe.ds.Vector.fromArrayCopy([
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 00..1f
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 20..3f
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 40..5f
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 60..7f
		1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9, // 80..9f
		7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7, // a0..bf
		8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, // c0..df
		0xa,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x3, // e0..ef
		0xb,0x6,0x6,0x6,0x5,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8, // f0..ff
		0x0,0x1,0x2,0x3,0x5,0x8,0x7,0x1,0x1,0x1,0x4,0x6,0x1,0x1,0x1,0x1, // s0..s0
		1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,1, // s1..s2
		1,2,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1, // s3..s4
		1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,3,1,1,1,1,1,1, // s5..s6
		1,3,1,1,1,1,1,3,1,3,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1, // s7..s8
	]);
	static inline var replacementChar = 0xFFFD;

	@:extern inline public static function iter(source:indian.Buffer,offset:Int,byteLength:Int, iter:Int->Int->Bool):Void
	{
		var state = 0,
				codepoint = 0;
		var utf8d = utf8d;
		var len = byteLength,
				i = -1;
		while(true)
		{
			++i;
			if (byteLength >= 0 && i >= len)
				break;
			var byte = source.getUInt8(offset+i);
			if (byteLength < 0 && byte == 0)
				break;

			var type = utf8d[byte];
			codepoint = (state != ACCEPT) ?
				(byte & 0x3fu) | (codepoint << 6) :
				(0xff >> type) & (byte);
			state = utf8d[256 + state << 4 + type];
			if (state == REJECT)
			{
				state = ACCEPT;
				codepoint = replacementChar;
			}
			if (state == ACCEPT)
			{
				var shouldContinue = iter(codepoint,i);
				if (!shouldContinue)
					break;
			}
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
		maxByteLength--;
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
			if (cp <= 0x7f)
			{
				if ((i + 1) >= maxByteLength)
					break;
				out.setUInt8(start + i++,cp);
			} else if (cp <= 0x7FF) {
				if ((i + 2) >= maxByteLength)
					break;
				out.setUInt8(start+i++,0xC0 | (cp >> 6));
				out.setUInt8(start+i++,0x80 | (cp & 0x3F));
			} else if (cp <= 0xFFFF) {
				if ((i + 3) >= maxByteLength)
					break;
				out.setUInt8(start+i++, 0xE0 | (cp >> 12) );
				out.setUInt8(start+i++, 0x80 | ((cp >> 6) & 0x3F) );
				out.setUInt8(start+i++, 0x80 | (cp & 0x3F) );
			} else {
				if ((i + 4) >= maxByteLength)
					break;
				out.setUInt8(start+i++, 0xF0 | (cp >> 18) );
				out.setUInt8(start+i++, 0x80 | ((cp >> 12) & 0x3F) );
				out.setUInt8(start+i++, 0x80 | ((cp >> 6) & 0x3F) );
				out.setUInt8(start+i++, 0x80 | (cp & 0x3F) );
			}
			curj = j;
		}
		if (maxByteLength >= 0)
			out.setUInt8(start+i, 0);
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
		var i = -1;
		while(true)
		{
			if (buf.getUInt8(i++) == 0)
				return i;
		}
		return -1;
	}

	override private function addTermination(buf:Buffer, pos:Int):Void
	{
		buf.setUInt8(pos,0);
	}

	override private function terminationBytes():Int
	{
		return 1;
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

#if !(cs || java || js)
	override public function convertToString(buf:indian.Buffer, length:Int):String
	{
		// direct copy
		var ret = new StringBuf();
		var i = -1;
		while(true)
		{
			++i;
			if (length >= 0 && i > length)
				break;
			var chr = buf.getUInt8(i);
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
		while ( !StringTools.isEof(chr = StringTools.fastCodeAt(string,++i)) && i < maxByteLength )
		{
			out.setUInt8(i, chr);
		}
		if (i < maxByteLength)
			out.setUInt8(i, 0);
		else
			out.setUInt8(maxByteLength, 0);
	}
#end

	/**
		Returns encoding name
	**/
	override public function name():String
	{
		return "UTF-8";
	}

}
