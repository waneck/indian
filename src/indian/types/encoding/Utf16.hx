package indian.types.encoding;
import indian.types.encoding.Encoding;
import indian.Indian.*;
import indian.types.*;

@:unsafe @:final @:dce class Utf16 extends Encoding
{
	public static var cur(default,null) = new Utf16();
	static inline var replacementChar = 0xFFFD;

	@:extern inline public static function iter(source:indian.Buffer,offset:Int,byteLength:Int, iter:Int->Int->Bool):Void
	{
		var srcptr = -2,
				codepoint = 0,
				surrogate = false;
		while(true)
		{
			srcptr += 2;
			// trace(srcptr,byteLength);
			if (byteLength >= 0 && srcptr >= byteLength)
				break;
			var cp = source.getUInt16(offset+srcptr);
			// trace(cp);
			if (cp == 0 && byteLength < 0)
				break;

			if (surrogate)
			{
				surrogate = false;
				if (cp >= 0xDC00 && cp <= 0xDFFF)
				{
					codepoint = (codepoint << 10) + (cp - 0x35FDC00);
				} else {
					codepoint = replacementChar;
					srcptr -= 2;
				}
			} else if (cp >= 0xD800 && cp <= 0xDBFF) {
				surrogate = true;
				codepoint = cp;
				continue;
			} else {
				codepoint = cp;
			}
			if (!iter(codepoint,srcptr))
				break;
		}
	}

	public function new()
	{
		this.terminationBytes = 2;
		this.name = "UTF-16";
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
			if (cp < 0x10000)
			{
				if ((written + 1) << 1 > outMaxByteLength)
					break;
				out.setUInt16(start + ((written++) << 1),cp);
			} else if (cp <= 0x10FFFF) {
				if ((written + 2) << 1 > outMaxByteLength)
					break;
				out.setUInt16(start + ((written++) << 1), (cp >> 10) + 0xD7C0 );
				out.setUInt16(start + ((written++) << 1), (cp & 0x3FF) + 0xDC00 );
			} else {
				if ((written + 1) << 1 > outMaxByteLength)
					break;
				out.setUInt16(start + ((written++) << 1),0xFFFD);
			}
			read = j;
		}
		return new EncodingReturn(read,written<<1);
	}

	override private function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,outMaxByteLength:Int):EncodingReturn
	{
		var read = 0,
				written = 0;
		iter(source,srcoffset,byteLength, function(codepoint:Int, curByte:Int) {
			var next = written + 4;
			trace(codepoint,outMaxByteLength,next);
			trace(StringTools.hex(codepoint));
			if (outMaxByteLength - next < 0)
			{
				return false;
			} else {
				read = curByte + 2;
				out.setInt32(written + outoffset,codepoint);
				written = next;
				return true;
			}
		});
		return new EncodingReturn(read,written);
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

	override public function addTermination(buf:Buffer, pos:Int):Void
	{
		buf.setUInt16(pos,0);
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

	override private function _convertFromString(string:String, out:indian.Buffer, outMaxByteLength:Int):Int
	{
		var chr = -1,
				strindex = -1;
		while ( !StringTools.isEof(chr = StringTools.fastCodeAt(string,++strindex)) && (strindex << 1) < outMaxByteLength )
		{
			out.setUInt16(strindex << 1, chr);
		}
		var written = strindex << 1;
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
			var needed = 0;
			Utf8.iter(str,0,len, function(cp,_) {
				needed++;
				if (cp > 0x10000 && cp <= 0x10FFFF)
					needed++;
				return true;
			});
			return (needed + term) << 1;
		});
#end
	}
}
