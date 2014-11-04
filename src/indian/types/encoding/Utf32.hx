package indian.types.encoding;
import indian.Indian.*;
import indian.types.*;

@:unsafe @:final @:dce class Utf32 extends Encoding
{
	public static var cur(default,null) = new Utf32();
	static inline var replacementChar = 0xFFFD;

	public function new()
	{
	}

	override private function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int, writtenOut:Buffer):Int
	{
		if (byteLength < 0) byteLength = getByteLength(source);
		if (out == null) return byteLength;
		var length = byteLength < maxByteLength ? byteLength : maxByteLength;
		if (writtenOut != null) writtenOut.setInt32(0,length);
		if (source == out || maxByteLength < 0)
			return length;

		Buffer.blit(source,srcoffset, out,outoffset, length);
		return length;
	}

	override private function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int, writtenOut:Buffer):Int
	{
		if (byteLength < 0) byteLength = getByteLength(source);
		if (out == null) return byteLength;
		var length = byteLength < maxByteLength ? byteLength : maxByteLength;
		if (writtenOut != null) writtenOut.setInt32(0,length);
		if (source == out || maxByteLength < 0)
			return length;

		Buffer.blit(source,srcoffset, out,outoffset, length);
		return length;
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
		return byteLength >> 2;
	}

	override public function neededLength(string:String, addTermination:Bool):Int
	{
		var len = string.length;
		var i = 0;
		pin(str = $ptr(string), {
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
		});
		if (addTermination)
			i++;
		return i << 2;
	}

	override public function getPosOffset(buf:Buffer, byteLength:Int, pos:Int):Int
	{
		if (byteLength < 0) byteLength = getByteLength(buf);
		var ret = pos << 2;
		if (ret > byteLength)
			ret = byteLength;
		return ret;
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
