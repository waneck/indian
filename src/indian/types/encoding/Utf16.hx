package indian.types.encoding;
import indian.Indian.*;
import indian.types.*;

@:unsafe @:final @:dce class Utf16 extends Encoding
{
	public static var cur(default,null) = new Utf16();
	static inline var replacementChar = 0xFFFD;
	@:extern inline public static function iter(source:indian.Buffer,offset:Int,byteLength:Int, iter:Int->Int->Bool):Void
	{
		var i = -2,
				codepoint = 0,
				surrogate = false;
		while(true)
		{
			i += 2;
			if (byteLength >= 0 && i >= byteLength)
			{
				break;
			}
			var cp = source.getUInt16(offset+i);
			if (byteLength < 0 && cp == 0)
			{
				break;
			}
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
			} else {
				codepoint = cp;
			}
			if (!iter(codepoint,i))
			{
				break;
			}
		}
	}

	public function new()
	{
		this.terminationBytes = 2;
		this.name = "UTF-16";
	}

	override private function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int, writtenOut:Buffer):Int
	{
		var start = outoffset,
				i = 0,
				j = -1,
				curj = 0;
		// for (j in 0...(byteLength >> 2))
		while(true)
		{
			++j;
			if (byteLength >= 0 && (j<<2) >= byteLength)
				break;
			var cp = source.getInt32(srcoffset + (j<<2));
			if (byteLength < 0 && cp == 0)
				break;
			if (cp < 0x10000)
			{
				if ((i + 1) << 1 > maxByteLength)
					break;
				out.setUInt16(start + ((i++) << 1),cp);
			} else if (cp <= 0x10FFFF) {
				if ((i + 2) << 1 > maxByteLength)
					break;
				out.setUInt16(start + ((i++) << 1), (cp >> 10) + 0xD7C0 );
				out.setUInt16(start + ((i++) << 1), (cp & 0x3FF) + 0xDC00 );
			} else {
				if ((i + 1) << 1 > maxByteLength)
					break;
				out.setUInt16(start + ((i++) << 1),0xFFFD);
			}
			curj = j;
		}
		if (writtenOut != null) writtenOut.setInt32(0,i << 1);

		return curj<<2;
	}

	override private function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,maxByteLength:Int, writtenOut:Buffer):Int
	{
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
		++i;
		if (writtenOut != null) writtenOut.setInt32(0,i << 2);
		return lst;
	}

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

	override private function hasTermination(buf:Buffer, pos:Int):Bool
	{
		return buf.getUInt16(pos-2) == 0;
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

#if (cs || java || js)
	override public function convertToString(buf:indian.Buffer, length:Int, hasTermination:Bool):String
	{
		if (hasTermination) length -= 2;
		if (length <= 0) return '';
		// direct copy
		var ret = new StringBuf();
		var i = -2;
		while(true)
		{
			i += 2;
			if (length >= 0 && i >= length)
				break;
			var chr = buf.getUInt16(i);
			if (length < 0 && chr == 0)
				break;
			ret.addChar(chr);
		}
		return ret.toString();
	}

	override public function convertFromString(string:String, out:indian.Buffer, maxByteLength:Int, reserveTermination:Bool):Int
	{
		var origMaxByte = maxByteLength,
				termBytes = 2;
		if (reserveTermination) maxByteLength -= termBytes;

		var chr = -1,
				i = -1;
		while ( !StringTools.isEof(chr = StringTools.fastCodeAt(string,++i)) && (i << 1) < maxByteLength )
		{
			out.setUInt16(i << 1, chr);
		}
		var written = i << 1;
		if (written <= (origMaxByte - termBytes))
			out.setUInt16(i << 1, 0);

		return written;
	}
#end

	override public function neededLength(string:String, addTermination:Bool):Int
	{
		var term = addTermination ? 1 : 0;
#if (cs || java || js)
		return (string.length + term) << 1;
#else
		var len = string.length;
		pin(str = $ptr(string), {
			var i = 0;
			Utf8.iter(str,0,len, function(cp,_) {
				i++;
				if (cp >= 0xD800 && cp <= 0xDBFF)
					i++;
				return true;
			});
			return (i + term) << 1;
		});
#end
	}

}

