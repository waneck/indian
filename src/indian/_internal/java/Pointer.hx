package indian._internal.java;
import haxe.Int64;
using haxe.Int64;
import java.sun.misc.Unsafe;

@:suppressWarnings("deprecation")
@:dce abstract Pointer(Int64) from Int64
{
	private static var unsafe:Unsafe = {
		try
		{
			var ctor = java.Lib.toNativeType(Unsafe).getDeclaredConstructor(new java.NativeArray(0));
			trace(ctor);
			ctor.setAccessible(true);
			cast ctor.newInstance(new java.NativeArray(0));
		}
		catch(e:Dynamic)
		{
			trace('Unsafe unsupported. Error:',e);
			null;
		}
	}

	@:extern inline public function new(ptr:Int64)
	{
		this = ptr;
	}

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
		return unsafe.reallocateMemory(this, cast newBytes);
	}

	@:extern inline public function getUInt8(offset:Int):Int
	{
		return cast unsafe.getByte(this.add(cast offset));
	}

	@:extern inline public function setUInt8(offset:Int, val:Int):Void
	{
		unsafe.putByte(this.add(cast offset), val);
	}

	@:extern inline public function getUInt16(offset:Int):Int
	{
		return cast unsafe.getShort(this.add(cast offset));
	}

	@:extern inline public function setUInt16(offset:Int, val:Int):Void
	{
		unsafe.putShort(this.add(cast offset), val);
	}

	@:extern inline public function getInt32(offset:Int):Int
	{
		return cast unsafe.getInt(this.add(cast offset));
	}

	@:extern inline public function setInt32(offset:Int, val:Int):Void
	{
		unsafe.putInt(this.add(cast offset), val);
	}

	@:extern inline public function getFloat32(offset:Int):Single
	{
		return cast unsafe.getFloat(this.add(cast offset));
	}

	@:extern inline public function setFloat32(offset:Int, val:Single):Void
	{
		unsafe.putFloat(this.add(cast offset), val);
	}

	@:extern inline public function getFloat64(offset:Int):Float
	{
		return unsafe.getDouble(this.add(cast offset));
	}

	@:extern inline public function setFloat64(offset:Int, val:Float):Void
	{
		unsafe.putDouble(this.add(cast offset), val);
	}

	@:extern inline public function getPointer<T>(offset:Int):Pointer
	{
		return cast new Pointer(unsafe.getLong(this.add(cast offset)));
	}

	@:extern inline public function setPointer<T>(offset:Int, pointer:Pointer):Void
	{
		unsafe.putLong(this.add(cast offset), pointer.addr());
	}

	@:extern inline public function addr():Int64
	{
		return cast this;
	}

	@:op(A+B) @:extern inline public function add(byteOffset:Int):Pointer
	{
		return new Pointer(this.add(cast byteOffset));
	}

}
