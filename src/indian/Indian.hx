package indian;
#if !macro
import indian.Buffer;
#else
import haxe.macro.Expr;
import indian._macro.IndianHelper;
#end

/**
**/
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
		Memory.free(ptr);
	}

	//TODO block alloc

	inline public static function supportsStackAlloc():Bool
	{
#if (cpp || cs)
		return true;
#else
		return false;
#end
	}

	inline public static function supportsPinning():Bool
	{
#if (cpp || cs)
		return true;
#else
		return false;
#end
	}

	/**
		Frees the memory allocated by `stackalloc`.
	**/
	@:extern inline public static function stackfree(ptr:Buffer):Void
	{
#if cpp
		untyped __cpp__('HX_FREEA({0})',ptr);
#elseif cs
		null;
#else
		free(ptr);
#end
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
		return IndianHelper.stackalloc(bytesLength);
	}

	/**
		This is a macro helper that takes multiple variable declarations and a code block.
		All variable declared in this way will force the underlying garbage-collectible object to be pinned to
		memory while inside this scope.
		A pinned object is an object that is guaranteed not to be moved by the garbage collector.

		There are special identifiers that should be used in the variable declarations:
			- `$ptr` will reinterpret the object to be pinned as a Buffer. It always returns `Buffer`
			- `$addr` will take the address of the variable that points to the pinned object, or the address of
			a field of the pinned object. It works like the `&` operator in C. It always returns `Buffer`

		Pinning is not available on all platforms. In this function, for any platform that does not support pinning:
			- `$ptr` will trigger a full object copy and will work like `autofree` - freeing the object automatically.
			- `$addr` will return null since it is impossible to emulate what it does
		In order to avoid copying, you can either check pinning support by calling `supportsPinning()`, or you can
		use `forcepin`, which will pin and return null if it doesn't support it.

		example:
		```haxe
		Indian.pin(a = $ptr("someString"), b = $ptr(Vector.ofArrayCopy([1,2,3,4])), c = $addr(someObject.someField), d = $addr(someVar), {
			//a, b, c and d will all be typed here as Buffer
		});
		```
	**/
	macro public static function pin(exprs:Array<Expr>):Expr
	{
		return IndianHelper.pin(exprs,false);
	}

	/**
		This function performs the same as `pin`, but will return null if the underlying platform doesn't support direct access
		@see `pin`
	**/
	macro public static function forcepin(exprs:Array<Expr>):Expr
	{
		return IndianHelper.pin(exprs,true);
	}

	/**
		This is a macro helper that takes multiple variable declarations and a code block.
		All variable declared this way will be automatically be freed at the end of the scope

		There are special identifiers that can be used in the variable declarations:
			- `$alloc` is an alias to `Indian.alloc`; It will be automatically freed at the end of the scope
			- `$stackalloc` is an alias to `Indian.stackalloc`; It will be automatically freed with `Indian.stackfree` at the end of the scope
		Please note that `stackfree` will only be used if `$stackalloc` or `Indian.stackalloc` is called directly; otherwise `free` will be called instead

		example:
		```haxe
		Indian.autofree(a = $alloc(10), b = $stackalloc(20), c = getSomeBuffer(), {
			// all the declarations above will be automatically freed after the scope leaves the block.
			// even if an exception is thrown
		});
		```
	**/
	macro public static function autofree(exprs:Array<Expr>):Expr
	{
		return IndianHelper.autofree(exprs);
	}

	/**
		Gets the address of the local stack variable. This only works with stack variables, and may return null on platforms that don't support it.
	**/
	macro public static function addr(of:Expr):Expr
	{
		return IndianHelper.addr(of);
	}

}
