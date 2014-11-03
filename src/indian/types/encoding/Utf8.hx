package indian.types.encoding;
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
				var shouldContinue = iter(codepoint,i);
				if (!shouldContinue)
					break;
			}
		}
	}

	public function new()
	{
	}

	override public function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int):Int
	{
		maxByteLength--;
		var start = outoffset,
				i = 0,
				j = -1,
				curj = 0;
		while(true)
		{
			++j;
			if (byteLength >= 0 && j >= byteLength)
				break;
			var cp = source.getInt32(srcoffset + (j<<2));
			if (byteLength < 0 && cp == 0)
				break;
			if (cp <= 0x7f)
			{
				if ((i + 1) > maxByteLength)
					break;
				out.setUInt8(start + i++,cp);
			} else if (cp <= 0x7FF) {
				if ((i + 2) > maxByteLength)
					break;
				out.setUInt8(start+i++,0xC0 | (cp >> 6));
				out.setUInt8(start+i++,0x80 | (cp & 0x3F));
			} else if (cp <= 0xFFFF) {
				if ((i + 3) > maxByteLength)
					break;
				out.setUInt8(start+i++, 0xE0 | (cp >> 12) );
				out.setUInt8(start+i++, 0x80 | ((cp >> 6) & 0x3F) );
				out.setUInt8(start+i++, 0x80 | (cp & 0x3F) );
			} else {
				if ((i + 4) > maxByteLength)
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
			out.setInt32(((++i)<<2)+outoffset,0);
		return lst;
	}

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

	override private function hasTermination(buf:Buffer, pos:Int):Bool
	{
		return buf.getUInt8(pos) == 0;
	}

	override public function count(buf:Buffer, byteLength:Int):Int
	{
		var i = 0;
		iter(buf,0,byteLength, function(_,_) {
			i++;
			return true;
		});
		return i;
	}

	override public function getPosOffset(buf:Buffer, byteLength:Int, pos:Int):Int
	{
		var byte = -1;
		iter(buf,0,byteLength, function(_,b) {
			byte = b;
			if (--pos <= 0)
			{
				return false;
			} else {
				return true;
			}
		});
		return byte;
	}

#if !(cs || java || js)
	override public function convertToString(buf:indian.Buffer, length:Int):String
	{
		if (hasTermination(buf,length))
			length -= this.terminationBytes();
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
			ret.addChar(chr);
		}
		return ret.toString();
	}

	override public function convertFromString(string:String, out:indian.Buffer, maxByteLength:Int):Void
	{
		var chr = -1,
				i = -1;
		while ( !StringTools.isEof(chr = StringTools.fastCodeAt(string,++i)) && i < maxByteLength )
		{
			out.setUInt8(i, chr);
		}
		++i;
		if (i < maxByteLength)
			out.setUInt8(i, 0);
		else
			out.setUInt8(maxByteLength, 0);
	}
#end

	override public function neededLength(string:String):Int
	{
#if !(cs || java || js)
		return string.length + 1;
#else
		var len = string.length << 1;
		pin(str = $ptr(string), {
			var i = 0;
			Utf16.iter(str,0,len, function(cp,_) {
				if (cp <= 0x7f)
				{
					i++;
				} else if (cp <= 0x7FF) {
					i += 2;
				} else if (cp <= 0xFFFF) {
					i += 3;
				} else {
					i += 4;
				}
				return true;
			});
			return i + 1;
		});
		throw 'assert';
#end
	}

	override public function name():String
	{
		return "UTF-8";
	}

}
