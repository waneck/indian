package indian.types.encoding;
import indian.types.encoding.Encoding;
import indian.types.*;
import indian.Indian.*;

@:unsafe @:final @:dce class Utf8 extends Encoding
{
	public static var cur(default,null) = new Utf8();
	// Copyright (c) 2008-2009 Bjoern Hoehrmann <bjoern@hoehrmann.de>
	// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.

	static inline var ACCEPT = 0;
	static inline var REJECT = 1;
	static var utf8d:haxe.ds.Vector<Int> = haxe.ds.Vector.fromArrayCopy([
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
		var srcptr = -1;
		while(true)
		{
			++srcptr;
			if (byteLength >= 0 && srcptr >= byteLength)
				break;
			var byte = source.getUInt8(offset+srcptr);
			if (byte == 0 && byteLength < 0)
				break;

			var type = utf8d[byte];
			codepoint = (state != ACCEPT) ?
				(byte & 0x3f) | (codepoint << 6) :
				(0xff >> type) & (byte);
			state = utf8d[256 + (state << 4) + type];
			if (state == REJECT)
			{
				state = ACCEPT;
				codepoint = replacementChar;
			}
			if (state == ACCEPT)
			{
				trace(codepoint);
				var shouldContinue = iter(codepoint,srcptr);
				if (!shouldContinue)
					break;
			}
		}
	}

	public function new()
	{
		this.terminationBytes = 1;
		this.name = "UTF-8";
	}

	override private function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,outMaxByteLength:Int):EncodingReturn
	{
		var start = outoffset,
				written = 0,
				j = -4,
				read = 0;
		while(true)
		{
			j += 4;
			if (byteLength >= 0 && j >= byteLength)
				break;
			var cp = source.getInt32(srcoffset + j);
			if (byteLength < 0 && cp == 0)
				break;
			if (cp <= 0x7f)
			{
				if ((written + 1) > outMaxByteLength)
					break;
				out.setUInt8(start + written++,cp);
			} else if (cp <= 0x7FF) {
				if ((written + 2) > outMaxByteLength)
					break;
				out.setUInt8(start+written++,0xC0 | (cp >> 6));
				out.setUInt8(start+written++,0x80 | (cp & 0x3F));
			} else if (cp <= 0xFFFF) {
				if ((written + 3) > outMaxByteLength)
					break;
				out.setUInt8(start+written++, 0xE0 | (cp >> 12) );
				out.setUInt8(start+written++, 0x80 | ((cp >> 6) & 0x3F) );
				out.setUInt8(start+written++, 0x80 | (cp & 0x3F) );
			} else if (cp <= 0x10FFFF) {
				if ((written + 4) > outMaxByteLength)
					break;
				out.setUInt8(start+written++, 0xF0 | (cp >> 18) );
				out.setUInt8(start+written++, 0x80 | ((cp >> 12) & 0x3F) );
				out.setUInt8(start+written++, 0x80 | ((cp >> 6) & 0x3F) );
				out.setUInt8(start+written++, 0x80 | (cp & 0x3F) );
			} else {
				// invalid
				if ( (written + 3) > outMaxByteLength)
					break;
				out.setUInt8(start+written++, 0xEF);
				out.setUInt8(start+written++, 0xBF);
				out.setUInt8(start+written++, 0xBD);
			}
			read = j;
		}
		return new EncodingReturn(read,written);
	}

	override private function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,outMaxByteLength:Int):EncodingReturn
	{
		var read = 0,
				written = 0;
		iter(source,srcoffset,byteLength, function(codepoint:Int, curByte:Int) {
			var next = written + 4;
			if (outMaxByteLength - next < 0)
			{
				return false;
			} else {
				read = curByte + 1;
				out.setInt32(written + outoffset,codepoint);
				written = next;
				return true;
			}
		});
		return new EncodingReturn(read,written);
	}

	override private function getByteLength(buf:Buffer):Int
	{
		var i = -1;
		while(true)
		{
			if (buf.getUInt8(++i) == 0)
				return i;
		}
		return -1;
	}

	override public function addTermination(buf:Buffer, pos:Int):Void
	{
		buf.setUInt8(pos,0);
	}

	override public function count(buf:Buffer, byteLength:Int):Int
	{
		var cps = 0;
		iter(buf,0,byteLength, function(_,_) {
			cps++;
			return true;
		});
		return cps;
	}

	override public function getPosOffset(buf:Buffer, byteLength:Int, pos:Int):Int
	{
		var srcpos = -1;
		iter(buf,0,byteLength, function(_,b) {
			srcpos = b;
			if (--pos <= 0)
			{
				return false;
			} else {
				return true;
			}
		});
		return srcpos;
	}

#if !(cs || java || js)
	override public function convertToString(buf:indian.Buffer, length:Int, hasTermination:Bool):String
	{
		if (hasTermination) length -= 1;
		if (length <= 0) return '';
		// direct copy
		var ret = new StringBuf();
		var i = -1;
		while(true)
		{
			++i;
			if (length >= 0 && i >= length)
				break;
			var chr = buf.getUInt8(i);
			if (length < 0 && chr == 0)
				break;
			ret.addChar(chr);
		}
		return ret.toString();
	}

	override private function _convertFromString(string:String, out:indian.Buffer, maxOutByteLength:Int):Int
	{
		var origMaxByte = maxOutByteLength,
				termBytes = 1;
		var chr = -1,
				strindex = -1;
		while ( !StringTools.isEof(chr = StringTools.fastCodeAt(string,++strindex)) && strindex < maxOutByteLength )
		{
			out.setUInt8(strindex, chr);
		}

		return strindex;
	}
#end

	override public function neededLength(string:String, addTermination:Bool):Int
	{
		var term = addTermination ? 1 : 0;
#if !(cs || java || js)
		return string.length + term;
#else
		var len = string.length << 1;
		var needed = 0;
		pin(str = $ptr(string), {
			Utf16.iter(str,0,len, function(cp,_) {
				if (cp <= 0x7f)
				{
					needed++;
				} else if (cp <= 0x7FF) {
					needed += 2;
				} else if (cp <= 0xFFFF) {
					needed += 3;
				} else if (cp <= 0x10FFFF) {
					needed += 4;
				} else {
					// invalid
					needed += 3;
				}
				return true;
			});
		});
		return needed + term;
#end
	}

}

