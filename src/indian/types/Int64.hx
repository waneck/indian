package indian.types;
using haxe.Int64;
#if neko
import neko.Lib;
#end

/**
	Cross-platform implementation of a 64-bit Int
**/
@:unreflective abstract Int64(Int64_t)
{
	@:extern private inline function new(real:Int64_t)
	{
		this = real;
	}

	@:extern inline public static function make(high:Int, low:Int):Int64
	{
#if cpp
		var ret = Int64Helper.make(high,low);
		return ret;
#elseif neko
		return __make(high,low);
#else
		return haxe.Int64.make(high,low);
#end
	}

	@:from @:extern inline public static function fromInt64(i64:haxe.Int64):Int64
	{
#if cpp
		var ret = Int64Helper.make(i64.getHigh(), i64.getLow());
		return ret;
#elseif neko
		return __make(i64.getHigh(), i64.getLow());
#else
		return new Int64(i64);
#end
	}

	@:to @:extern inline public function toInt64():haxe.Int64
	{
#if cpp
		var ret = haxe.Int64.make( (this >>> 32) & 0xFFFFFFFF, this & 0xFFFFFFFF );
		return ret;
#elseif neko
		return haxe.Int64.make( __toInt(__and( __ushr(this,32), 0xFFFFFFFF )), __toInt(__and(this, 0xFFFFFFFF)) );
#else
		return this;
#end
	}

	@:extern private inline function t():Int64_t
	{
		return this;
	}

	@:extern @:from inline public static function ofInt(i:Int):Int64
	{
#if (cpp || java || cs)
		return cast i;
#elseif neko
		return make(0,i);
#else
		return new Int64(haxe.Int64.ofInt(i));
#end
	}

	@:extern inline public function toInt():Int
	{
#if (cpp || java || cs)
		return cast this;
#elseif neko
		return __toInt(this);
#else
		return haxe.Int64.toInt(this);
#end
	}

	@:extern @:op(A+B) public inline function add(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.add(this,i);
		return ret;
#elseif neko
		return __add(this,i);
#elseif (cs || java)
		return new Int64( this.add(cast i) );
#else
		return new Int64( this.add( haxe.Int64.ofInt(i) ) );
#end
	}

	@:extern @:op(A++) public inline function incr():Int64
	{
#if cpp
		var ret = Int64Helper.add(this,1);
		return ret;
#elseif neko
		return __add(this,1);
#elseif (cs || java)
		return new Int64( this.add(cast 1) );
#else
		return new Int64( this.add( haxe.Int64.ofInt(1) ) );
#end
	}

	@:extern @:op(A--) public inline function decr():Int64
	{
#if cpp
		var ret = Int64Helper.add(this,-1);
		return ret;
#elseif neko
		return __add(this,-1);
#elseif (cs || java)
		return new Int64( this.add(cast -1) );
#else
		return new Int64( this.add( haxe.Int64.ofInt(-1) ) );
#end
	}

	@:extern @:op(A-B) public inline function sub(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.add(this,-i);
		return ret;
#elseif neko
		return __add(this,-i);
#elseif (cs || java)
		return new Int64( this.add(cast -i) );
#else
		return new Int64( this.add( haxe.Int64.ofInt(-i) ) );
#end
	}

	@:extern @:op(A+B) public inline function add_int64(i:Int64):Int64
	{
#if cpp
		var ret =  Int64Helper.add_i64(this,i.t());
		return ret;
#elseif neko
		return __add(this,i);
#else
		return new Int64( this.add(i) );
#end
	}

	@:extern @:op(A-B) public inline function sub_int64(i:Int64):Int64
	{
#if cpp
		var ret =  Int64Helper.add_i64(this,-i.t());
		return ret;
#elseif neko
		return __sub(this,i);
#else
		return new Int64( this.add(i.t().neg()) );
#end
	}

	@:extern @:op(-A) inline public function neg():Int64
	{
#if cpp
		return new Int64(-this);
#elseif neko
		return __sub(0,this);
#else
		return new Int64(this.neg());
#end
	}

	@:extern @:op(A*B) public inline function mul(i:Int):Int64
	{
#if cpp
		return Int64Helper.mul(this,i);
#elseif neko
		var ret = __mul(this,i);
		return ret;
#elseif (cs || java)
		return new Int64( this.mul(cast i) );
#else
		return new Int64( this.mul( haxe.Int64.ofInt(i) ) );
#end
	}

	@:extern @:op(A*B) public inline function mul_int64(i:Int64):Int64
	{
#if cpp
		return Int64Helper.mul_i64(this,i.t());
#elseif neko
		var ret = __mul(this,i);
		return ret;
#else
		return new Int64( this.mul(i) );
#end
	}

	@:extern @:op(A/B) public inline function div(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.div(this,i);
		return ret;
#elseif neko
		return __div(this,i);
#elseif (cs || java)
		return new Int64( this.div(cast i) );
#else
		return new Int64( this.div( haxe.Int64.ofInt(i) ) );
#end
	}

	@:extern @:op(A/B) public inline function div_int64(i:Int64):Int64
	{
#if cpp
		var ret = Int64Helper.div_i64(this,i.t());
		return ret;
#elseif neko
		return __div(this,i);
#else
		return new Int64( this.div(i) );
#end
	}

	@:extern @:op(A%B) public inline function mod(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.mod(this,i);
		return ret;
#elseif neko
		return __mod(this,i);
#elseif (cs || java)
		return new Int64( this.mod(cast i) );
#else
		return new Int64( this.mod( haxe.Int64.ofInt(i) ) );
#end
	}

	@:extern @:op(A%B) public inline function mod_int64(i:Int64):Int64
	{
#if cpp
		var ret = Int64Helper.mod_i64(this,i.t());
		return ret;
#elseif neko
		return __mod(this,i);
#else
		return new Int64( this.mod(i) );
#end
	}

	@:extern @:op(A<<B) public inline function shl(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.shl(this,i);
		return ret;
#elseif neko
		return __shl(this,i);
#else
		return new Int64( this.shl(i) );
#end
	}

	@:extern @:op(A>>B) public inline function shr(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.shr(this,i);
		return ret;
#elseif neko
		return __shr(this,i);
#else
		return new Int64( this.shl(i) );
#end
	}

	@:extern @:op(A>>>B) public inline function ushr(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.ushr(this,i);
		return ret;
#elseif neko
		return __ushr(this,i);
#else
		return new Int64( this.ushr(i) );
#end
	}

	@:extern @:op(A&B) public inline function and(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.iand(this,i);
		return ret;
#elseif neko
		return __and(this,i);
#elseif (cs || java)
		return new Int64( this.and(cast i) );
#else
		return new Int64( this.and( haxe.Int64.ofInt(i) ) );
#end
	}

	@:extern @:op(A&B) public inline function and_int64(i:Int64):Int64
	{
#if cpp
		var ret = Int64Helper.and_i64(this,i.t());
		return ret;
#elseif neko
		return __and(this,i);
#else
		return new Int64( this.and(i.t()) );
#end
	}

	@:extern @:op(A|B) public inline function or(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.ior(this,i);
		return ret;
#elseif neko
		return __or(this,i);
#elseif (cs || java)
		return new Int64( this.or(cast i) );
#else
		return new Int64( this.or( haxe.Int64.ofInt(i) ) );
#end
	}

	@:extern @:op(A|B) public inline function or_int64(i:Int64):Int64
	{
#if cpp
		var ret = Int64Helper.or_i64(this,i.t());
		return ret;
#elseif neko
		return __or(this,i);
#else
		return new Int64( this.or(i.t()) );
#end
	}

	@:extern @:op(A^B) public inline function xor(i:Int):Int64
	{
#if cpp
		var ret = Int64Helper.ixor(this,i);
		return ret;
#elseif neko
		return __xor(this,i);
#elseif (cs || java)
		return new Int64( this.xor(cast i) );
#else
		return new Int64( this.xor( haxe.Int64.ofInt(i) ) );
#end
	}

	@:extern @:op(A^B) public inline function xor_int64(i:Int64):Int64
	{
#if cpp
		var ret = Int64Helper.xor_i64(this,i.t());
		return ret;
#elseif neko
		return __xor(this,i);
#else
		return new Int64( this.xor(i.t()) );
#end
	}

	@:extern public static inline function compare(a:Int64, b:Int64):Int
	{
#if cpp
		return Int64Helper.compare(a.t(),b.t());
#elseif neko
		return __compare(a.t(),b.t());
#else
		return a.t().compare(b.t());
#end
	}

	@:extern @:op(A>B) public static inline function gt(a:Int64, i:Int):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i) > 0;
#elseif neko
		return __compare(a.t(),i) > 0;
#elseif (java || cs)
		return a.t().compare(cast i) > 0;
#else
		return a.t().compare( haxe.Int64.ofInt(i) ) > 0;
#end
	}

	@:extern @:op(A>B) public static inline function gt_int64(a:Int64, i:Int64):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i.t()) > 0;
#elseif neko
		return __compare(a.t(),i.t()) > 0;
#else
		return a.t().compare(i.t()) > 0;
#end
	}

	@:extern @:op(A>=B) public static inline function gte(a:Int64, i:Int):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i) >= 0;
#elseif neko
		return __compare(a.t(),i) >= 0;
#elseif (java || cs)
		return a.t().compare(cast i) >= 0;
#else
		return a.t().compare( haxe.Int64.ofInt(i) ) >= 0;
#end
	}

	@:extern @:op(A>=B) public static inline function gte_int64(a:Int64, i:Int64):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i.t()) >= 0;
#elseif neko
		return __compare(a.t(),i.t()) >= 0;
#else
		return a.t().compare(i) >= 0;
#end
	}

	@:extern @:op(A<B) public static inline function lt(a:Int64, i:Int):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i) < 0;
#elseif neko
		return __compare(a.t(),i) < 0;
#elseif (java || cs)
		return a.t().compare(cast i) < 0;
#else
		return a.t().compare( haxe.Int64.ofInt(i) ) < 0;
#end
	}

	@:extern @:op(A<B) public static inline function lt_int64(a:Int64, i:Int64):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i.t()) < 0;
#elseif neko
		return __compare(a.t(),i.t()) < 0;
#else
		return a.t().compare(i.t()) < 0;
#end
	}

	@:extern @:op(A<=B) public static inline function lte(a:Int64, i:Int):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i) <= 0;
#elseif neko
		return __compare(a.t(),i) <= 0;
#elseif (java || cs)
		return a.t().compare(cast i) <= 0;
#else
		return a.t().compare( haxe.Int64.ofInt(i) ) <= 0;
#end
	}

	@:extern @:op(A<=B) public static inline function lte_int64(a:Int64, i:Int64):Bool
	{
#if cpp
		return Int64Helper.compare(a.t(),i.t()) <= 0;
#elseif neko
		return __compare(a.t(),i.t()) <= 0;
#else
		return a.t().compare(i.t()) <= 0;
#end
	}

	@:extern @:op(A==B) public inline function eq(to:Int64):Bool
	{
#if cpp
		return Int64Helper.compare(this,to.t()) == 0;
#elseif neko
		return __compare(this,to.t()) == 0;
#else
		return haxe.Int64.compare( this, to.t() ) == 0;
#end
	}

	@:extern public inline function toString():String
	{
#if cpp
		return Int64Helper.toStr(this);
#elseif neko
		return neko.Lib.nekoToHaxe(__toStr(this));
#elseif (java || cs)
		return this + "";
#else
		return haxe.Int64.toStr(this);
#end
	}

#if cpp @:extern inline #end public function toHex():String
	{
#if cpp
		return Int64Helper.toHex(this);
#elseif neko
		return neko.Lib.nekoToHaxe(__toHex(this));
#elseif java
		var r = this;
		var r2:String = untyped __java__('java.lang.Long.toHexString(r)');
		return '0x' + StringTools.lpad(r2,'0',16);
#elseif cs
		var r = this;
		var r2:String = untyped __cs__('r.ToString("X")');
		return '0x' + StringTools.lpad(r2.toLowerCase(),'0',16);
#else
		var hex = '0123456789abcdef',
				ethis = new Int64(this);
		var ret = new StringBuf();
		var i = 16;
		while (i --> 0)
		{
			var i = i * 4;
			var h = ofInt(0xf) << i;
			var i2 = ( (h & ethis) >>> i ).toInt();
			ret.add(hex.charAt(i2));
		}
		return '0x' + ret.toString();
#end
	}

	// DEFS
#if neko
	private static var __toHex:Dynamic = neko.Lib.load("indian","tau_i64_to_hex",1);
	private static var __toStr:Dynamic = neko.Lib.load("indian","tau_i64_to_str",1);
	private static var __toInt:Dynamic = neko.Lib.load("indian","tau_i64_to_int",1);
	private static var __compare:Dynamic = neko.Lib.load("indian","tau_i64_compare",2);
	private static var __xor:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_xor",2);
	private static var __or:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_or",2);
	private static var __and:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_and",2);
	private static var __ushr:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_ushr",2);
	private static var __shr:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_shr",2);
	private static var __shl:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_shl",2);
	private static var __mod:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_mod",2);
	private static var __div:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_div",2);
	private static var __mul:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_mul",2);
	private static var __sub:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_sub",2);
	private static var __add:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_add",2);
	private static var __make:Dynamic->Dynamic->Int64 = neko.Lib.load("indian","tau_i64_make",2);
#end

}

#if neko
typedef Int64_t = Dynamic;
#else
typedef Int64_t = #if cpp cpp.Int64 #else haxe.Int64 #end
#end

#if cpp
@:headerClassCode('
		static ::cpp::Int64 shl( ::cpp::Int64 this1,int i)
		{
			return (long long int) ((long long int) this1) << i;
		}

		static ::cpp::Int64 mul( ::cpp::Int64 this1, int i)
		{
			return this1 * i;
		}

		static ::cpp::Int64 mul_i64( ::cpp::Int64 this1, ::cpp::Int64 i)
		{
			return this1 * i;
		}

		static ::cpp::Int64 div ( ::cpp::Int64 this1, int i)
		{
			return this1 / i;
		}

		static ::cpp::Int64 div_i64( ::cpp::Int64 this1, ::cpp::Int64 i)
		{
			return this1 / i;
		}

		static ::cpp::Int64 mod ( ::cpp::Int64 this1, int i)
		{
			return this1 % i;
		}

		static ::cpp::Int64 mod_i64( ::cpp::Int64 this1, ::cpp::Int64 i)
		{
			return this1 % i;
		}

		static ::cpp::Int64 add( ::cpp::Int64 this1, int i)
		{
			return this1 + i;
		}

		static ::cpp::Int64 add_i64( ::cpp::Int64 this1, ::cpp::Int64 i)
		{
			return this1 + i;
		}

		static ::cpp::Int64 shr ( ::cpp::Int64 this1, int i)
		{
			return this1 >> i;
		}

		static ::cpp::Int64 ushr( ::cpp::Int64 this1, int i)
		{
			return ((unsigned long long int) this1) >> i;
		}

		static ::cpp::Int64 iand ( ::cpp::Int64 this1, int i)
		{
			return this1 & i;
		}

		static ::cpp::Int64 and_i64( ::cpp::Int64 this1, ::cpp::Int64 i)
		{
			return this1 & i;
		}

		static ::cpp::Int64 ior ( ::cpp::Int64 this1, int i)
		{
			return this1 | i;
		}

		static ::cpp::Int64 or_i64( ::cpp::Int64 this1, ::cpp::Int64 i)
		{
			return this1 | i;
		}

		static ::cpp::Int64 ixor ( ::cpp::Int64 this1, int i)
		{
			return this1 ^ i;
		}

		static ::cpp::Int64 xor_i64( ::cpp::Int64 this1, ::cpp::Int64 i)
		{
			return this1 ^ i;
		}

		static int compare( ::cpp::Int64 this1, ::cpp::Int64 i2 )
		{
			return this1 > i2 ? 1 : (this1 < i2) ? -1 : 0;
		}

		static ::cpp::Int64 make( int high, int low )
		{
			return (( (::cpp::Int64) high ) << 32) | (low & 0xFFFFFFFF);
		}

		static ::String toStr( ::cpp::Int64 this1 )
		{
			char str[25];
			sprintf(str, "%lld", (long long int) this1);
			return ::String(str, strlen(str)).dup();
		}

		static ::String toHex( ::cpp::Int64 this1 )
		{
			char str[19];
			sprintf(str, "0x%016llx", (long long int) this1);
			return ::String(str, strlen(str)).dup();
		}
')
@:keep class Int64Helper
{
	@:extern public static function ixor(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function compare(i:Int64_t, i2:Int64_t):Int
	{
		return 1;
	}

	@:extern public static function xor_i64(i:Int64_t, i2:Int64_t):Int64
	{
		return 1;
	}

	@:extern public static function ior(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function or_i64(i:Int64_t, i2:Int64_t):Int64
	{
		return 1;
	}

	@:extern public static function iand(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function and_i64(i:Int64_t, i2:Int64_t):Int64
	{
		return 1;
	}

	@:extern public static function shr(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function ushr(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function shl(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function mul(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function mul_i64(i:Int64_t, i2:Int64_t):Int64
	{
		return 1;
	}

	@:extern public static function div(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function div_i64(i:Int64_t, i2:Int64_t):Int64
	{
		return 1;
	}

	@:extern public static function mod(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function mod_i64(i:Int64_t, i2:Int64_t):Int64
	{
		return 1;
	}

	@:extern public static function add(i:Int64_t, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function add_i64(i:Int64_t, i2:Int64_t):Int64
	{
		return 1;
	}

	@:extern public static function make(i1:Int, i2:Int):Int64
	{
		return 1;
	}

	@:extern public static function toStr(i:Int64_t):String
	{
		return null;
	}

	@:extern public static function toHex(i:Int64_t):String
	{
		return null;
	}
}
#end

