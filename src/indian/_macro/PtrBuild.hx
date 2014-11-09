package indian._macro;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.*;

import indian._macro.BuildHelper.*;

using haxe.macro.Tools;

class PtrBuild
{
	public static function build():Type
	{
		return switch getLocalType() {
			case TInst(_.get() => cl, [t]):
				switch [ cl.pack, cl.name ] {
					case [ ["indian"], "Ptr" ]:
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
		var original = t;
		var layout = Layout.fromType(t,pos);
		if (layout == null)
			return getType('indian.AnyPtr');
		return getOrBuild(layout, t,pos);
	}

	private static function getOrBuild(layout:Layout, derefType:Type,pos:Position)
	{
		var pack = layout.pack,
				name = layout.name;
		var fnName = layout.type;
		var agg = new LayoutAgg();
		agg.add(layout);
		var build = [];
		var align = agg.expand('ptr',build);

		var t = pack.length == 0 ? name : shortType(pack,name);
		var buildName = 'P' + t;
		var typeName = 'indian.pointers.' + buildName;
		var type = try getType(typeName) catch(e:String) { if (e.indexOf('Type not found') >= 0) null; else throw e; };
		if (type != null)
			return type;

		var get = 'get$fnName',
				set = 'set$fnName';

		var thisType = TPath({ pack:['indian','pointers'], name:buildName });
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
			public static var bytesize(get,never):Int;

			@:extern inline private static function get_bytesize():Int
				return ${align(macro $v{1})};

			/**
				Returns the pointer to the n-th element
			**/
			@:op(A+B) @:extern inline public function advance(nth:Int) : $thisType
				return ${getExpr([
					'neko' => macro indian._impl.neko.PointerHelper.add(this,${align(macro nth)}),
					'cs' => macro cast this.add(nth),
					'cpp' => macro cast this.add(nth),
					'default' => macro cast this.add(${align(macro nth)}),
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
					'default' => macro this.$get( ${align(macro idx)} )
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
					'default' => macro { this.$set(${align(macro idx)},value); return value; }
				])};
			}

			@:extern inline private function t()
				return this;
		};

		cls.pack = ['indian','pointers'];
		cls.name = buildName;
		cls.kind = TDAbstract(underlying);
		cls.meta = [ for (name in [':dce',':pointer',':extern']) { name:name, params:[], pos:pos } ];
		for (field in build)
			cls.fields.push(field);

		// for (f in cls.fields)
		// {
		// 	switch(f.kind)
		// 	{
		// 		case FFun(fn):
		// 			trace({ expr:EFunction(f.name,fn), pos:pos }.toString(),f.access);
		// 		case _:
		// 			trace(f.name,f.access);
		// 	}
		// }
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
