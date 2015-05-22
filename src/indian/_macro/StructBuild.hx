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

						var ret = getOrBuild([ for (f in fields) f.field ],cl.name);
						return ret;
					case _:
				}
			case _:
		}
		return getType('Dynamic');
	}

	private static function isStruct(t:Type)
	{
		return switch(follow(t))
		{
			case TAbstract(a,pl):
				var a2 = a.get();
				if (a2.meta.has(':structimpl'))
					true;
				else if (!a2.meta.has(':coreType'))
					isStruct(a2.type);
				else
					false;
			case _:
				false;
		}
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
		var typeName = 'indian.structs.' + buildname;
		var type = try getType(typeName) catch(e:String) { if (e.indexOf('Type not found') >= 0) null; else throw e; };
		if (type != null)
			return type;
		var supports = defined('cs') || defined('cpp');

		var cls = macro class {};
		var build = cls.fields;

		var tdefDecl = tryGetDeclaringTypedef(),
		    hasTdef = tdefDecl != null;
		if (tdefDecl == null)
			tdefDecl = { pack:['indian','structs'], name: buildname };
		else
			tdefDecl.name = '__Strt_' + tdefDecl.name;
		if (tdefDecl.pack.length == 0)
			tdefDecl.pack = ['indian','structs'];


		// inline function add(def:TypeDefinition) for (f in def.fields) { var pos = getPosInfos(f.pos); pos.file += tdefDecl.name + "-" + f.name; f.pos = makePosition(pos);  build.push(f); }
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

		var thisType = TPath({ pack:tdefDecl.pack, name:tdefDecl.name }),
				thisPtr = macro : indian.Ptr<$thisType>;
		var complexTypes = [];
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

			var isstr = isStruct(i.field.type);
			var type = i.field.type.toComplexType(),
					ptrget = 'ptr_get_${name}', ptrset = 'ptr_set_$name';
			if (isstr)
			{
				type = TPath({ pack:["indian"], name:"Ptr", params: [TPType(type)] });
			}
			complexTypes.push({ name:name, t: type });
			var get = 'get${i.layout.type}', set = 'set${i.layout.type}';
			add(macro class {
				@:analyzer(no_simplification)
				public static var $off(get,never):Int;
				@:extern inline private static function $offget():Int
					return ${getOffset(macro 1)};

				@:analyzer(no_simplification)
				@:extern inline public static function $ptrget(ptr:$thisPtr):$type
					return ${getExpr([
						'cs' => (isstr ?
								macro untyped __cs__('&({0})', @:privateAccess ptr.t().acc.$name) :
								macro @:privateAccess ptr.t().acc.$name),
						'cpp' => (isstr ?
							macro untyped __cpp__($v{'&({0}->get_ref().$name)'}, ptr) :
							macro @:privateAccess ptr.t().ref.$name),
						'default' => (isstr ?
							macro @:privateAccess ptr.t() + ${getOffset(macro 1)} :
							macro @:privateAccess ptr.t().$get(${getOffset(macro 1)}))
					])};

				@:analyzer(no_simplification)
				@:extern inline public static function $ptrset(ptr:$thisPtr, val:$type):Void
					${getExpr([
						'cs' => (isstr ?
								macro @:privateAccess ptr.t().acc.$name = untyped __cs__('*{0}',val) :
								macro @:privateAccess ptr.t().acc.$name = val),
						'cpp' => (isstr ?
								macro untyped __cpp__($v{'{0}->get_ref().$name = *({1})'},ptr,val) :
								macro untyped __cpp__($v{'{0}->get_ref().$name = {1}'},ptr,val)),
						'default' => (isstr ?
							macro throw 'Not implemented' :
							// macro (@:privateAccess ptr.t() + ${getOffset(macro 1)}).,val) :
							macro @:privateAccess ptr.t().$set(${getOffset(macro 1)},val))
					])};
			});

			agg.add(i.layout);
		}


		var underlying = getUnderlying(fields,tdefDecl.pack,tdefDecl.name);
		if (supports)
		{
			var name = null, pack = null;

			switch (underlying) {
				case TPath(p):
					name = p.name;
					pack = p.pack;
				case _: throw 'assert';
			};
			var t = Context.parse(pack.join('.') + '.' + name, currentPos());
			add(macro class {
				@:extern public inline function new()
					this = ${getExpr([
						'cs' => macro null,
						'cpp' => macro $t.create()
				])};
			});
		}

		agg.alignAsPointer();
		var size = agg.expand('ptr',build);
		add(macro class {
			public static var bytesize(get,never):Int;
			@:extern inline private static function get_bytesize():Int
				return ${size(macro 1)};
		});

		var offsets = agg.offsets();
		agg.end();
		var sizes = agg.offsets(),
				aligns = agg.getAligns();

		cls.pack = tdefDecl.pack;
		cls.name = tdefDecl.name;
		cls.kind = TDAbstract(underlying);
		cls.meta = [ for (name in [':dce',':structimpl',':extern']) { name:name, params:[], pos:currentPos() } ];
		cls.meta.push({ name:':structsize',  params:[for (s in sizes) macro $v{s}],  pos:currentPos() });
		cls.meta.push({ name:':structalign', params:[for (a in aligns) macro $v{a}], pos:currentPos() });
		cls.meta.push({ name:':structfields',params:[for (a in complexTypes) { var t = a.t; macro ($v{a.name} : $t); }], pos:currentPos() });

		// for (f in cls.fields)
		// {
		// 	switch(f.kind)
		// 	{
		// 		case FFun(fn):
		// 			trace({ expr:EFunction(f.name,fn), pos:currentPos() }.toString(),f.access);
		// 		case _:
		// 			trace(f.name,f.access);
		// 	}
		// }
		defineType(cls);

		if (hasTdef)
		{
			defineType({
				pack:['indian','structs'],
				name: buildname,
				pos: currentPos(),
				fields: [],
				kind: TDAlias(TPath({ pack:tdefDecl.pack, name:tdefDecl.name }))
			});
		}

		return getType(typeName);
	}

	private static function getUnderlying(fields:Array<ClassField>, pack:Array<String>, name:String):ComplexType
	{
		if (defined('cs'))
		{
			var def = indian._macro.cs.StructBuilder.build(name,pack,fields,currentPos());
			defineType(def);
			return TPath({ pack:def.pack, name:def.name });
		} else if (defined('cpp')) {
			var defs = indian._macro.cpp.StructBuilder.build(name,pack,fields,currentPos());
			for (def in defs)
				defineType(def);
			return TPath({ pack:defs[0].pack, name:defs[0].name });
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

