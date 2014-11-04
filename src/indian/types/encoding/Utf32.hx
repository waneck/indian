package indian.types.encoding;
import indian.types.encoding.Encoding;
import indian.Indian.*;
import indian.types.*;

@:unsafe @:final @:dce class Utf32 extends Encoding
{
	public static var cur(default,null) = new Utf32();
	static inline var replacementChar = 0xFFFD;

	public function new()
	{
		this.terminationBytes = 4;
		this.isUtf32 = true;
		this.name = "UTF-32";
	}

	override private function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,outMaxByteLength:Int):EncodingReturn
	{
		if (byteLength < 0)
			byteLength = getByteLength(source);
		var length = byteLength < outMaxByteLength ? byteLength : outMaxByteLength;

		if (length <= 0)
			return new EncodingReturn(0,0);
		if (source == out)
			return new EncodingReturn(length,length);

		Buffer.blit(source,srcoffset, out,outoffset, length);
		return new EncodingReturn(length,length);
	}

	override private function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,outMaxByteLength:Int):EncodingReturn
	{
		if (byteLength < 0)
			byteLength = getByteLength(source);

		var length = byteLength < outMaxByteLength ? byteLength : outMaxByteLength;
		if (length <= 0)
			return new EncodingReturn(0,0);
		if (source == out)
			return new EncodingReturn(length,length);

		Buffer.blit(source,srcoffset, out,outoffset, length);
		return new EncodingReturn(length,length);
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

	override public function addTermination(buf:Buffer, pos:Int):Void
	{
		buf.setInt32(pos,0);
	}

	override public function count(buf:Buffer, byteLength:Int):Int
	{
		if (byteLength < 0) byteLength = getByteLength(buf);
		return byteLength >> 2;
	}

	override public function neededLength(string:String, addTermination:Bool):Int
	{
		var len = string.length;
		var needed = 0;
		pin(str = $ptr(string), {
#if !(cs || java || js) // UTF-8
			Utf8.iter(str,0,len, function(cp,_) {
				needed++;
				return true;
			});
#else // UTF-16
			Utf16.iter(str,0,len << 1, function(cp,_) {
				needed++;
				return true;
			});
#end
		});
		if (addTermination)
			needed++;
		return needed << 2;
	}

	override public function getPosOffset(buf:Buffer, byteLength:Int, pos:Int):Int
	{
		if (byteLength < 0)
			byteLength = getByteLength(buf);

		var ret = pos << 2;
		if (ret > byteLength)
			ret = byteLength;
		return ret;
	}

}

