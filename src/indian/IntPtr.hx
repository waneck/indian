package indian;
import indian._impl.*;
import indian.types.*;

/**
	This type always has the same size as a Pointer. This way it can be safely cast to and from any Pointer, and
	this way it is possible to do arithmetic with it.
	It is equivalent to the unmanaged types `intptr_t`,	`size_t` and `ptrdiff_t`.
**/
@:access(indian) abstract IntPtr(IntPtrType)
{
	@:extern inline private function new(t)
		this = t;

	@:from @:extern inline public static function fromInt(i:Int):IntPtr
#if cs
		return new IntPtr(new cs.system.IntPtr( i ));
#elseif cpp
		return new IntPtr( IntPtrType.ofInt(i) );
#else
		return new IntPtr( cast i );
#end

	@:from @:extern inline public static function fromInt64(i:Int64):IntPtr
#if cs
		return new IntPtr(new cs.system.IntPtr( i.t() ));
#elseif cpp
		return new IntPtr( IntPtrType.ofInt64(i.t()) );
#else
		return new IntPtr( cast i );
#end

	@:from @:extern inline public static function fromPointer(i:AnyPtr):IntPtr
#if cs
		return new IntPtr(new cs.system.IntPtr( (cast i.t() : cs.Pointer<Void>) ));
#elseif cpp
		return new IntPtr( IntPtrType.ofPointer(i.t().raw) );
#else
		return new IntPtr(i.t());
#end

	@:extern inline public function toInt():Int
#if cs
		return this.ToInt32();
#elseif cpp
		return this.toInt();
#elseif java
		return cast this;
#elseif neko
		return indian.types.Int64.toInt(this);
#end

	@:to @:extern inline public function toInt64():Int64
#if cs
		return this.ToInt64();
#elseif cpp
		return untyped this.toInt64();
#elseif java
		return cast this;
#elseif neko
		return cast this;
#end

	@:to @:extern inline public function toPointer():AnyPtr
#if cs
		return cast this.ToPointer();
#elseif cpp
		return cast this.toPointer();
#else
		return cast this;
#end

	@:extern inline private function t()
		return this;


	@:extern @:op(A+B) public inline function add(i:Int):IntPtr
#if cpp
		return new IntPtr(this.add(i));
#else
		return fromInt64(toInt64()+i);
#end

	// @:extern @:op(A++) public inline function incr():IntPtr
	// @:extern @:op(A--) public inline function decr():IntPtr

	@:extern @:op(A-B) public inline function sub(i:Int):IntPtr
#if cpp
		return new IntPtr(this.sub(i));
#else
		return fromInt64(toInt64()-i);
#end

	@:extern @:op(A+B) public inline function add_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.add_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()+i);
#end

	@:extern @:op(A+B) public inline function add_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.add_iptr(i.t()));
#else
		return fromInt64(toInt64()+i.toInt64());
#end

	@:extern @:op(A-B) public inline function sub_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.sub_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()-i);
#end

	@:extern @:op(A-B) public inline function sub_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.sub_iptr(i.t()));
#else
		return fromInt64(toInt64()-i.toInt64());
#end

	@:extern @:op(-A) inline public function neg():IntPtr
#if cpp
		return new IntPtr(this.neg());
#else
		return fromInt64(-toInt64());
#end

	@:extern @:op(A*B) public inline function mul(i:Int):IntPtr
#if cpp
		return new IntPtr(this.mul(i));
#else
		return fromInt64(toInt64()*i);
#end

	@:extern @:op(A*B) public inline function mul_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.mul_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()*i);
#end

	@:extern @:op(A*B) public inline function mul_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.mul_iptr(i.t()));
#else
		return fromInt64(toInt64()*i.toInt64());
#end

	@:extern @:op(A/B) public inline function div(i:Int):IntPtr
#if cpp
		return new IntPtr(this.div(i));
#else
		return fromInt64(toInt64()/i);
#end

	@:extern @:op(A/B) public inline function div_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.div_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()/i);
#end

	@:extern @:op(A/B) public inline function div_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.div_iptr(i.t()));
#else
		return fromInt64(toInt64()/i.toInt64());
#end

	@:extern @:op(A%B) public inline function mod(i:Int):IntPtr
#if cpp
		return new IntPtr(this.mod(i));
#else
		return fromInt64(toInt64()%i);
#end

	@:extern @:op(A%B) public inline function mod_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.mod_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()%i);
#end

	@:extern @:op(A%B) public inline function mod_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.mod_iptr(i.t()));
#else
		return fromInt64(toInt64()%i.toInt64());
#end

	@:extern @:op(A<<B) public inline function shl(i:Int):IntPtr
#if cpp
		return new IntPtr(this.shl(i));
#else
		return fromInt64(toInt64()<<i);
#end

	@:extern @:op(A>>B) public inline function shr(i:Int):IntPtr
#if cpp
		return new IntPtr(this.shr(i));
#else
		return fromInt64(toInt64()>>i);
#end

	@:extern @:op(A>>>B) public inline function ushr(i:Int):IntPtr
#if cpp
		return new IntPtr(this.ushr(i));
#else
		return fromInt64(toInt64()>>>i);
#end

	@:extern @:op(A&B) public inline function and(i:Int):IntPtr
#if cpp
		return new IntPtr(this.iand(i));
#else
		return fromInt64(toInt64()&i);
#end

	@:extern @:op(A&B) public inline function and_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.and_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()&i);
#end

	@:extern @:op(A&B) public inline function and_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.and_iptr(i.t()));
#else
		return fromInt64(toInt64()&i.toInt64());
#end

	@:extern @:op(A|B) public inline function or(i:Int):IntPtr
#if cpp
		return new IntPtr(this.ior(i));
#else
		return fromInt64(toInt64()|i);
#end

	@:extern @:op(A|B) public inline function or_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.or_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()|i);
#end

	@:extern @:op(A|B) public inline function or_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.or_iptr(i.t()));
#else
		return fromInt64(toInt64()|i.toInt64());
#end

	@:extern @:op(A^B) public inline function xor(i:Int):IntPtr
#if cpp
		return new IntPtr(this.ixor(i));
#else
		return fromInt64(toInt64()^i);
#end

	@:extern @:op(A^B) public inline function xor_int64(i:Int64):IntPtr
#if cpp
		return new IntPtr(this.xor_iptr(fromInt64(i).t()));
#else
		return fromInt64(toInt64()^i);
#end

	@:extern @:op(A^B) public inline function xor_intptr(i:IntPtr):IntPtr
#if cpp
		return new IntPtr(this.xor_iptr(i.t()));
#else
		return fromInt64(toInt64()^i.toInt64());
#end

	// @:extern public static inline function compare(a:IntPtr, b:IntPtr):Int
	// @:extern @:op(A>B) public static inline function gt(a:IntPtr, i:Int):Bool
	// @:extern @:op(A>B) public static inline function gt_int64(a:IntPtr, i:IntPtr):Bool
	// @:extern @:op(A>=B) public static inline function gte(a:IntPtr, i:Int):Bool
	// @:extern @:op(A>=B) public static inline function gte_int64(a:IntPtr, i:IntPtr):Bool
	// @:extern @:op(A<B) public static inline function lt(a:IntPtr, i:Int):Bool
	// @:extern @:op(A<B) public static inline function lt_int64(a:IntPtr, i:IntPtr):Bool
	// @:extern @:op(A<=B) public static inline function lte(a:IntPtr, i:Int):Bool
	// @:extern @:op(A<=B) public static inline function lte_int64(a:IntPtr, i:IntPtr):Bool

	@:extern @:op(A==B) public inline function eq(to:IntPtr):Bool
#if cs
		return untyped this.Equals(to.t());
#else
		return this == to.t();
#end

}
