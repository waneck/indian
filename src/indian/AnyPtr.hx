package indian;
import indian.types.*;
import indian._impl.*;

/**
	This is equivalent to a `void *` pointer in C. It's a pointer, but what it points to is not known,
	and its underlying value is unaccessible while it remains so.

	All `indian.Ptr` types can be interpreted as `indian.AnyPtr`
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

	public static var power(default,null):Int = {
		var index = size;
		var targetlevel = 0;
		while ((index >>>= 1) > 0) ++targetlevel;
		targetlevel;
	};

	@:extern inline public function new(v)
	{
		this = v;
	}

	@:extern inline public static function fromInternalPointer<T>(ptr:indian._impl.PointerType<T>):AnyPtr
#if cpp
		return untyped (ptr.reinterpret() : AnyPtrType);
#else
		return cast ptr;
#end

	@:extern @:to inline public function toBuffer():Buffer
#if cpp
		return untyped ( this.reinterpret() : indian._impl.BufferType );
#else
		return cast this;
#end

	@:extern inline private function t()
		return this;

	/**
		Converts the pointer to an Int value
	**/
	@:extern inline public function toInt():Int
	{
#if cpp
		return untyped __cpp__('((int) (size_t) {0})',this.raw);
#elseif (cs || java)
		return cast toInt64();
#elseif neko
		return indian.types.Int64.toInt(this);
#end
	}

	/**
		Converts the pointer to an Int64 value
	**/
	@:extern inline public function toInt64():Int64
	{
#if cpp
		return untyped __cpp__('( (cpp::Int64) {0})',this.raw);
#elseif cs
		return cast this;
#elseif (neko || java)
		return untyped this;
#end
	}
}
