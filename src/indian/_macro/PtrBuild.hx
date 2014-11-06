package indian._macro;
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
			case TInst(_.get() => cl, [t]):
				var suffix = switch [ cl.pack, cl.name ] {
					case [ ["indian"], "Ptr" ]:
					case [ ["indian"], "HeapPtr" ]:
						'_Heap';
					case _:
						throw new Error('Invalid local build type: ${cl.pack.join(".")}.${cl.name}',currentPos());
				}
				var basename = checkOrCreate(t,currentPos());

			case _:
				throw "assert";
		}
	}

	private static function checkOrCreate(t:Type, pos:Position):String
	{
		while(true)
		{
			inline function recurse(withType:Type) { t = withType; continue; }

			switch(t) {
				case TMono(tmono) if (tmono != null):
					recurse(tmono.get());
				case TMono(_):
					throw new Error('Cannot create pointer of unknown type',pos);
				case TAbstract(abs,tl):
					var a = abs.get();
					switch [a.pack, a.name, a.meta.has(':coreType')] {
						case [ [], 'Int', true ]:
							return getOrBuild(a.pack,a.name,4,t);
						case [ [], 'Float', true ]:
							return getOrBuild(a.pack,a.name,8,t);
						case _:
					}
				case TDynamic(_):
					getType('indian.types.AnyPointer');
				case TInst(_.get() => { kind : KTypeParameter(_) }, _):
					return getType('Dynamic');
				case _:
			}
			return t;
		}
	}

	private static function getOrBuild(pack:Array<String>, name:String, size:Int, derefType:Type, pos:Position):String
	{
		var ret = getType(pack.join('.') + (pack.length == 0 ? name : "." + name)),
				realPointerType = getType('indian.unsafe.UnsafePointer');
		if (ret != null)
			return ret;
		//build here
		return null;
	}
}
