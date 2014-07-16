package indian;
import haxe.Int64;
import indian._internal.PtrData;
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;
#end

/**
	A Ptr represents a pointer to a natively-allocated memory chunk.
	This is the lightest representation of a pointer, since it performs no checks and doesn't have to perform a lookup for the descriptors.
	However, acquiring a buffer instance from an IntPtr requires a descriptor lookup,
	so in cases where the pointer may be stored for an extended period of time, it is advisable to store a MemChunk instance instead
**/
abstract IntPtr<T>(PtrData)
{
	macro public function pcast(ethis:haxe.macro.Expr, to:haxe.macro.Expr):haxe.macro.Expr
	{
		var type = switch (Context.parse('(_ : ${to.toString()})', to.pos)) {
			case macro (_ : $t):
				t;
			case _:
				throw "assert";
		};
		return macro (cast $ethis : indian.IntPtr<$type>);
	}
#if !macro
	inline public function new(pointer)
	{
		this = pointer;
	}

	public static var pointerSize(get,never):Int;


	inline public function descriptor():MemChunk
	{
	}

	inline public function unsafeBuffer():Buffer
	{
	}

	inline public function eq(to:IntPtr<T>):Bool
	{
	}

	@:op(A+B) public function add(nbytes:Int):IntPtr
	{
	}

	@:op(A+B) public function add64(nbytes:Int64):IntPtr
	{
	}

	@:op(A-B) public function sub(nbytes:Int):IntPtr
	{
	}

	@:op(A-B) public function sub64(nbytes:Int64):IntPtr
	{
	}

	@:deprecated("Do not use the equality operator with pointers as it's not reliable. Use `eq` instead")
	@:op(A == B) inline public function equals(to:IntPtr<T>):Bool
	{
		return eq(to);
	}

	@:deprecated("Do not use the equality operator with pointers as it's not reliable. Use `eq` instead")
	@:op(A != B) inline public function notEquals(to:IntPtr<T>):Bool
	{
		return !eq(to);
	}
#end
}
