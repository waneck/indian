package indian._macro;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.*;

using haxe.macro.Tools;
using StringTools;

@:forward abstract Layout(LayoutData) from LayoutData
{
	public static var platforms(default,null) = ['win32','win64','nix32','nix64'];
	private static function mklayouts(map:Map<String,{ nbytes:Int, align:Int }>)
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

	private static function getObjectDecl(arr:Array<Expr>):Map<String,Int>
	{
		var ret = new Map();
		for (a in arr)
		{
			switch(a.expr)
			{
				case EObjectDecl(decl):
					var name = null,
							value = null;
					for (d in decl)
					{
						if (d.field == "name") name = d.expr;
						else if (d.field == "value") value = d.expr;
					}
					if (name == null || value == null) throw 'assert';
					switch [name.expr, value.expr] {
						case [EConst(CString(name)), EConst(CInt(val))]:
							ret[name] = Std.parseInt(val);
						case _:
							throw 'assert';
					}
				case _:
					trace(a.toString());
					throw 'assert';
			}
		}
		return ret;
	}

	private static function structLayout(m:MetaAccess)
	{
		var metas = [ for (p in platforms) p => {name:p, nbytes:0,align:p.endsWith('64') ? 8 : 4} ];
		for (meta in m.get())
		{
			switch (meta.name)
			{
				case ':structsize':
					var decl = getObjectDecl(meta.params);
					for (k in decl.keys()) metas[k].nbytes = decl[k];
				case ':align':
					var decl = getObjectDecl(meta.params);
					for (k in decl.keys()) metas[k].align = decl[k];
				case _:
			}
		}
		return [ for (m in metas) m ];
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
							return { type:'Int32', pack:[], name:a.name, layouts:layout(4,4), followedType:t };
						case [ [], 'Float', true ]:
							return { type:'Float64', pack:[], name:a.name, layouts:mklayouts(['default'=>{nbytes:8,align:8}, 'nix32'=>{nbytes:8,align:4}]), followedType:t };
						case [ [], 'Single', true ]:
							return { type:'Float32', pack:[], name:a.name, layouts:layout(4,4), followedType:t };
						case [ [], 'Bool', true ]:
							return { type:'Bool', pack:[], name:a.name, layouts:layout(1,1), followedType:t };
						case [ [], 'Dynamic', true ]:
							return null;
						case [ _, _, true ]:
							throw new Error('Unrecognized native type ${a.pack.join('.')}.${a.name}. Please use the `indian.types` package for using standardized basic types',pos);
						case [ ['indian','types'], 'UInt8', false ]:
							return { type:'UInt8', pack:[], name:a.name, layouts:layout(1,1), followedType:t };
						case [ ['indian','types'], 'UInt16', false ]:
							return { type:'UInt16', pack:[], name:a.name, layouts:layout(2,2), followedType:t };
						case [ ['indian','types'], 'Int64', false ]:
							return { type:'Int64', pack:[], name:a.name, layouts:mklayouts(['default'=>{nbytes:8,align:8}, 'nix32'=>{nbytes:8,align:4}]), followedType:t };
						case [ _, _, false ] if (a.meta.has(':structimpl')):
							var fields = [];
							for (m in a.meta.get()) switch(m.name) {
								case ':structfields':
									for (p in m.params)
									{
										switch (p)
										{
											case macro ( $s : $t ): switch(s.expr) {
													case EConst(CString(s)):
														fields.push({ field:s, type:t });
													case _:
														throw 'assert';
												}
											case _: throw 'assert';
										}
									}
								case _:
							}
							return { type:'Pointer', pack:a.pack, name:a.name, layouts:structLayout(a.meta), structFields:fields, followedType:t };
						case [ _, _, false ] if (a.meta.has(':pointer')):
							return { type:'Pointer', pack:a.pack, name:a.name, layouts:mklayouts([
								'nix32'=>{nbytes:4,align:4},
								'nix64'=>{nbytes:8,align:8},
								'win32'=>{nbytes:4,align:4},
								'win64'=>{nbytes:8,align:8},
							]), followedType:t };
						case [ _, _, false ]:
							recurse(a.type);
					}
				case TType(_.get() => tdef,tl):
					switch [tdef.pack, tdef.name ] {
						case [ ['indian','types'], 'Single' ]:
							return { type:'Float32', pack:[], name:tdef.name, layouts:layout(4,4), followedType:t };
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

typedef LayoutData = { type:String, name:String, pack:Array<String>, layouts:Array<{ name:String, nbytes:Int, align:Int }>, ?structFields:Array<{ field:String, type:ComplexType }>, followedType:Type };
