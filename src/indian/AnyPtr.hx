package indian;
import indian.types.*;
import indian._impl.*;

/**
	This is equivalent to a `void *` pointer in C. It's a pointer, but its value is not known.
	All `indian.Ptr` types can be interpreted as `AnyPtr`, and it can be used outside an unsafe context
 **/
abstract AnyPtr(AnyPtrType)
{
	/**
		Contains the size - in bytes - of a pointer. Returns 4 on a 32-bit machine, and 8 in a 64-bit
	**/
	public static var size(default,null):Int = {
#if java
		indian._impl.java.Unsafe.unsafe.addressSize();
#elseif cs
		cs.system.IntPtr.Size;
#elseif cpp
		untyped __cpp__("sizeof(void *)");
#elseif neko
		indian._impl.neko.PointerHelper.ptrsize();
#else
#error "Not available"
#end
	};

	@:extern inline public static function fromPointer<T>(ptr:indian._impl.PointerType<T>):AnyPtr
	{
#if cs
		return cast new cs.system.IntPtr( ( cast ptr : cs.Pointer<Void> ) );
#elseif cpp
		return untyped (ptr.reinterpret() : AnyPtrType);
#else
		return cast ptr;
#end
	}

	/**
		Adds an offset to the value of a pointer
	**/
	// @:op(A+B) public function advance(offset:Int):AnyPtr
	// {
	// }

	/**
		Subtracts an offset to the value of a pointer
	**/
	// @:op(A-B) public function subtract(offset:Int):AnyPtr
	// {
	// }

	/**
		Converts the pointer to an Int value
	**/
	// public function toInt():Int
	// {
	// }

	/**
		Converts the pointer to an Int64 value
	**/
	// public function toInt64():Int64
	// {
	// }
}
