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
// 	@:op(A+B) @:extern inline public function advance(bytesOffset:Int):AnyPtr
// 	{
// #if cs
// 		return cast this;
// 		// return cast cs.system.IntPtr.Add(this,bytesOffset);
// #elseif (cpp || java)
// 		return cast this.add(bytesOffset);
// #elseif (neko && !macro && !interp)
// 		return new AnyPtr(indian._impl.neko.PointerHelper.add(this, bytesOffset));
// #end
// 	}

	/**
		Subtracts an offset to the value of a pointer
	**/
	// @:op(A-B) @:extern inline public function subtract(offset:Int):AnyPtr
	// {
	// 	return advance(-offset);
	// }

	/**
		Converts the pointer to an Int value
	**/
	@:extern inline public function toInt():Int
	{
#if cs
		return this.ToInt32();
#elseif (cpp || java)
		return cast this;
#elseif neko
		return indian.types.Int64.toInt(this);
#end
	}

	/**
		Converts the pointer to an Int64 value
	**/
	@:extern inline public function toInt64():Int64
	{
#if cs
		return this.ToInt64();
#elseif (cpp || java)
		return cast this;
#elseif neko
		return cast this;
#end
	}
}
