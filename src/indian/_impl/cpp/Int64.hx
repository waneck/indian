package indian._impl.cpp;

@:unreflective
@:structAccess
@:include('indian/_impl/cpp/Int64Boxed.h')
extern class Int64
{
	public function ixor(i2:Int):Int64;
	public function compare(i2:Int64):Int;
	public function xor_i64(i2:Int64):Int64;
	public function ior(i2:Int):Int64;
	public function or_i64(i2:Int64):Int64;
	public function iand(i2:Int):Int64;
	public function and_i64(i2:Int64):Int64;
	public function shr(i2:Int):Int64;
	public function ushr(i2:Int):Int64;
	public function shl(i2:Int):Int64;
	public function mul(i2:Int):Int64;
	public function mul_i64(i2:Int64):Int64;
	public function div(i2:Int):Int64;
	public function div_i64(i2:Int64):Int64;
	public function mod(i2:Int):Int64;
	public function mod_i64(i2:Int64):Int64;
	public function add(i2:Int):Int64;
	public function add_i64(i2:Int64):Int64;
	public function make(i2:Int):Int64;
	public function toStr():String;
	public function toHex():String;
}

@:headerNamespaceCode('
	class Int64;

	extern "C" {
		::indian::_impl::cpp::Int64 indian_i64_of_Dynamic(Dynamic d);
		Dynamic indian_Dynamic_of_i64(::indian::_impl::cpp::Int64 t);
	}

	class Int64
	{
		public:
			inline operator Dynamic () const { return indian_Dynamic_of_i64(*this); }
			inline operator long long int() { return i64; }

			inline Int64(Dynamic val) : i64(indian_i64_of_Dynamic(val).i64) { }
			inline Int64(int high, int low) : i64((( (long long int) high ) << 32) | (low & 0xFFFFFFFF)) { }
			inline Int64(long long int val) : i64(val) { }
			inline Int64(const null &v) : i64(0L) { }
			inline Int64() : i64(0L) { }

			long long int i64;

			inline ::indian::_impl::cpp::Int64 shl(int i) { return (long long int) ((long long int) this->i64) << i; }
			inline ::indian::_impl::cpp::Int64 mul( int i) { return this->i64 * i; }
			inline ::indian::_impl::cpp::Int64 mul_i64( ::indian::_impl::cpp::Int64 i) { return this->i64 * i; }
			inline ::indian::_impl::cpp::Int64 div ( int i) { return this->i64 / i; }
			inline ::indian::_impl::cpp::Int64 div_i64( ::indian::_impl::cpp::Int64 i) { return this->i64 / i; }
			inline ::indian::_impl::cpp::Int64 mod ( int i) { return this->i64 % i; }
			inline ::indian::_impl::cpp::Int64 mod_i64( ::indian::_impl::cpp::Int64 i) { return this->i64 % i; }
			inline ::indian::_impl::cpp::Int64 add( int i) { return this->i64 + i; }
			inline ::indian::_impl::cpp::Int64 add_i64( ::indian::_impl::cpp::Int64 i) { return this->i64 + i; }
			inline ::indian::_impl::cpp::Int64 shr ( int i) { return this->i64 >> i; }
			inline ::indian::_impl::cpp::Int64 ushr( int i) { return ((unsigned long long int) this->i64) >> i; }
			inline ::indian::_impl::cpp::Int64 iand ( int i) { return this->i64 & i; }
			inline ::indian::_impl::cpp::Int64 and_i64( ::indian::_impl::cpp::Int64 i) { return this->i64 & i; }
			inline ::indian::_impl::cpp::Int64 ior ( int i) { return this->i64 | i; }
			inline ::indian::_impl::cpp::Int64 or_i64( ::indian::_impl::cpp::Int64 i) { return this->i64 | i; }
			inline ::indian::_impl::cpp::Int64 ixor ( int i) { return this->i64 ^ i; }
			inline ::indian::_impl::cpp::Int64 xor_i64( ::indian::_impl::cpp::Int64 i) { return this->i64 ^ i; }

			inline int compare( ::indian::_impl::cpp::Int64 i2 )
			{
				return this->i64 > i2 ? 1 : (this->i64 < i2) ? -1 : 0;
			}

			inline ::String toStr()
			{
				char str[25];
				sprintf(str, "%lld", (long long int) this->i64);
				return ::String(str, strlen(str)).dup();
			}

			inline ::String toHex()
			{
				char str[20];
				sprintf(str, "0x%016llx", (long long int) this->i64);
				return ::String(str, strlen(str)).dup();
			}
	};

')
@:cppFileCode('
	extern "C" {
		::indian::_impl::cpp::Int64 indian_i64_of_Dynamic(Dynamic d)
		{
			::indian::_impl::cpp::Int64Boxed b = d;
			return b == null() ? ::indian::_impl::cpp::Int64() : b->data;
		}

		Dynamic indian_Dynamic_of_i64(::indian::_impl::cpp::Int64 t)
		{
			return ::indian::_impl::cpp::Int64Boxed_obj::__new(t);
		}
	}
')
@:keep class Int64Boxed
{
	public var data:Int64;
	public function new(data)
	{
		this.data = data;
	}

	public function toString():String
	{
		return data.toHex();
	}
}
