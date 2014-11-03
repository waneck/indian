package indian.types.encoding;
import indian.Indian.*;
import indian.types.*;

@:unsafe @:final @:dce class Utf32 extends Encoding
{
	public static var cur(default,null) = new Utf32();
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

	override public function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int):Int
	{
		if (out == null) return byteLength;
		maxByteLength -= 4;
		var length = byteLength < maxByteLength ? byteLength : maxByteLength;
		if (source == out || maxByteLength < 0)
			return length;

		Buffer.blit(source,srcoffset, out,outoffset, length);
		out.setInt32(outoffset+length,0);
		return length;
	}

	override public function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int):Int
	{
		if (out == null) return byteLength;
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

	override private function getByteLength(buf:Buffer):Int
	{
		var i = -4;
		while(true)
		{
			if (buf.getInt32( (i += 4)) == 0)
				return i;
		}
		return -1;
	}

	override private function addTermination(buf:Buffer, pos:Int):Void
	{
		buf.setInt32(pos,0);
	}

	override private function terminationBytes():Int
	{
		return 4;
	}

	override private function hasTermination(buf:Buffer, pos:Int):Bool
	{
		return buf.getInt32(pos-4) == 0;
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

	override public function neededLength(string:String):Int
	{
		var len = string.length;
		pin(str = $ptr(string), {
			var i = 0;
#if !(cs || java || js) // UTF-8
			Utf8.iter(str,0,len, function(cp,_) {
				i++;
				return true;
			});
#else // UTF-16
			Utf16.iter(str,0,len << 1, function(cp,_) {
				i++;
				return true;
			});
#end
			return (i + 1) << 2;
		});
		throw 'assert';
	}

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
			} else {
				return true;
			}
		});
		return byte;
	}

	override public function name():String
	{
		return "UTF-32";
	}

	override private function isUtf32():Bool
	{
		return true;
	}
}
