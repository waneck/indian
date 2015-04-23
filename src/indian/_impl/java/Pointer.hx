package indian._impl.java;
import indian.types.*;
import indian._impl.java.Unsafe.*;

@:dce abstract Pointer(Int64) from Int64
{
	@:extern inline public static function copy(src:Pointer, dest:Pointer, bytes:indian.types.Int64)
	{
		unsafe.copyMemory(cast src,cast dest,cast bytes);
	}

	@:extern inline public static function nil():Pointer
	{
		return null;
	}

	@:extern inline public function new(ptr:indian.types.Int64)
	{
		this = ptr;
	}

	//FIXME maybe change this to JNI global refs, so memory pressure is realistic
	@:extern inline public static function alloc(nbytes:Int):Pointer
	{
		return new Pointer(unsafe.allocateMemory(cast nbytes));
	}

	@:extern inline public function free()
	{
		unsafe.freeMemory(this);
	}

	@:extern inline public function realloc(newBytes:Int):Pointer
	{
		return cast unsafe.reallocateMemory(this, cast newBytes);
	}

	@:extern inline public function getUInt8(offset:Int):Int
	{
		return cast unsafe.getByte(add(offset).addr());
	}

	@:extern inline public function setUInt8(offset:Int, val:Int):Void
	{
		unsafe.putByte(add(offset).addr(), val);
	}

	@:extern inline public function getUInt16(offset:Int):Int
	{
		return cast unsafe.getShort(add(offset).addr());
	}

	@:extern inline public function setUInt16(offset:Int, val:Int):Void
	{
		unsafe.putShort(add(offset).addr(), val);
	}

	@:extern inline public function getInt32(offset:Int):Int
	{
		return cast unsafe.getInt(add(offset).addr());
	}

	@:extern inline public function setInt32(offset:Int, val:Int):Void
	{
		unsafe.putInt(add(offset).addr(), val);
	}

	@:extern inline public function getInt64(offset:Int):indian.types.Int64
	{
		return unsafe.getLong(add(offset).addr());
	}

	@:extern inline public function setInt64(offset:Int, val:indian.types.Int64):Void
	{
		unsafe.putLong(add(offset).addr(), val);
	}

	@:extern inline public function getFloat32(offset:Int):Single
	{
		return cast unsafe.getFloat(add(offset).addr());
	}

	@:extern inline public function setFloat32(offset:Int, val:Single):Void
	{
		unsafe.putFloat(add(offset).addr(), val);
	}

	@:extern inline public function getFloat64(offset:Int):Float
	{
		return unsafe.getDouble(add(offset).addr());
	}

	@:extern inline public function setFloat64(offset:Int, val:Float):Void
	{
		unsafe.putDouble(add(offset).addr(), val);
	}

	@:extern inline public function getPointer<T>(offset:Int):Pointer
	{
		return cast new Pointer(unsafe.getLong(add(offset).addr()));
	}

	@:extern inline public function setPointer<T>(offset:Int, pointer:Pointer):Void
	{
		unsafe.putLong(add(offset).addr(), pointer.addr());
	}

	@:extern inline public function addr():indian.types.Int64
	{
		return this;
	}

	@:op(A+B) @:extern inline public function add(byteOffset:Int):Pointer
	{
		return new Pointer(this + byteOffset);
	}
}

@:final @:nativeGen class PointerHelper
{
	@:readOnly public static var current(default,never):PointerSize = getCurrent();

	public static function getCurrent():PointerSize
	{
		if (indian.AnyPtr.size == 4)
			return new PointerSize32();
		else
			return new PointerSize64();
	}

}

@:abstract @:nativeGen class PointerSize
{
	public function getPointer(ptr:Pointer,offset:Int):Pointer
	{
		return ptr;
	}

	public function setPointer(ptr:Pointer,offset:Int,val:Pointer):Void
	{
	}
}

@:final @:nativeGen class PointerSize32 extends PointerSize
{
	public function new()
	{
	}

	override public function getPointer(ptr:Pointer, offset:Int):Pointer
	{
		return new Pointer(cast ptr.getInt32(offset));
	}

	override public function setPointer(ptr:Pointer,offset:Int,val:Pointer):Void
	{
		ptr.setInt32(offset,untyped val.addr());
	}
}

@:final @:nativeGen class PointerSize64 extends PointerSize
{
	public function new()
	{
	}

	override public function getPointer(ptr:Pointer, offset:Int):Pointer
	{
		return new Pointer(ptr.getInt64(offset));
	}

	override public function setPointer(ptr:Pointer,offset:Int,val:Pointer):Void
	{
		ptr.setInt64(offset,val.addr());
	}
}

// this class is here to allow null values to be passed to Int64 (as a pointer is nullable)
@:native("java.Int64")
@:runtimeValue @:coreType private abstract Int64 from Int from Float to indian.types.Int64 from indian.types.Int64 from haxe.Int64 to haxe.Int64
{
	@:op(A+B) public static function addI(lhs:Int64, rhs:Int):Int64;
	@:op(A+B) public static function add(lhs:Int64, rhs:Int64):Int64;
	@:op(A*B) public static function mulI(lhs:Int64, rhs:Int):Int64;
	@:op(A*B) public static function mul(lhs:Int64, rhs:Int64):Int64;
	@:op(A%B) public static function modI(lhs:Int64, rhs:Int):Int64;
	@:op(A%B) public static function mod(lhs:Int64, rhs:Int64):Int64;
	@:op(A-B) public static function subI(lhs:Int64, rhs:Int):Int64;
	@:op(A-B) public static function sub(lhs:Int64, rhs:Int64):Int64;
	@:op(A/B) public static function divI(lhs:Int64, rhs:Int):Int64;
	@:op(A/B) public static function div(lhs:Int64, rhs:Int64):Int64;
	@:op(A|B) public static function orI(lhs:Int64, rhs:Int):Int64;
	@:op(A|B) public static function or(lhs:Int64, rhs:Int64):Int64;
	@:op(A^B) public static function xorI(lhs:Int64, rhs:Int):Int64;
	@:op(A^B) public static function xor(lhs:Int64, rhs:Int64):Int64;
	@:op(A&B) public static function andI(lhs:Int64, rhs:Int):Int64;
	@:op(A&B) public static function and(lhs:Int64, rhs:Int64):Int64;
	@:op(A<<B) public static function shlI(lhs:Int64, rhs:Int):Int64;
	@:op(A<<B) public static function shl(lhs:Int64, rhs:Int64):Int64;
	@:op(A>>B) public static function shrI(lhs:Int64, rhs:Int):Int64;
	@:op(A>>B) public static function shr(lhs:Int64, rhs:Int64):Int64;
	@:op(A>>>B) public static function ushrI(lhs:Int64, rhs:Int):Int64;
	@:op(A>>>B) public static function ushr(lhs:Int64, rhs:Int64):Int64;

	@:op(A>B) public static function gt(lhs:Int64, rhs:Int64):Bool;
	@:op(A>=B) public static function gte(lhs:Int64, rhs:Int64):Bool;
	@:op(A<B) public static function lt(lhs:Int64, rhs:Int64):Bool;
	@:op(A<=B) public static function lte(lhs:Int64, rhs:Int64):Bool;

	@:op(~A) public static function bneg(t:Int64):Int64;
	@:op(-A) public static function neg(t:Int64):Int64;

	@:op(++A) public static function preIncrement(t:Int64):Int64;
	@:op(A++) public static function postIncrement(t:Int64):Int64;
	@:op(--A) public static function preDecrement(t:Int64):Int64;
	@:op(A--) public static function postDecrement(t:Int64):Int64;
}
