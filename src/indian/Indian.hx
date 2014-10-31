package indian;
#if !macro
import indian.Buffer;
#else
import haxe.macro.Expr;
import haxe.macro.Context;
#end

@:unsafe class Indian
{
#if !macro
	/**
		Allocates non-gc heap bytes, and returns a pointer to it.
		Any memory allocated with this method *must* be freed by calling `Indian.free`
	**/
	inline public static function alloc(bytesLength:Int):Buffer
	{
		return Memory.alloc(bytesLength);
	}

	inline public static function free(ptr:Buffer):Void
	{
	}

	inline public static function supportsStackAlloc():Bool
	{
#if (cpp || cs)
		return true;
#else
		return false;
#end
	}

	/**
		Gets a pointer to a directly-accessed
	**/
	public static function stringPtr(string:String):Null<Buffer>
	{
	}

	public static function arrayPtr<T>(array:Array<T>):Null<Buffer>
	{
	}

#end
	/**
		Tries to allocate a memory of size `bytesLength` in the stack.
		The success of the operation depends on the platform support for it.
		If it is not possible to allocate in the stack, `bytesLength` will be allocated in the heap instead.
		Any memory allocated with this method *must* be freed by calling `Indian.stackfree`
	**/
	macro public static function stackalloc(bytesLength:ExprOf<Int>):ExprOf<Buffer>
	{
	}

	/**
		Frees the memory allocated by `stackalloc`.
	**/
	macro public static function stackfree(ptr:ExprOf<Buffer>):Void
	{
	}

	/**
		```
		Indian.auto(var a = alloc(10), b = stackalloc(20), c = stringPtr("someStr"), {
			// all the declarations above will be automatically freed after the scope leaves the block.
			// even if an exception is thrown
		});
		```
	**/
	macro public static function auto(exprs:Array<Expr>):Expr
	{
	}

}
