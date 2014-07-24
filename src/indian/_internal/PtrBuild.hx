package indian._internal;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.*;

using haxe.macro.Tools;

class PtrBuild
{
	public static function build():Type
	{
		return switch getLocalType() {
			case TInst(_, [t]):
				createType(t, currentPos());
			case _:
				throw "assert";
		}
	}

	private static function createType(t:Type, pos:Position):Type
	{
		while(true)
		{
			inline function recurse(withType:Type) { t = withType; continue; }

			switch(t) {
				case TMono(tmono):
					var t2 = tmono.get();
					if (t2 == null)
						throw new Error('Cannot create pointer on unknown type',pos);
					recurse(t2);
				case TAbstract(abs,tl):
					var a = abs.get();
					switch [a.pack, a.name, a.impl == null] {
						case [ [], 'Int', _ ]:
							//
						case [ [], 'Float', _ ]:
						case _:
					}
				case TDynamic(_):
					return getOrBuild(['indian','_internal'],'Void',0,null);
				case _:
			}
			return t;
		}
	}

	private static function getOrBuild(pack:Array<String>, name:String, size:Int, derefType:Type):Type
	{
		var ret = getType(pack.join('.') + (pack.length == 0 ? name : "." + name)),
				realPointerType = getType('indian.unsafe.UnsafePointer');
		if (ret != null)
			return ret;
		//build here
		return null;
	}
}
