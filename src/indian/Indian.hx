package indian;
#if !macro
import indian.Buffer;
#else
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Context.*;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
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

	inline public static function supportsPinning():Bool
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
			if (!cls.meta.has(':alloca'))
			{
				cls.meta.add(':alloca',[],bytesLength.pos);
				cls.meta.add(':headerCode',[macro "#ifndef HX_ALLOCA\n#include <alloca.h>\n#ifdef _MSC_VER\n#define HX_ALLOCA(v) (unsigned char *) _malloca(v)\n#define HX_FREEA _freea(v)\n#else\n#define HX_ALLOCA(v) (unsigned char *) alloca(v)\n#define HX_FREEA \n#endif\n#endif\n"], bytesLength.pos);
			}
			return macro ( (untyped __cpp__('HX_ALLOCA({0})',$bytesLength)) : indian.Buffer );
		} else if (defined('cs')) {
			var tmpNum = Context.getPosInfos(bytesLength.pos);
			return macro ( (cast untyped __ptr__(__stackalloc__($bytesLength))) : indian.Buffer );
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
		This is a macro helper that takes multiple variable declarations and a code block.
		All variable declared in this way will force the underlying garbage-collectible object to be pinned to
		memory while inside this scope.
		A pinned object is an object that is guaranteed not to be moved by the garbage collector.
		Pinning is not available on all platforms. As such, any garbage-collectible object that cannot be pinned may
		return `null` as a pointer.

		There are special identifiers that can be used in the variable declarations:
			- `ptr` will reinterpret the object to be pinned as a Buffer. It always returns `Buffer`
			- `addr` will take the address of the variable that points to the pinned object, or the address of
			a field of the pinned object. It works like the `&` operator in C. It always returns `Buffer`

		example:
		```haxe
		Indian.pin(a = ptr("someString"), b = ptr(Vector.ofArrayCopy([1,2,3,4])), c = addr(someObject.someField), d = addr(someVar), {
			//a, b, c and d will all be typed here as Buffer
		});
		```
	**/
	macro public static function pin(exprs:Array<Expr>):Expr
	{
		var block = exprs.pop();
		var ret = [],
				afterFixed = [],
				beforeFixed = [];
		for (e in exprs)
		{
			switch(e)
			{
				case macro $i{name} = $v:
					var tmpCount = 0;
					var v = v;
					var allocname = name + "_" + (tmpCount++);
					{
						var targetType = null;
						v = switch(v.expr)
						{
							case ECall(macro addr,[v]):
								// store an actual reference to it
								var changed = switch (v.expr)
								{
									case EField(e1,f):
										beforeFixed.push({ name: allocname, type:null, expr: e1 });
										{ expr:EField(macro @:pos(e1.pos) $i{allocname}, f), pos: v.pos };
									case EConst(CIdent(i)):
										v;
									case _:
										throw new Error('Only fields and local variables can have their address extracted through `addr`', e.pos);
								};
								if (defined('cs'))
								{
									macro untyped __ptr__(__addressOf__($changed));
								} else if (defined('cpp')) {
									macro untyped __cpp__('&{0}',$changed);
								} else {
									// not available
									macro null;
								}
							case ECall(macro ptr, [v]):
								var t = typeof(v);
								beforeFixed.push({ name: allocname, type:null, expr:v });
								function getPointerType(t:haxe.macro.Type):ComplexType
								{
									var t = follow(t);
									var ret = switch(t)
									{
										case TAbstract(_.get() => a,_) if (a.meta.has(':coreType')):
											t.toComplexType();
										case _:
											throw new Error('Invalid array type: ${t.toString()}. Only arrays of basic types can have their addresses taken',v.pos);
									}
									return macro : indian._impl.PointerType<$ret>;
								}
								switch(follow(t))
								{
									case TInst(_.get() => { pack:[], name:'String' }, _):
										if (defined('cs'))
											macro (untyped __ptr__($i{allocname}) : indian.Buffer);
										else if (defined('cpp'))
											macro (untyped __cpp__("(unsigned char *) ({0}.__CStr())", $i{allocname}) : indian.Buffer);
										else
											macro (null : indian.Buffer); //not available
									case TInst(_.get() => { pack:[], name:'Array' }, [t]):
										var t = getPointerType(t);
										if (defined('cs'))
											macro ( untyped __ptr__($i{allocname}.__a) : $t );
										else if (defined('cpp'))
											macro (untyped __cpp__("(unsigned char *) ({0}->GetBase())", $i{allocname}) : indian.Buffer);
										else
											macro (null : indian.Buffer); //not available
									case TAbstract(_.get() => { pack:['haxe','ds'], name:'Vector' }, [t]):
										var t = getPointerType(t);
										if (defined('cs'))
											macro ( untyped __ptr__($i{allocname}) : $t );
										else if (defined('cpp'))
											macro (untyped __cpp__("(unsigned char *) ({0}->GetBase())", $i{allocname}) : indian.Buffer);
										else
											macro (null : indian.Buffer); //not available
									case TInst(_.get() => { pack:["cs"], name:'NativeArray' }, [t]):
										var t = getPointerType(t);
										macro ( untyped __ptr__($i{allocname}) : $t );
									case _:
										throw new Error('Invalid type used with `addr` for var `$name`',e.pos);
								}
							case _:
								throw new Error('`ptr` or `addr` expected inside a `pin` statement',e.pos);
						}
					}
					ret.push({ name:name + '_alloc', type:null, expr:v });
					afterFixed.push({ name:name, type:macro : indian.Buffer , expr:macro cast $i{name + '_alloc'} });
				case _:
					throw new Error('Invalid syntax for pin: Expected `varname = value`', e.pos);
			}
		}

		if (defined('cs') && ret.length > 0)
		{
			var fixedBlock = { expr:EBlock([{ expr:EVars(ret), pos:currentPos() }, { expr:EBlock([{ expr:EVars(afterFixed), pos:currentPos() }, block]), pos:currentPos() } ]), pos:currentPos() };
			var fixed = macro cs.Lib.fixed($fixedBlock);
			var exprs = [ { expr:EVars(beforeFixed), pos:currentPos() }, fixed ];
			var exprsBlock = { expr:EBlock(exprs), pos:currentPos() };
			// trace(exprsBlock.toString());
			return exprsBlock;
		} else {
			var exprs = [ { expr: EVars(beforeFixed), pos:currentPos() }, { expr:EVars(ret), pos:currentPos() }, { expr:EBlock([{ expr:EVars(afterFixed), pos:currentPos() }, block]), pos:currentPos() } ];
			var exprsBlock = { expr:EBlock(exprs), pos:currentPos() };
			return exprsBlock;
		}
	}

	/**
		This is a macro helper that takes multiple variable declarations and a code block.
		All variable declared this way will be automatically be freed at the end of the scope

		There are special identifiers that can be used in the variable declarations:
			- `alloc` is an alias to `Indian.alloc`; It will be automatically freed at the end of the scope
			- `stackalloc` is an alias to `Indian.stackalloc`; It will be automatically freed with `Indian.stackfree` at the end of the scope
		Please note that `stackfree` will only be used if `stackalloc` or `Indian.stackalloc` is called directly; otherwise `free` will be called instead

		example:
		```haxe
		Indian.autofree(a = alloc(10), b = stackalloc(20), c = getSomeBuffer(), {
			// all the declarations above will be automatically freed after the scope leaves the block.
			// even if an exception is thrown
		});
		```
	**/
	macro public static function autofree(exprs:Array<Expr>):Expr
	{
		var block = exprs.pop();
		var ret = [],
				toRelease = [];
		for (e in exprs)
		{
			switch(e)
			{
				case macro $i{name} = $v:
					var allocname = name + "_alloc";
					var isStack = false;
					function map(e:Expr)
					{
						return switch(e.expr)
						{
							case ECall(macro stackalloc,[v]):
								isStack = true;
								{ expr:ECall(macro indian.Indian.stackalloc, [v]), pos: e.pos };
							case ECall(macro indian.Indian.stackalloc,[v]),
									ECall(macro Indian.stackalloc,[v]):
								isStack = true;
								e;
							case ECall(macro alloc, [v]):
								{ expr: ECall(macro indian.Indian.alloc,[v]), pos:e.pos };
							case _:
								haxe.macro.ExprTools.map(e,map);
						}
					}
					var v = map(v);
					if (isStack)
					{
						toRelease.push(macro indian.Indian.stackfree($i{allocname}));
					} else {
						toRelease.push(macro indian.Indian.free($i{allocname}));
					}
					toRelease.push(macro $i{name} = null);
					toRelease.push(macro $i{allocname} = null);
					ret.push({ name:allocname, type:null, expr:v });
					ret.push({ name:name, type:null, expr:macro $i{allocname} });
				case _:
					throw new Error('Invalid syntax for autofree: Expected `varname = value`', e.pos);
			}
		}
		function getRelease(andExpr:Expr)
		{
			if (andExpr != null)
			{
				var rel = toRelease.copy();
				rel.push(andExpr);
				return { expr:EBlock(rel), pos: currentPos() };
			} else {
				return { expr:EBlock(toRelease), pos:currentPos() };
			}
		}

		var inLoop = false;
		function map(e:Expr)
		{
			return switch(e.expr)
			{
				case EReturn(_):
					getRelease(e.map(map));
				case EBreak | EContinue if (!inLoop):
					getRelease(e);
				case EWhile(_,_,_) if (!inLoop):
					inLoop = true;
					var ret =e.map(map);
					inLoop = false;
					ret;
				case EFor(_,_) if (!inLoop):
					inLoop = true;
					var ret = e.map(map);
					inLoop =false;
					ret;
				case _:
					e.map(map);
			}
		}
		block = map(block);
		var pos = currentPos();
		var ret = { expr:EVars(ret), pos:pos };
		var rethrow = if (defined('cs'))
			macro cs.Lib.rethrow(exception_);
		else if (defined('cpp'))
			macro cpp.Lib.rethrow(exception_);
		else if (defined('neko'))
			macro neko.Lib.rethrow(exception_);
		else
			macro throw exception_;
		var ret = macro { $ret; try {$block; ${getRelease(null)};} catch(exception_:Dynamic) { ${getRelease(null)}; $rethrow; } }
		// trace(ret.toString());
		return ret;
	}

}
