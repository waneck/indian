package indian.safe;
import indian.types.*;
import indian._impl.*;

/**
	This is equivalent to `indian.AnyPtr`. This type however does not require an unsafe context
 **/
@:access(indian.AnyPtr) abstract SafePtr(SafePtrType)
{
	@:extern inline public function new(v)
		this = v;

	@:extern inline public static function fromInternalPointer<T>(ptr:indian._impl.PointerType<T>):SafePtr
#if cs
		return cast new cs.system.IntPtr( ( cast ptr : cs.Pointer<Void> ) );
#elseif cpp
		return untyped (ptr.reinterpret() : SafePtrType);
#else
		return cast ptr;
#end

	@:extern inline public static function fromAnyPtr(ptr:AnyPtr):SafePtr
#if cs
		return new SafePtr( new cs.system.IntPtr( ptr.t() ) );
#else
		return new SafePtr( ptr.t() );
#end

	@:extern @:to inline public function toBuffer():Buffer
#if cs
		return ( cast this.ToPointer() : indian.Buffer );
#elseif cpp
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
#if cs
		return this.ToInt32();
#elseif cpp
		return untyped __cpp__('((int) (size_t) {0})',this.raw);
#elseif java
		return cast this;
#elseif neko
		return indian.types.Int64.toInt(this);
#end

	/**
		Converts the pointer to an Int64 value
	**/
	@:extern inline public function toInt64():Int64
#if cs
		return this.ToInt64();
#elseif cpp
		return untyped __cpp__('( (cpp::Int64) {0})',this.raw);
#elseif java
		return cast this;
#elseif neko
		return cast this;
#end
}
