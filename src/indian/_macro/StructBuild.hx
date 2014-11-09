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
		var offset32 = 0,
				offset64 = 0;
		for (i in infos)
		{
			if (union) { offset32 = 0; offset64 = 0; } //always zero the offset on unions
			// first align the offset
			if (i.nbytes < 0) // pointer
			{
				offset32 = align(4,4,offset32);
				offset64 = align(8,8,offset64);
			} else {
				offset32 = align(i.nbytes,i.alignment,offset32);
				offset64 = align(i.nbytes,i.alignment,offset64);
			}

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
			var off = 'offset_${name}', offget = 'get_$off';
			var expr = offset32 == offset64 ? macro $v{offset32} : macro (indian.Infos.is64) ? $v{offset64} : $v{offset32};
			var type = i.field.type.toComplexType(),
					ptrget = 'ptr_get_${name}', ptrset = 'ptr_set_$name';
			var get = 'get${i.fun}', set = 'set${i.fun}';
			add(macro class {
				public static var $off(get,never):Int;
				@:extern inline private static function $offget():Int
					return $expr;

				@:extern inline public static function $ptrget(ptr:$thisPtr):$type
					return ${getExpr([
						'cs' => macro ptr.acc.$name,
						'cpp' => macro ptr.ref.$name,
						'default' => macro @:privateAccess ptr.t().$get($i{off})
					])};

				@:extern inline public static function $ptrset(ptr:$thisPtr, val:$type):Void
					${getExpr([
						'cs' => macro ptr.acc.$name = val,
						'cpp' => macro ptr.ref.$name = val,
						'default' => macro @:privateAccess ptr.t().$set($i{off},val)
					])};
			});

			if (i.nbytes < 0)
			{
				offset32 += 4;
				offset64 += 4;
			} else {
				offset32 += i.nbytes;
				offset64 += i.nbytes;
			}
		}
		var size = (offset32 == offset64) ? macro $v{offset32} : macro indian.Infos.is64 ? $v{offset64} : $v{offset32};
		add(macro class {
			public static var bytesize(get,never):Int;
			@:extern inline private static function get_bytesize():Int
				return $size;
		});

		cls.pack = ['indian','structs'];
		cls.name = buildname;
		cls.kind = TDAbstract(getUnderlying(fields,buildname));
		cls.meta = [ for (name in [':dce',':structimpl',':extern']) { name:name, params:[], pos:currentPos() } ];

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

	private static function fieldInfo(field:ClassField):{ mangled:String, fun:String, nbytes:Int, alignment:Int, field:ClassField }
	{
		inline function retval(pack,name,fun,nbytes,alignment) return { mangled:field.name + BuildHelper.shortType(pack,name), fun:fun, nbytes:nbytes, alignment:alignment, field:field };
		var pos = field.pos;
		var t = field.type;
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
							return retval([],a.name,'Int32',4,4);
						case [ [], 'Float', true ]:
							return retval([],a.name,'Float64',8,8);
						case [ [], 'Single', true ]:
							return retval([],a.name,'Float32',4,4);
						case [ [], 'Bool', true ]:
							return retval([],a.name,'Bool',1,1);
						case [ [], 'Dynamic', true ]:
							return null;
							//TODO
							// return getType('indian.AnyPtr');
						case [ _, _, true ]:
							throw new Error('Unrecognized native type ${a.pack.join('.')}.${a.name}. Please use the `indian.types` package for using standardized basic types',pos);
						case [ ['indian','types'], 'UInt8', false ]:
							return retval([],a.name,'UInt8',1,1);
						case [ ['indian','types'], 'UInt16', false ]:
							return retval([],a.name,'UInt16',2,2);
						case [ ['indian','types'], 'Int64', false ]:
							return retval([],a.name,'Int64',8,8);
						case [ _, _, false ] if (a.meta.has(':pointer')):
							return retval(a.pack,a.name,'Pointer',-1,-1);
						case [ _, _, false ]:
							recurse(a.type);
					}
				case TType(_.get() => tdef,tl):
					switch [tdef.pack, tdef.name ] {
						case [ ['indian','types'], 'Single' ]:
							return retval([],tdef.name,'Float32',4,4);
						case _:
							recurse(follow(t,true));
					}
				case TDynamic(_):
					//TODO
					// return getType('indian.AnyPtr');
					return null;
				// case TInst(_.get() => { kind : KTypeParameter(_) }, _):
					// return getType('Dynamic');
				case TAnonymous(_):
					throw new Error('A managed (anonymous) type cannot have its address used. Are you missing another `Struct` definition?', pos);
				case _:
					throw new Error('Still unsupported type : $t',pos);
			}
			// return t;
			throw 'assert';
		}
	}

	private static function align(nbytes:Int, alignment:Int, currentOffset:Int)
	{
		// alignment rules taken from
		// http://en.wikipedia.org/wiki/Data_structure_alignment
		// and http://msdn.microsoft.com/en-us/library/ms253949(v=vs.80).aspx
		var current = currentOffset % alignment;
		if (current != 0)
		{
			currentOffset += (alignment - current);
		}

		return currentOffset;
	}
}

