package indian;
import taurine.*;
import indian.types.Int64;
import indian._internal.*;

/**
	Any pointer can be accessed as a Buffer type.
	Like the `Ptr` type, a `Buffer` instance can only exist in the stack, and can't be stored as a variable or captured by a function.
**/
@:dce abstract Buffer(BufferType)
{
	@:extern inline private function new(pointer:PointerType<Dynamic>)
	{
		this = cast pointer;
	}

#if cs
	@:unsafe
#else
	@:extern inline
#end
	public static function blit(src:Buffer, srcPos:Int, dest:Buffer, destPos:Int, len:Int):Void
	{
#if cpp
		indian._internal.cpp.Memory.m_memmove(cast (dest + destPos), cast (src + srcPos), len);
#elseif java
		indian._internal.java.Pointer.copy( src.add(srcPos).t(), dest.add(destPos).t(), cast len );
#elseif neko
		indian._internal.neko.PointerHelper.memmove(src,srcPos,dest,destPos,len);
#elseif cs
		trace(len);
		var src = src.t() + srcPos,
				dest = dest.t() + destPos;
		var src64:Int64 = cast src,
				dest64:Int64 = cast dest;
		var src64:Int = cast (src64 & 7);
		var dest64:Int = cast (dest64 & 7);
		var llen = 8 - src64;
		if (src64 == dest64 && len > llen)
		{
			trace('here');
			for (i in 0...llen)
			{
				src[i] = dest[i];
			}
			len -= llen;

			var lsrc:cs.Pointer<Int64> = cast (src + llen);
			var ldest:cs.Pointer<Int64> = cast (dest + llen);
			var llen = Std.int(len/8);
			for (i in 0...llen)
			{
				ldest[i] = lsrc[i];
			}
			len -= llen;
			if (len > 0)
			{
				src = cast lsrc;
				dest = cast ldest;
				for (i in 0...len)
				{
					dest[i] = src[i];
				}
			}
		} else {
			for (i in 0...len)
			{
				dest[i] = src[i];
			}
		}
#end
	}

	@:extern inline public function getUInt8(offset:Int):Int
	{
#if (cpp || cs)
		return this[offset];
#elseif neko
		return indian._internal.neko.PointerHelper.getUInt8(this,offset);
#else
		return this.getUInt8(offset) & 0xFF;
#end
	}

	@:extern inline public function setUInt8(offset:Int, val:Int):Void
	{
#if (cpp || cs)
		this[offset] = val;
#elseif neko
		indian._internal.neko.PointerHelper.setUInt8(this, offset, val);
#else
		this.setUInt8(offset,val);
#end
	}

	@:extern inline public function getUInt16(offset:Int):Int
	{
#if cs
		return ( cast this.add(offset) : PointerType<UInt16> )[0];
#elseif neko
		return indian._internal.neko.PointerHelper.getUInt16(this,offset);
#elseif cpp
		var p16:PointerType<UInt16> = this.add(offset).reinterpret();
		return p16[0];
#else
		return this.getUInt16(offset) & 0xFFFF;
#end
	}

	@:extern inline public function setUInt16(offset:Int, val:Int):Void
	{
#if cs
		( cast this.add(offset) : PointerType<UInt16> )[0] = cast val;
#elseif neko
		indian._internal.neko.PointerHelper.setUInt16(this, offset, val);
#elseif cpp
		var p16:PointerType<UInt16> = this.add(offset).reinterpret();
		p16[0] = cast val;
#else
		this.setUInt16(offset,val);
#end
	}

	@:extern inline public function getInt32(offset:Int):Int
	{
#if cs
		return ( cast this.add(offset) : PointerType<Int> )[0];
#elseif neko
		return indian._internal.neko.PointerHelper.getInt32(this,offset);
#elseif cpp
		var p:PointerType<Int> = this.add(offset).reinterpret();
		return p[0];
#else
		return this.getInt32(offset);
#end
	}

	@:extern inline public function setInt32(offset:Int, val:Int):Void
	{
#if cs
		( cast this.add(offset) : PointerType<Int> )[0] = val;
#elseif neko
		indian._internal.neko.PointerHelper.setInt32(this, offset, val);
#elseif cpp
		var p:PointerType<Int> = this.add(offset).reinterpret();
		p[0] = val;
#else
		this.setInt32(offset,val);
#end
	}

	@:extern inline public function getInt64(offset:Int):Int64
	{
#if cs
		return ( cast this.add(offset) : PointerType<Int64> )[0];
#elseif neko
		return indian._internal.neko.PointerHelper.getInt64(this,offset);
#elseif cpp
		var p:PointerType<Int64> = this.add(offset).reinterpret();
		return p[0];
#elseif java
		return this.getInt32(offset);
#else
		//TODO
#end
	}

	@:extern inline public function setInt64(offset:Int, val:Int64):Void
	{
#if cs
		( cast this.add(offset) : PointerType<Int64> )[0] = val;
#elseif neko
		indian._internal.neko.PointerHelper.setInt64(this, offset, val);
#elseif cpp
		var p:PointerType<Int64> = this.add(offset).reinterpret();
		p[0] = val;
#else
		this.setInt64(offset,val);
#end
	}

	@:extern inline public function getFloat32(offset:Int):Single
	{
#if cs
		return ( cast this.add(offset) : PointerType<Single> )[0];
#elseif neko
		return indian._internal.neko.PointerHelper.getFloat32(this,offset);
#elseif cpp
		var p:PointerType<Single> = this.add(offset).reinterpret();
		return p[0];
#else
		return this.getFloat32(offset);
#end
	}

	@:extern inline public function setFloat32(offset:Int, val:Single):Void
	{
#if cs
		( cast this.add(offset) : PointerType<Single> )[0] = val;
#elseif neko
		indian._internal.neko.PointerHelper.setFloat32(this, offset, val);
#elseif cpp
		var p:PointerType<Single> = this.add(offset).reinterpret();
		p[0] = val;
#else
		this.setFloat32(offset,val);
#end
	}

	@:extern inline public function getFloat64(offset:Int):Float
	{
#if cs
		return ( cast this.add(offset) : PointerType<Float> )[0];
#elseif neko
		return indian._internal.neko.PointerHelper.getFloat64(this,offset);
#elseif cpp
		var p:PointerType<Float> = this.add(offset).reinterpret();
		return p[0];
#else
		return this.getFloat64(offset);
#end
	}

	@:extern inline public function setFloat64(offset:Int, val:Float):Void
	{
#if cs
		( cast this.add(offset) : PointerType<Float> )[0] = val;
#elseif neko
		indian._internal.neko.PointerHelper.setFloat64(this, offset, val);
#elseif cpp
		var p:PointerType<Float> = this.add(offset).reinterpret();
		p[0] = val;
#else
		this.setFloat64(offset,val);
#end
	}

	@:extern inline public function getPointer<T>(offset:Int):PointerType<T>
	{
#if cs
		return ( cast this.add(offset) : PointerType<PointerType<T>> )[0];
#elseif neko
		return indian._internal.neko.PointerHelper.getPointer(this,offset);
#elseif cpp
		return this.add(offset).reinterpret()[0];
#else
		// return this.getFloat64(offset);
		//TODO
		return null;
#end
	}

	@:extern inline public function setPointer<T>(offset:Int, pointer:PointerType<T>):Void
	{
#if cs
		( cast this.add(offset) : PointerType<PointerType<T>> )[0] = pointer;
#elseif neko
		indian._internal.neko.PointerHelper.setPointer(this, offset, pointer);
#elseif cpp
		var p:PointerType<PointerType<T>> = this.add(offset).reinterpret();
		p[0] = pointer;
#else
		// this.setFloat64(offset,val);
		//TODO
#end
	}

	@:extern inline public function getCString()
	{
	}

	public static function memcpy(src:Buffer, srcPos:Int, dest:Buffer, destPos:Int, len:Int):Void
	{
		//TODO
	}

	public static function memmove(src:Buffer, srcPos:Int, dest:Buffer, destPos:Int, len:Int):Void
	{
		//TODO
	}

	@:op(A+B) @:extern inline public function add(byteOffset:Int):Buffer
	{
#if (cs || cpp || java)
		return cast this.add(byteOffset);
#elseif neko
		return new Buffer(indian._internal.neko.PointerHelper.add(byteOffset));
#else
		//TODO
		throw "not available";
#end
	}

	@:op(A-B) @:extern inline public function sub(byteOffset:Int):Buffer
	{
#if (cs || cpp || java)
		return new Buffer(this.add(-byteOffset));
#elseif neko
		return new Buffer(indian._internal.neko.PointerHelper.add(-byteOffset));
#else
		//TODO
		throw "not available";
#end
	}

	@:extern inline private function t()
	{
		return this;
	}
}
