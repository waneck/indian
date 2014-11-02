package indian;
#if !macro
import indian.Buffer;
#else
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Context.*;
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

	inline public static function supportsStackAlloc():Bool
	{
#if (cpp || cs)
		return true;
#else
		return false;
#end
	}

	/**
		Gets a pointer to the directly-accessed string bytes. Returns null if this operation is not available on this platform.
	**/
	// public static function stringPtr(string:String):Null<Buffer>
	// {
	// 	retur
	// }

	// public static function arrayPtr<T>(array:Array<T>):Null<Buffer>
	// {
	// }

	// public static function addrOf<T>(val:T):Ptr<T>
	// {
	// }
#end
	/**
		Tries to allocate a memory of size `bytesLength` in the stack.
		The success of the operation depends on the platform support for it.
		If it is not possible to allocate in the stack, `bytesLength` will be allocated in the heap instead.
		Any memory allocated with this method *must* be freed by calling `Indian.stackfree`
	**/
	macro public static function stackalloc(bytesLength:ExprOf<Int>):ExprOf<Buffer>
	{
		// var value:Null<Int> = switch(bytesLength.expr) {
		// 	case EConst(CInt(i)):
		// 		Std.parseInt(i);
		// 	case _:
		// 		null;
		// }

		if (defined('cpp'))
		{
			var cls = Context.getLocalClass().get();
			// if (value != null)
			// {
			// 	var tmpNum = Context.getPosInfos(bytesLength.pos);
			// 	var decl = 'char stackalloc_${tmpNum.min}[$value]',
			// 			val = '(void *) stackalloc_${tmpNum.min}';
			// 	macro @:mergeBlock { untyped __cpp__($v{decl}); untyped __cpp__($v{val}); };
			// } else {
				if (!cls.meta.has(':alloca'))
				{
					cls.meta.add(':alloca',[],bytesLength.pos);
					cls.meta.add(':headerCode',[macro "#include <alloca.h>\n#ifdef _MSC_VER\n#define HX_ALLOCA(v) (unsigned char *) _malloca(v)\n#define HX_FREEA _freea(v)\n#else\n#define HX_ALLOCA(v) (unsigned char *) alloca(v)\n#define HX_FREEA \n#endif\n"], bytesLength.pos);
				}
				return macro ( (untyped __cpp__('HX_ALLOCA({0})',$bytesLength)) : indian.Buffer );
			// }
		} else if (defined('cs')) {
			var tmpNum = Context.getPosInfos(bytesLength.pos);
			return macro ( (cast untyped __arrptr__(__stackalloc__($bytesLength))) : indian.Buffer );
		} else {
			return macro indian.Indian.alloc($bytesLength);
		}
	}

	/**
		Frees the memory allocated by `stackalloc`.
	**/
	macro public static function stackfree(ptr:ExprOf<Buffer>):ExprOf<Void>
	{
		if (defined('cpp'))
		{
			return macro untyped __cpp__('HX_FREEA({0})',$ptr);
		} else if (defined('cs')) {
			return macro null;
		} else {
			return macro indian.Indian.free($ptr);
		}
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
		return null;
	}

}
