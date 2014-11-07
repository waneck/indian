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
				switch [ cl.pack, cl.name ] {
					case [ ["indian"], "Ptr" ]:
					// case [ ["indian"], "HeapPtr" ]:
						// '_Heap';
					case _:
						throw new Error('Invalid local build type: ${cl.pack.join(".")}.${cl.name}',currentPos());
				}
				return checkOrCreate(t,currentPos());

			case _:
				throw "assert";
		}
	}

	private static function checkOrCreate(t:Type, pos:Position):Type
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
							return getOrBuild('Int32',[],a.name,4,t,pos);
						case [ [], 'Float', true ]:
							return getOrBuild('Float64',[],a.name,8,t,pos);
						case [ [], 'Single', true ]:
							return getOrBuild('Float32',[],a.name,4,t,pos);
						case [ [], 'Bool', true ]:
							return getOrBuild('Bool',[],a.name,1,t,pos);
						case [ _, _, true ]:
							throw new Error('Unrecognized native type ${a.pack.join('.')}.${a.name}. Please use the `indian.types` package for using standardized basic types',pos);
						case [ ['indian','types'], 'UInt8', false ]:
							return getOrBuild('UInt8',[],a.name,1,t,pos);
						case [ ['indian','types'], 'UInt16', false ]:
							return getOrBuild('UInt16',[],a.name,2,t,pos);
						case [ ['indian','types'], 'Int64', false ]:
							return getOrBuild('Int64',[],a.name,8,t,pos);
						case [ _, _, false ] if (a.meta.has(':pointer')):
							return getOrBuild('Pointer',[],a.name,-1,t,pos);
						case [ _, _, false ]:
							recurse(a.type);
					}
				case TType(_.get() => tdef,tl):
					switch [tdef.pack, tdef.name ] {
						case [ ['indian','types'], 'Single' ]:
							return getOrBuild('Float32', [],'Single',4,t,pos);
						case _:
							recurse(follow(t,true));
					}
				case TDynamic(_):
					return getType('indian.AnyPtr');
				case TInst(_.get() => { kind : KTypeParameter(_) }, _):
					return getType('indian.AnyPtr');
				case TAnonymous(_):
					throw new Error('A managed (anonymous) type cannot have its address used. Are you missing a `Struct` definition?', pos);
				case _:
					throw new Error('Still unsupported type : $t',pos);
			}
			return t;
		}
	}

	private static function getOrBuild(fnName:String, pack:Array<String>, name:String, size:Int, derefType:Type, pos:Position):Type
	{
		var buildName = "Ptr_" +pack.join("_") + (pack.length == 0 ? '' : '_') + name;
		var typeName = 'indian.pointers.' + buildName;
		var type = try getType(typeName) catch(e:String) { if (e.indexOf('Type not found') >= 0) null; else throw e; };
		if (type != null)
			return type;

		var get = 'get$fnName',
				set = 'set$fnName';

		var thisType = switch (parse('(_ : $typeName)',pos)) {
			case macro (_ : $type):
				type;
			case _: throw 'assert';
		};
		var deref = derefType.toComplexType();

		var underlying = if (defined('cpp') || defined('cs'))
			macro : indian._impl.PointerType<$deref>;
		else
			macro : indian.Buffer;

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

		//build here
		var cls = macro class { //abstract Ptr(indian._impl.PointerType<$T>)
			public static var byteSize(get,never):Int;

			@:extern inline private static function get_byteSize():Int
				return ${if(size > 0) macro $v{size} else macro indian.AnyPtr.size};

			public static var power(get,never):Int;

			@:extern inline private static function get_power():Int
				return ${if(size > 0) macro $v{log2(size)} else macro indian.AnyPtr.power};

			/**
				Returns the pointer to the n-th element
			**/
			@:op(A+B) @:extern inline public function advance(nth:Int) : $thisType
				return ${getExpr([
					'neko' => macro indian._impl.neko.PointerHelper.add(this,nth << power),
					'java' => macro cast this.add(nth << power),
					'default' => macro cast this.add(nth)
				])};

			@:op(++A) @:extern inline public function incr() : $thisType
				return cast this = advance(1).t();

			@:op(A++) @:extern inline public function postIncr() : $thisType
			{
				var t = this;
				this = advance(1).t();
				return cast t;
			}

			@:op(--A) @:extern inline public function decr() : $thisType
				return cast this = advance(-1).t();

			@:op(A--) @:extern inline public function postDecr() : $thisType
			{
				var t = this;
				this = advance(-1).t();
				return cast t;
			}

			@:from @:extern inline public static function fromBuffer(buf : indian.Buffer) : $thisType
			{
				${getExpr([
					'cpp' => macro return untyped ( buf.t().reinterpret() : $underlying ),
					'default' => macro return cast buf
				])};
			}

			@:from @:extern inline public static function fromAny(any : indian.AnyPtr) : $thisType
				${getExpr([
					'cs' => macro return cast @:privateAccess any.t().ToPointer(),
					'cpp' => macro return untyped ( any.t().reinterpret() : $underlying ),
					'default' => macro return cast any
				])};

			/**
				Reinterprets the pointer as an `indian.Buffer`
			**/
			@:to @:extern inline public function asBuffer():Buffer
			{
				${getExpr([
					'cpp' => macro return untyped ( this.reinterpret() : indian._impl.BufferType ),
					'default' => macro return cast this,
				])};
			}

			/**
				Reinterprets the pointer as `indian.AnyPtr`
			**/
			@:to @:extern inline public function asAny():AnyPtr
			{
				return indian.AnyPtr.fromInternalPointer(${getExpr([
					'cpp' => macro this,
					'cs' => macro this,
					'default' => macro @:privateAccess this.t()
				])});
			}

			/**
				Dereferences the pointer to the actual `T` object. If the actual `T` object is a Struct, and
				the underlying platform doesn't support naked structs, this field won't be available.
			**/
			@:deref @:extern inline public function dereference() : $deref
				return get(0);

			/**
				Gets the concrete `T` reference. If the underlying type is a struct, and
				the underlying platform doesn't support structs, this field won't be available
			**/
			@:deref @:arrayAccess @:extern inline public function get(idx:Int) : $deref
			{
				return ${getExpr([
					'cs' => macro this[idx],
					'cpp' => macro this.at(idx),
					'default' => macro this.$get(idx << power )
				])};
			}

			/**
				Sets the concrete `T` reference. If the underlying type is a struct, and
				the underlying platform doesn't support structs, this field won't be available
			**/
			@:deref @:arrayAccess @:extern inline public function set(idx:Int, value : $deref) : $deref
			{
				return ${getExpr([
					'cs' => macro this[idx] = value,
					'cpp' => macro { var ret:cpp.ConstPointer<$deref> = cast this.add(idx); untyped __cpp__('{0}[0] = {1}',ret,value); },
					'default' => macro { this.$set(idx << power,value); return value; }
				])};
			}

			@:extern inline private function t()
				return this;
		};

		cls.pack = ['indian','pointers'];
		cls.name = buildName;
		cls.kind = TDAbstract(underlying);
		cls.meta = [ for (name in [':dce',':pointer']) { name:name, params:[], pos:pos } ];
		defineType(cls);

		return getType(typeName);
	}

	private static function log2(index:Int):Int
	{
		var targetlevel = 0;
		while ((index >>>= 1) > 0) ++targetlevel;
		return targetlevel;
	}
}
