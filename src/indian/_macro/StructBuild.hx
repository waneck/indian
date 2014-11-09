package indian._macro;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.*;
import indian._macro.BuildHelper.*;

using haxe.macro.Tools;

class StructBuild
{
	public static function build():Type
	{
		switch (getLocalType())
		{
			case TInst(_.get() => cl,[t]):
				switch(follow(t))
				{
					case TAnonymous(_.get() => a) if (a.fields.length > 0):
						var fields = [for (f in a.fields) { field:f, pos:getPosInfos(f.pos) } ];
						var file = fields[0].pos.file;
						var msg = "Cannot determine the fields' position. Were the struct's fields procedurally generated? If so, make sure that they don't have overlapping positions and different file declaration positions. The struct layout is determined by the position order";
						for (f in fields)
						{
							if (f.pos.file != file)
								throw new Error(msg,f.field.pos);
							for (f2 in fields)
							{
								if (f == f2) continue;
								var min = f.pos.min > f2.pos.min ? f.pos.min : f2.pos.min,
										max = f.pos.max < f2.pos.max ? f.pos.max : f2.pos.max;
								if (min < max)
								{
									//intersects
									warning(msg,f.field.pos);
									throw new Error(msg,f2.field.pos);
								}
							}
						}
						fields.sort(function(v1,v2) return Reflect.compare(v1.pos.min,v2.pos.min));

						return getOrBuild([ for (f in fields) f.field ],cl.name);
					case _:
				}
			case _:
		}
		return getType('Dynamic');
	}

	private static function getOrBuild(fields:Array<ClassField>, type:String)
	{
		var infos = [ for (f in fields) fieldInfo(f) ];
		var buf = new StringBuf();
		for (i in infos)
			buf.add(i.mangled);
		var union = false;
		var prefix = switch (type) {
			case 'Struct':
				'S';
			case 'Union':
				union = true;
				'U';
			case _: throw new Error('Invalid genericBuild type name $type',currentPos());
		};
		var buildname = prefix + buf.toString();
		trace(buildname);
		var typeName = 'indian.structs.' + buildname;
		var type = try getType(typeName) catch(e:String) { if (e.indexOf('Type not found') >= 0) null; else throw e; };
		if (type != null)
			return type;
		var supports = defined('cs') || defined('cpp');

		var cls = macro class {};
		var build = cls.fields;

		inline function add(def:TypeDefinition) for (f in def.fields) build.push(f);
		function getExpr(map:Map<String,Expr>)
		{
			if (defined('neko'))
				return map.exists('neko') ? map['neko'] : map['default'];
			else if (defined('cs'))
				return map.exists('cs') ? map['cs'] : map['default'];
			else if (defined('java'))
				return map.exists('java') ? map['java'] : map['default'];
			else if (defined('cpp'))
				return map.exists('cpp') ? map['cpp'] : map['default'];
			else throw 'assert';
		}

		var thisType = TPath({ pack:['indian','structs'], name:buildname }),
				thisPtr = macro : indian.Ptr<$thisType>;
		var agg = new LayoutAgg();
		for (i in infos)
		{
			if (union) agg.reset();
			agg.align(i.layout);

			var name = i.field.name;
			if (supports)
			{
				var t = i.field.type.toComplexType(),
						get = 'get_$name', set = 'set_$name';
				add(macro class {
					public var $name(get,set) : $t;
					@:extern inline public function $get() : $t
						return this.$name;
					@:extern inline public function $set(v:$t) : $t
						return this.$name = v;
				});
			}
			var fun = i.layout.type;
			var getOffset = agg.expand('ptr_$name', build);

			var off = 'offset_${name}', offget = 'get_$off';
			var type = i.field.type.toComplexType(),
					ptrget = 'ptr_get_${name}', ptrset = 'ptr_set_$name';
			var get = 'get${i.layout.type}', set = 'set${i.layout.type}';
			add(macro class {
				public static var $off(get,never):Int;
				@:extern inline private static function $offget():Int
					return ${getOffset(macro 1)};

				@:extern inline public static function $ptrget(ptr:$thisPtr):$type
					return ${getExpr([
						'cs' => macro ptr.acc.$name,
						'cpp' => macro ptr.ref.$name,
						'default' => macro @:privateAccess ptr.t().$get(${getOffset(macro 1)})
					])};

				@:extern inline public static function $ptrset(ptr:$thisPtr, val:$type):Void
					${getExpr([
						'cs' => macro ptr.acc.$name = val,
						'cpp' => macro ptr.ref.$name = val,
						'default' => macro @:privateAccess ptr.t().$set(${getOffset(macro 1)},val)
					])};
			});

			agg.add(i.layout);
		}

		var size = agg.expand('ptr',build);
		add(macro class {
			public static var bytesize(get,never):Int;
			@:extern inline private static function get_bytesize():Int
				return ${size(macro 1)};
		});

		cls.pack = ['indian','structs'];
		cls.name = buildname;
		cls.kind = TDAbstract(getUnderlying(fields,buildname));
		cls.meta = [ for (name in [':dce',':structimpl',':extern']) { name:name, params:[], pos:currentPos() } ];

		for (f in cls.fields)
		{
			switch(f.kind)
			{
				case FFun(fn):
					trace({ expr:EFunction(f.name,fn), pos:currentPos() }.toString(),f.access);
				case _:
					trace(f.name,f.access);
			}
		}
		defineType(cls);

		return getType(typeName);
	}

	private static function getUnderlying(fields:Array<ClassField>, name:String):ComplexType
	{
		if (defined('cs'))
		{
			var def = indian._macro.cs.StructBuilder.build(name,fields,currentPos());
			defineType(def);
			return TPath({ pack:def.pack, name:def.name });
		} else {
			return macro : indian.Buffer;
		}
	}

	private static function fieldInfo(field:ClassField):{ mangled:String, field:ClassField, layout:Layout }
	{
		var original = field.type;
		var layout = Layout.fromType(original,field.pos);
		if (layout == null)
			return null;
		return { mangled:field.name + BuildHelper.shortType(layout.pack,layout.name), field:field, layout:layout };
	}
}

