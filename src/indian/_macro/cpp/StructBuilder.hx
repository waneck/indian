package indian._macro.cpp;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.*;
import indian._macro.BuildHelper.*;

using haxe.macro.Tools;

class StructBuilder
{
	var name:String;
	var fields:Array<ClassField>;
	var pos:Position;
	public function new(name:String, fields:Array<ClassField>, pos)
	{
		this.name = name;
		this.fields = fields;
		this.pos = pos;
	}

	public function tdef():Array<TypeDefinition>
	{
		return [getExtern(), getBoxed()];
	}

	private static function typeToCpp(t:Type)
	{
		return switch(follow(t)) {
			case TAbstract(_.get() => cl,p):
				var pack = cl.pack, name = cl.name;
				var ret = clsString(pack,name, cl.meta.has(':coreType'));
				if (ret == null)
					return typeToCpp(cl.type);
				ret;
			case TInst(_.get() => cl,p):
				var pack = cl.pack, name = cl.name;
				var ret = clsString(pack,name,true);
				switch [pack,name] {
					case [['cpp'],'Pointer']
					   | [['cpp'],'ConstPointer']
					   | [['cpp'],'RawPointer']
					   | [['cpp'],'RawConstPointer']:
						 ret + '<' + [ for (p in p) typeToCpp(p) ].join(',') + '>';
					case _:
							ret;
				}
			case TEnum(_.get() => cl,p):
				var pack = cl.pack, name = cl.name;
				clsString(pack,name,true);
			case _:
				return 'Dynamic';
		}
	}

	private static function clsString(pack:Array<String>, name:String, isFinal:Bool)
	{
		return switch [pack, name] {
			case [ [], 'Int' ]:
				'int';
			case [ [], 'Float' ]:
				'Float';
			case [ [], 'Bool' ]:
				'bool';
			case _ if (isFinal):
				'::' + pack.join('::') + (pack.length == 0 ? '' : '::') + name;
			case _:
				null;
		}
	}

	function getBoxed()
	{
		var thisType = TPath({ pack:['indian','structs'], name:'D'+name });
		var def = macro class {
			private var data__ : $thisType;
			public function new(data)
			{
				this.data__ = data;
			}
		};
		var thisType = clsString(['indian','structs'],'D' + name,true);
		var boxType = clsString(['indian','structs'],'B' + name,true);
		def.meta = [ for (name in [':keep']) { name:name, params:[], pos:pos } ];
		var metas = [{
			name: ':headerNamespaceCode',
			param: '
				class D$name;
				extern "C" {
					$thisType istruct_${name}_unbox(Dynamic d);
					Dynamic istruct_${name}_box($thisType t);
				}
				class D$name
				{
					public:
						inline operator Dynamic () const { return istruct_${name}_box(*this); }
						D$name(Dynamic val) { $thisType t = istruct_${name}_unbox(val); ${ [ for (field in fields) 'this->${field.name} = t.${field.name};' ].join('') } }
						D$name() {}

						${[ for (field in fields) typeToCpp(field.type) + ' ' + field.name + '; '].join('')}
				};
			',
		}, {
			name: ':cppFileCode',
			param: '
				extern "C" {
				$thisType istruct_${name}_unbox(Dynamic d)
				{
					$boxType b = d;
					return b == null() ? $thisType() : b->data__;
				}

				Dynamic istruct_${name}_box($thisType t)
				{
					return ${boxType}_obj::__new(t);
				}
				}
			'
		}];
		for (meta in metas)
		{
			def.meta.push({ name:meta.name, params:[macro $v{meta.param}], pos:pos });
		}
		def.pack = ['indian','structs'];
		def.name = "B" + name;
		def.pos = pos;

		return def;
	}

	function getExtern()
	{
		var thisTypeStr = clsString(['indian','structs'],'D' + name,true);
		var thisType = TPath({ pack:['indian','structs'], name:'D'+name });
		var def = macro class {
			@:extern static inline function create():$thisType
			{
				var ret:$thisType = untyped __cpp__($v{ thisTypeStr + "()" });
				return ret;
			}
		};
		var newArgs = [], newExpr = [];
		for (f in fields)
		{
			var name = f.name;
			newArgs.push({ name:f.name, type:null, opt:false, value:null });
			var expr = macro this.$name = $i{name};
			expr.pos = f.pos;
			newExpr.push(expr);

			def.fields.push({
				name:name,
				kind:FVar(f.type.toComplexType()),
				access:[APublic],
				pos:f.pos
			});
		}
		var block = { expr:EBlock(newExpr), pos:pos };
		def.isExtern = true;
		def.meta = [ for (name in [':unreflective',':structAccess']) { name:name, params:[], pos:pos } ];
		def.meta.push({ name:':include', params:[macro $v{ 'indian/structs/B' + name + '.h' }], pos:pos });
		def.pack = ['indian','structs'];
		def.name = "D" + name;
		def.pos = pos;

		return def;
	}

	static public function build(name,fields,pos)
	{
		return new StructBuilder(name,fields,pos).tdef();
	}
}
