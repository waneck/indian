package indian;
import indian.types.*;
import indian._impl.*;

/**
	Any pointer can be accessed as a Buffer type.
	Like the `Ptr` type, a `Buffer` instance can only exist in the stack, and can't be stored as a variable or captured by a function.
**/
@:dce abstract Buffer(BufferType)
{
	@:extern inline private function new(pointer:BufferType)
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
		indian._impl.cpp.Memory.memmove(cast (dest + destPos), cast (src + srcPos), len);
#elseif java
		indian._impl.java.Pointer.copy( src.add(srcPos).t(), dest.add(destPos).t(), cast len );
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.memmove(src,srcPos,dest,destPos,len);
#elseif cs
		var src = src.t() + srcPos,
				dest = dest.t() + destPos;
		var src64:Int64 = cast src,
				dest64:Int64 = cast dest;
		if (src64 < dest64 && (src64+len) > dest64)
		{
			//copy from the back - slow
			while (len --> 0)
			{
				dest[len] = src[len];
			}
		} else {
			//copy using Int64's
			var lsrc:cs.Pointer<Int64> = cast src;
			var ldest:cs.Pointer<Int64> = cast dest;
			var ilen = len >>> 3;
			for (i in 0...ilen)
			{
				ldest[i] = lsrc[i];
			}
			len -= ilen << 3;
			if (len > 0)
			{
				var offset = ilen << 3;
				for (i in 0...len)
				{
					dest[offset+i] = src[offset+i];
				}
			}
		}
#else
		indian._impl.cross.RawMem.blit(src, srcPos, dest, destPos, len);
#end
	}

	/**
		Physically compares `this` Buffer to `to`.
	**/
	@:unsafe public function physCompare(to:Buffer):Int
	{
#if (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.physcmp(this,to);
#elseif cpp
		return (this == to.t()) ? 0 : (this.lt(to.t())) ? -1 : 1;
#elseif java
		return (this == to.t()) ? 0 : (this.addr() < to.t().addr()) ? -1 : 1;
#else
		return (this == to.t()) ? 0 : (this < to.t()) ? -1 : 1;
#end
	}

	@:op(A == B) inline public function equals(to:Buffer):Bool
	{
#if (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.physcmp(this,to.t()) == 0;
#else
		return this == to.t();
#end
	}

	@:op(A >= B) inline public function gte(to:Buffer):Bool
	{
#if (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.physcmp(this,to.t()) >= 0;
#elseif cpp
		return this.geq(to.t());
#elseif java
		return this.addr() >= to.t().addr();
#else
		return this >= to.t();
#end
	}

	@:op(A > B) inline public function gt(to:Buffer):Bool
	{
#if (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.physcmp(this,to.t()) > 0;
#elseif cpp
		return this.gt(to.t());
#elseif java
		return this.addr() > to.t().addr();
#else
		return this > to.t();
#end
	}

	@:op(A <= B) inline public function lte(to:Buffer):Bool
	{
#if (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.physcmp(this,to.t()) <= 0;
#elseif cpp
		return this.leq(to.t());
#elseif java
		return this.addr() <= to.t().addr();
#else
		return this <= to.t();
#end
	}

	@:op(A < B) inline public function lt(to:Buffer):Bool
	{
#if (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.physcmp(this,to.t()) < 0;
#elseif cpp
		return this.lt(to.t());
#elseif java
		return this.addr() < to.t().addr();
#else
		return this < to.t();
#end
	}

#if (cs || java)
	@:unsafe
#else
	@:extern inline
#end
	public static function compare(ptr1:Buffer, ptr1pos:Int, ptr2:Buffer, ptr2pos:Int, len:Int):Int
	{
#if cpp
		return indian._impl.cpp.Memory.memcmp(cast (ptr1 + ptr1pos), cast (ptr2 + ptr2pos), len);
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.memcmp(ptr1,ptr1pos,ptr2,ptr2pos,len);
#elseif java
		ptr1 = ptr1 + ptr1pos;
		ptr2 = ptr2 + ptr2pos;
		var llen = len >>> 3;
		for (i in 0...llen)
		{
			var v1 = ptr1.getInt64(i<<3),
					v2 = ptr2.getInt64(i<<3);
			if (v1 != v2)
			{
				for (j in 0...4)
				{
					var v = ptr1.getUInt16( (i<<3) + (j << 1) ) - ptr2.getUInt16( (i<<3) + (j << 1) );
					if (v != 0) return v;
				}
			}
		}
		len -= llen << 3;
		if (len > 0)
		{
			var offset = llen << 3;
			for (j in 0...len)
			{
				var v = ptr1.getUInt8( offset + j ) - ptr2.getUInt8( offset + j );
				if (v != 0) return v;
			}
		}

		return 0;
#elseif cs
		ptr1 = ptr1 + ptr1pos;
		ptr2 = ptr2 + ptr2pos;
		var llen = len >>> 3;
		for (i in 0...llen)
		{
			var v1:cs.StdTypes.UInt64 = cast ptr1.getInt64(i<<3),
					v2:cs.StdTypes.UInt64 = cast ptr2.getInt64(i<<3);
			if (v1 != v2)
			{
				return v1 < v2 ? -1 : 1;
			}
		}
		len -= llen << 3;
		if (len > 0)
		{
			var offset = llen << 3;
			for (j in 0...len)
			{
				var v = ptr1.getUInt8( offset + j ) - ptr2.getUInt8( offset + j );
				if (v != 0) return v;
			}
		}

		return 0;
#end
	}

#if !(neko || cpp)
	@:unsafe
#else
	@:extern inline
#end
	public static function strlen(src:Buffer, offset:Int):Int
	{
#if cpp
		return indian._impl.cpp.Memory.strlen(src + offset);
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.strlen(src, offset);
#else
		var len = offset;
		while (true)
		{
			var v = src.getUInt8(++len);
			if (v == 0)
				return (len - offset);
		}
		return -1;
#end
	}



	@:extern inline public function getUInt8(offset:Int):Int
	{
#if (cpp || cs)
		return this[offset];
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.getUInt8(this,offset);
#else
		return this.getUInt8(offset) & 0xFF;
#end
	}

	@:extern inline public function setUInt8(offset:Int, val:Int):Void
	{
#if (cpp || cs)
		this[offset] = cast val;
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.setUInt8(this, offset, val);
#else
		this.setUInt8(offset,val);
#end
	}

	@:extern inline public function getUInt16(offset:Int):Int
	{
#if cs
		return ( cast this.add(offset) : PointerType<UInt16> )[0];
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.getUInt16(this,offset);
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
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.setUInt16(this, offset, val);
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
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.getInt32(this,offset);
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
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.setInt32(this, offset, val);
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
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.getInt64(this,offset);
#elseif cpp
		var p:PointerType<Int64> = this.add(offset).reinterpret();
		return p[0];
#elseif java
		return this.getInt64(offset);
#else
		//TODO
#end
	}

	@:extern inline public function setInt64(offset:Int, val:Int64):Void
	{
#if cs
		( cast this.add(offset) : PointerType<Int64> )[0] = val;
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.setInt64(this, offset, val);
#elseif cpp
		var p:PointerType<Int64> = this.add(offset).reinterpret();
		p[0] = val;
#elseif java
		this.setInt64(offset,val);
#else
		this.setInt64(offset,val);
#end
	}

	@:extern inline public function getFloat32(offset:Int):Single
	{
#if cs
		return ( cast this.add(offset) : PointerType<Single> )[0];
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.getFloat32(this,offset);
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
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.setFloat32(this, offset, val);
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
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.getFloat64(this,offset);
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
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.setFloat64(this, offset, val);
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
#elseif (neko && !macro && !interp)
		return indian._impl.neko.PointerHelper.getPointer(this,offset);
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
#elseif (neko && !macro && !interp)
		indian._impl.neko.PointerHelper.setPointer(this, offset, pointer);
#elseif cpp
		var p:PointerType<PointerType<T>> = this.add(offset).reinterpret();
		p[0] = pointer;
#else
		// this.setFloat64(offset,val);
		//TODO
#end
	}

	@:op(A+B) @:extern inline public function add(byteOffset:Int):Buffer
	{
#if (cs || cpp || java)
		return cast this.add(byteOffset);
#elseif (neko && !macro && !interp)
		return new Buffer(indian._impl.neko.PointerHelper.add(this, byteOffset));
#else
		//TODO
		throw "not available";
#end
	}

	@:op(A++) @:extern inline public function preincr():Buffer
	{
		var t = this;
		this = add(1).t();
		return cast t;
	}

	@:op(A--) @:extern inline public function predecr():Buffer
	{
		var t = this;
		this = add(-1).t();
		return cast t;
	}

	@:op(++A) @:extern inline public function incr():Buffer
	{
		return cast this = add(1).t();
	}

	@:op(--A) @:extern inline public function decr():Buffer
	{
		return cast this = add(-1).t();
	}

	@:op(A-B) @:extern inline public function sub(byteOffset:Int):Buffer
	{
#if (cs || cpp || java)
		return cast this.add(-byteOffset);
#elseif (neko && !macro && !interp)
		return new Buffer(indian._impl.neko.PointerHelper.add(this, -byteOffset));
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
