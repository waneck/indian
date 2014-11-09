package indian._macro;
import haxe.macro.Expr;
import haxe.macro.Context.*;
using haxe.macro.Tools;

class LayoutAgg
{
	private var platfs:LayoutAggData;

	public function new()
	{
		this.platfs = [for (name in Layout.platforms) name => { name:name, offset:0 }];
	}

	public function align(layout:Layout)
	{
		for (v in layout.layouts)
		{
			var off = this.platfs[v.name];
			if (off == null) throw 'assert ${v.name}';
			off.offset = _align(v.nbytes,v.align,off.offset);
		}
	}

	public function reset()
	{
		for (p in platfs) p.offset = 0;
	}

	public function add(layout:Layout)
	{
		for (v in layout.layouts)
		{
			var off = this.platfs[v.name];
			if (off == null) throw 'assert ${v.name}';
			off.offset += v.nbytes;
		}
	}

	private static function isOne(e:Expr)
	{
		return switch (e) {
			case macro 1:
				true;
			case _:
				false;
		}
	}

	public function expand(uniqueName:String, build:Array<Field>):Expr->Expr
	{
		var byVal = new Map();
		for (o in this.platfs)
		{
			var off = o.offset;
			var arr = byVal[off];
			if (arr == null)
				byVal[off] = arr = [];
			arr.push(o);
		}
		var byVal = [ for (v in byVal) { value: v[0].offset, names:v } ];
		if (byVal.length == 1) //platform-independent!
		{
			var val = byVal[0];
			var lg = log2(val.value);
			if (lg > 0)
			{
				return function(e:Expr) return macro $e << $v{lg};
			} else {
				return function(e:Expr) return isOne(e) ? macro $v{val.value} : macro $e * $v{val.value};
			}
		} else {
			var power = true;
			for (v in byVal)
			{
				if (log2(v.value) <= 0)
				{
					power = false;
					break;
				}
			}

			byVal.sort(function(v1,v2) return Reflect.compare(v2.value,v1.value));
			var expr = null,
					i = 0;
			for (v in byVal)
			{
				// var cond = ++i == byVal.length ? null : getCond([ for (n in v.names) n]);
				var e = if (power)
				{
					macro $v{log2(v.value)};
				} else {
					macro $v{v.value};
				}
				if (expr == null)
					expr = e;
				else
					expr = macro if (${getCond([for (n in v.names) n.name])}) $e else $expr;
			}
			var vname = uniqueName + (power ? "_power" : ""),
					get = 'get_$vname',
					getOnce = 'getOnce_$vname',
					realv = '_$vname';
			var getData = if (defined('cpp') && !defined('HXCPP_CROSS')) macro $expr else macro $i{realv}; //let constant folding do its job here
			var cls = macro class {
				public static var $vname(get,never):Int;
				@:readOnly private static var $realv(default,never):Int = $i{getOnce}();

				@:extern inline public static function $get():Int
					return $getData;
				private static function $getOnce():Int
					return $expr;
			};
			for (field in cls.fields)
			{
				if (defined('cpp') && !defined('HXCPP_CROSS') && (field.name == realv || field.name == getOnce))
					continue;
				build.push(field);
			}

			if (power)
			{
				return function(e:Expr) return macro $e << $i{get}();
			} else {
				return function(e:Expr) return isOne(e) ? macro $i{get}() : macro $e * $i{get}();
			}
		}
	}

	private static function getCond(arr:Array<String>)
	{
		arr.sort(function(v1,v2) return Reflect.compare(v1,v2));
		switch (arr) {
			case ['nix32','win32']:
				return macro !indian.Infos.is64;
			case ['nix64','win64']:
				return macro indian.Infos.is64;
			case ['win32','win64']:
				return macro indian.Infos.isWindows;
			case ['nix32','nix64']:
				return macro !indian.Infos.isWindows;
			case _:
				var expr = null;
				for (a in arr)
				{
					var e = switch(a) {
						case 'win32':
							macro !indian.Infos.is64 && indian.Infos.isWindows;
						case 'win64':
							macro indian.Infos.is64 && indian.Infos.isWindows;
						case 'nix32':
							macro !indian.Infos.is64 && !indian.Infos.isWindows;
						case 'nix64':
							macro indian.Infos.is64 && !indian.Infos.isWindows;
						case _: throw 'assert';
					};
					if (expr == null)
						expr = e;
					else
						expr = macro ($expr) || ($e);
				}
				return expr;
		}
	}

	private static function log2(index:Int)
	{
		var targetlevel = 0,
				nOnes = 0;
		while(true)
		{
			if ( (index & 1) == 1 )
				nOnes++;
			if ( (index >>>= 1) <= 0 )
			{
				break;
			}
			++targetlevel;
		}
		if (nOnes == 1)
			return targetlevel; // power of two
		else
			return -1;
	}

	private static function _align(nbytes:Int, alignment:Int, currentOffset:Int)
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

typedef LayoutAggData = Map<String,{ offset:Int, name:String }>
