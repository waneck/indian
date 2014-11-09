package indian._macro.cs;
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

	public function tdef():TypeDefinition
	{
		var def = macro class {
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
		def.fields.push({ name:'new', kind:FFun({ args:newArgs, ret:null, expr:block }), access:[APublic], pos:pos });
		def.meta = [ for (name in [':keep',':struct',':nativeGen']) { name:name, params:[], pos:pos } ];
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
