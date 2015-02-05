package indian._impl.cpp;

@:unreflective
@:structAccess
@:include('indian/_impl/cpp/IntPtrBoxed.h')
extern class IntPtr
{
	public function ixor(i2:Int):IntPtr;
	public function compare(i2:IntPtr):Int;
	public function xor_iptr(i2:IntPtr):IntPtr;
	public function ior(i2:Int):IntPtr;
	public function or_iptr(i2:IntPtr):IntPtr;
	public function iand(i2:Int):IntPtr;
	public function and_iptr(i2:IntPtr):IntPtr;
	public function shr(i2:Int):IntPtr;
	public function ushr(i2:Int):IntPtr;
	public function shl(i2:Int):IntPtr;
	public function mul(i2:Int):IntPtr;
	public function mul_iptr(i2:IntPtr):IntPtr;
	public function div(i2:Int):IntPtr;
	public function div_iptr(i2:IntPtr):IntPtr;
	public function mod(i2:Int):IntPtr;
	public function mod_iptr(i2:IntPtr):IntPtr;
	public function add(i2:Int):IntPtr;
	public function add_iptr(i2:IntPtr):IntPtr;
	public function sub(i2:Int):IntPtr;
	public function sub_iptr(i2:IntPtr):IntPtr;
	public function neg():IntPtr;
	public function nebBits():IntPtr;
	public function toStr():String;
	public function toHex():String;

	public function toInt():Int;
	public function toInt64():Int64;
	public function toPointer():cpp.RawPointer<Dynamic>;

	@:extern inline public static function ofInt(i:Int):IntPtr
		return untyped __cpp__('::indian::_impl::cpp::IntPtr::ofInt({0})',i);
	@:extern inline public static function ofInt64(i:Int64):IntPtr
		return untyped __cpp__('::indian::_impl::cpp::IntPtr::ofInt64({0})',i);
	@:extern inline public static function ofPointer(ptr:cpp.RawConstPointer<Dynamic>):IntPtr
		return untyped __cpp__('::indian::_impl::cpp::IntPtr::ofPointer((void *) {0})',ptr);
}

@:headerCode('
#include <indian/_impl/cpp/Int64Boxed.h>
')
@:headerNamespaceCode('
	class IntPtr;

	IntPtr indian_iptr_of_Dynamic(Dynamic d);
	Dynamic indian_Dynamic_of_iptr(IntPtr t);

	class IntPtr
	{
		public:
			inline operator Dynamic () const { return indian_Dynamic_of_iptr(*this); }
			inline operator intptr_t() { return iptr; }

			inline IntPtr(Dynamic val) : iptr(indian_iptr_of_Dynamic(val).iptr) { }
			inline IntPtr(intptr_t val) : iptr(val) { }
			inline IntPtr(const null &v) : iptr(0L) { }
			inline IntPtr() : iptr(0L) { }

			inline static ::indian::_impl::cpp::IntPtr ofInt(int i)
			{
				return ::indian::_impl::cpp::IntPtr( (intptr_t) i );
			}

			inline static ::indian::_impl::cpp::IntPtr ofInt64(::indian::_impl::cpp::Int64 i)
			{
				return ::indian::_impl::cpp::IntPtr( (intptr_t) i.i64 );
			}

			inline static ::indian::_impl::cpp::IntPtr ofPointer(void *ptr)
			{
				return ::indian::_impl::cpp::IntPtr( (intptr_t) ptr );
			}

			intptr_t iptr;

			inline ::indian::_impl::cpp::IntPtr shl(int i) { return this->iptr << i; }
			inline ::indian::_impl::cpp::IntPtr mul( int i) { return this->iptr * ((intptr_t) i); }
			inline ::indian::_impl::cpp::IntPtr mul_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr * i.iptr; }
			inline ::indian::_impl::cpp::IntPtr div ( int i) { return this->iptr / ((intptr_t) i); }
			inline ::indian::_impl::cpp::IntPtr div_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr / i.iptr; }
			inline ::indian::_impl::cpp::IntPtr mod ( int i) { return this->iptr % ((intptr_t) i); }
			inline ::indian::_impl::cpp::IntPtr mod_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr % i.iptr; }
			inline ::indian::_impl::cpp::IntPtr add( int i) { return this->iptr + ((intptr_t) i); }
			inline ::indian::_impl::cpp::IntPtr add_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr + i.iptr; }
			inline ::indian::_impl::cpp::IntPtr sub( int i) { return this->iptr - ((intptr_t) i); }
			inline ::indian::_impl::cpp::IntPtr sub_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr - i.iptr; }
			inline ::indian::_impl::cpp::IntPtr shr ( int i) { return this->iptr >> i; }
			inline ::indian::_impl::cpp::IntPtr ushr( int i) { return (this->iptr) >> i; }
			inline ::indian::_impl::cpp::IntPtr iand ( int i) { return this->iptr & i; }
			inline ::indian::_impl::cpp::IntPtr and_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr & i; }
			inline ::indian::_impl::cpp::IntPtr ior ( int i) { return this->iptr | i; }
			inline ::indian::_impl::cpp::IntPtr or_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr | i; }
			inline ::indian::_impl::cpp::IntPtr ixor ( int i) { return this->iptr ^ i; }
			inline ::indian::_impl::cpp::IntPtr xor_iptr( ::indian::_impl::cpp::IntPtr i) { return this->iptr ^ i; }

			inline ::indian::_impl::cpp::IntPtr neg () { return -(this->iptr); }
			inline ::indian::_impl::cpp::IntPtr negBits () { return ~(this->iptr); }

			inline int toInt () { return (int) this->iptr; }
			inline ::indian::_impl::cpp::Int64 toInt64 () { return ::indian::_impl::cpp::Int64( (long long int) this->iptr ); }
			inline void *toPointer () { return (void *) this->iptr; }

			inline int compare( ::indian::_impl::cpp::IntPtr i2 )
			{
				return this->iptr > i2.iptr ? 1 : (this->iptr < i2.iptr) ? -1 : 0;
			}

			inline ::String toStr()
			{
				char str[25];
				sprintf(str, "%lld", (long long int) this->iptr);
				return ::String(str, strlen(str)).dup();
			}

			inline ::String toHex()
			{
				char str[20];
				sprintf(str, "0x%016llx", (long long int) this->iptr);
				return ::String(str, strlen(str)).dup();
			}
	};

')
@:cppNamespaceCode('
		IntPtr indian_iptr_of_Dynamic(Dynamic d)
		{
			IntPtrBoxed b = d;
			return b == null() ? IntPtr() : b->data;
		}

		Dynamic indian_Dynamic_of_iptr(IntPtr t)
		{
			return IntPtrBoxed_obj::__new(t);
		}
')
@:keep class IntPtrBoxed
{
	public var data:IntPtr;
	public function new(data)
	{
		this.data = data;
	}

	public function toString():String
	{
		return data.toHex();
	}
}

