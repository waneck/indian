package indian;
import indian.types.*;
import indian._impl.*;

/**
	This is equivalent to a `void *` pointer in C. It's a pointer, but what it points to is not known,
	and its underlying value is unaccessible while it remains so.

	All `indian.Ptr` types can be interpreted as `AnyPtr`, and it can be used outside an unsafe context.
 **/
abstract AnyPtr(AnyPtrType)
{
	/**
		Contains the size - in bytes - of a pointer. Returns 4 if on 32-bit, and 8 if on 64-bit
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

	@:extern inline public function new(v)
	{
		this = v;
	}

	@:extern inline public static function fromInternalPointer<T>(ptr:indian._impl.PointerType<T>):AnyPtr
	{
#if cs
		return cast new cs.system.IntPtr( ( cast ptr : cs.Pointer<Void> ) );
#elseif cpp
		return untyped (ptr.reinterpret() : AnyPtrType);
#else
		return cast ptr;
#end
	}

	@:extern @:to inline public function toBuffer():Buffer
	{
#if cs
		return ( cast this.ToPointer() : indian.Buffer );
#elseif cpp
		return untyped ( this.reinterpret() : indian._impl.BufferType );
#else
		return cast this;
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
