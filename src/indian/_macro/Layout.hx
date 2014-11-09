package indian._macro;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.*;

@:forward abstract Layout(LayoutData) from LayoutData
{
	public static var platforms(default,null) = ['win32','win64','nix32','nix64'];
	private static function layouts(map:Map<String,{ nbytes:Int, align:Int }>)
	{
		var ret = [];
		for (p in platforms)
		{
			var m = map[p];
			if (m == null)
				m = map['default'];
			if (m == null) throw 'assert';
			ret.push({ name:p, nbytes:m.nbytes, align:m.align });
		}
		return ret;
	}

	private static function layout(nbytes:Int, align:Int)
	{
		var ret = [];
		for (p in platforms)
		{
			ret.push({name:p, nbytes:nbytes, align:align});
		}
		return ret;
	}

	public static function fromType(t:Type,pos:Position):Null<Layout>
	{
		while(true)
		{
			inline function recurse(withType:Type) { t = withType; continue; }

			switch(t) {
				case TMono(tmono) if (tmono != null):
					recurse(tmono.get());
				case TMono(_):
					throw new Error('Cannot create Struct with field with unknown type',pos);
				case TAbstract(abs,tl):
					var a = abs.get();
					switch [a.pack, a.name, a.meta.has(':coreType')] {
						case [ [], 'Int', true ]:
							return { type:'Int32', pack:[], name:a.name, layouts:layout(4,4) };
						case [ [], 'Float', true ]:
							return { type:'Float64', pack:[], name:a.name, layouts:layouts(['default'=>{nbytes:8,align:8}, 'nix32'=>{nbytes:8,align:4}]) };
						case [ [], 'Single', true ]:
							return { type:'Float32', pack:[], name:a.name, layouts:layout(4,4) };
						case [ [], 'Bool', true ]:
							return { type:'Bool', pack:[], name:a.name, layouts:layout(1,1) };
						case [ [], 'Dynamic', true ]:
							return null;
						case [ _, _, true ]:
							throw new Error('Unrecognized native type ${a.pack.join('.')}.${a.name}. Please use the `indian.types` package for using standardized basic types',pos);
						case [ ['indian','types'], 'UInt8', false ]:
							return { type:'UInt8', pack:[], name:a.name, layouts:layout(1,1) };
						case [ ['indian','types'], 'UInt16', false ]:
							return { type:'UInt16', pack:[], name:a.name, layouts:layout(2,2) };
						case [ ['indian','types'], 'Int64', false ]:
							return { type:'Int64', pack:[], name:a.name, layouts:layout(8,8) };
						case [ _, _, false ] if (a.meta.has(':pointer')):
							return { type:'Pointer', pack:a.pack, name:a.name, layouts:layouts([
								'nix32'=>{nbytes:4,align:4},
								'nix64'=>{nbytes:8,align:8},
								'win32'=>{nbytes:4,align:4},
								'win64'=>{nbytes:8,align:8},
							]) };
						case [ _, _, false ]:
							recurse(a.type);
					}
				case TType(_.get() => tdef,tl):
					switch [tdef.pack, tdef.name ] {
						case [ ['indian','types'], 'Single' ]:
							return { type:'Float32', pack:[], name:tdef.name, layouts:layout(4,4) };
						case _:
							recurse(follow(t,true));
					}
				case TDynamic(_):
					//TODO
					return null;
				case TInst(_.get() => { kind : KTypeParameter(_) }, _):
					return null;
				case TAnonymous(_):
					throw new Error('A managed (anonymous) type cannot be directly referenced by unmanaged code. Are you missing another `Struct` definition?', pos);
				case _:
					throw new Error('Still unsupported type : $t',pos);
			}
			throw 'assert';
		}
	}
}

typedef LayoutData = { type:String, name:String, pack:Array<String>, layouts:Array<{ name:String, nbytes:Int, align:Int }> };
