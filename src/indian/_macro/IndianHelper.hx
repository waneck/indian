package indian._macro;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Context.*;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;

class IndianHelper
{

	public static function stackalloc(bytesLength:Expr):Expr
	{
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

	public static function pin(exprs:Array<Expr>, strict:Bool):Expr
	{
		var block = exprs.pop();
		var ret = [],
				afterFixed = [],
				beforeFixed = [],
				toRelease = [];
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
							case ECall({ expr: EConst(CIdent("$addr")) },[v]):
								// store an actual reference to it
								var changed = switch (v.expr)
								{
									case EField(e1,f):
										beforeFixed.push({ name: allocname, type:null, expr: e1 });
										{ expr:EField(macro @:pos(e1.pos) $i{allocname}, f), pos: v.pos };
									case EConst(CIdent(i)):
										v;
									case _:
										throw new Error('Only fields and local variables can have their address extracted through `$$addr`', e.pos);
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
							case ECall({ expr: EConst(CIdent("$ptr")) }, [v]):
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
										else if (!strict) {
											if (!defined('neko'))
												toRelease.push(macro if ($i{name + "_alloc"} != null) indian.Indian.free($i{name + "_alloc"}));
											macro indian._impl.PinHelper.string($i{allocname});
										} else
											macro (null : indian.Buffer); //not available
									case TInst(_.get() => { pack:[], name:'Array' }, [t]):
										var t = getPointerType(t);
										if (defined('cs'))
											macro ( untyped __ptr__($i{allocname}.__a) : $t );
										else if (defined('cpp'))
											macro (untyped __cpp__("(unsigned char *) ({0}->GetBase())", $i{allocname}) : indian.Buffer);
										else if (!strict) {
											toRelease.push(macro if ($i{name + "_alloc"} != null) indian.Indian.free($i{name + "_alloc"}));
											macro indian._impl.PinHelper.array($i{allocname});
										} else
											macro (null : indian.Buffer); //not available
									case TAbstract(_.get() => { pack:['haxe','ds'], name:'Vector' }, [t]):
										var t = getPointerType(t);
										if (defined('cs'))
											macro ( untyped __ptr__($i{allocname}) : $t );
										else if (defined('cpp'))
											macro (untyped __cpp__("(unsigned char *) ({0}->GetBase())", $i{allocname}) : indian.Buffer);
										else if (!strict) {
											toRelease.push(macro if ($i{name + "_alloc"} != null) indian.Indian.free($i{name + "_alloc"}));
											macro indian._impl.PinHelper.vector($i{allocname});
										} else
											macro (null : indian.Buffer); //not available
									case TInst(_.get() => { pack:[ ("cs" | "java" | "neko")], name:'NativeArray' }, [t]):
										var t = getPointerType(t);
										if (defined('cs'))
											macro ( untyped __ptr__($i{allocname}) : $t );
										else if (!strict) {
											toRelease.push(macro if ($i{name + "_alloc"} != null) indian.Indian.free($i{name + "_alloc"}));
											macro indian._impl.PinHelper.vector(haxe.ds.Vector.ofData($i{allocname}));
										} else
											macro (null : indian.Buffer); //not available
									case _:
										throw new Error('Invalid type used with `$$addr` for var `$name`',e.pos);
								}
							case _:
								throw new Error('`$$ptr` or `$$addr` expected inside a `pin` statement',e.pos);
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
			if (toRelease.length > 0) throw 'assert';
			var fixedBlock = { expr:EBlock([{ expr:EVars(ret), pos:currentPos() }, { expr:EBlock([{ expr:EVars(afterFixed), pos:currentPos() }, block]), pos:currentPos() } ]), pos:currentPos() };
			var fixed = macro cs.Lib.fixed($fixedBlock);
			var exprs = [ { expr:EVars(beforeFixed), pos:currentPos() }, fixed ];
			var exprsBlock = { expr:EBlock(exprs), pos:currentPos() };
			// trace(exprsBlock.toString());
			return exprsBlock;
		} else {
			if (toRelease.length > 0)
				block = mkRelease(toRelease,block);
			var exprs = [ { expr: EVars(beforeFixed), pos:currentPos() }, { expr:EVars(ret), pos:currentPos() }, { expr:EBlock([{ expr:EVars(afterFixed), pos:currentPos() }, block]), pos:currentPos() } ];
			var exprsBlock = { expr:EBlock(exprs), pos:currentPos() };
			return exprsBlock;
		}

	}

	public static function autofree(exprs:Array<Expr>):Expr
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
							case ECall({ expr:EConst(CIdent("$stackalloc")) },[v]):
								isStack = true;
								{ expr:ECall(macro indian.Indian.stackalloc, [v]), pos: e.pos };
							case ECall(macro indian.Indian.stackalloc,[v]),
									ECall(macro Indian.stackalloc,[v]):
								isStack = true;
								e;
							case ECall({ expr:EConst(CIdent("$alloc")) }, [v]):
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

		var ret = { expr:EVars(ret), pos:currentPos() };
		var rel = mkRelease(toRelease, block);
		return macro { $ret; $rel; };
	}

	private static function mkRelease(toRelease:Array<Expr>, block:Expr)
	{
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
		var rethrow = if (defined('cs'))
			macro cs.Lib.rethrow(exception_);
		else if (defined('cpp'))
			macro cpp.Lib.rethrow(exception_);
		else if (defined('neko'))
			macro neko.Lib.rethrow(exception_);
		else
			macro throw exception_;
		return macro try {$block; ${getRelease(null)};} catch(exception_:Dynamic) { ${getRelease(null)}; $rethrow; };
	}

}
