package indian._impl.cpp;

//FIXME: use `m_` idiom for everything; expose malloc as well
@:keep @:unreflective class Memory
{
	public static function alloc(nbytes:Int):indian.Buffer
	{
		return untyped __cpp__('(unsigned char *) malloc({0})',nbytes);
	}

	@:extern inline public static function free(ptr:indian._impl.PointerType<Dynamic>)
	{
		m_free(ptr.reinterpret());
	}

	static function m_free(ptr:indian._impl.PointerType<cpp.UInt8>)
	{
		untyped __cpp__('free((void *) {0})',ptr);
	}

	@:extern inline public static function memmove(dest:indian.Buffer, src:indian.Buffer, len:Int)
	{
		m_memmove(dest,src,len);
	}

	static function m_memmove(dest:indian.Buffer, src:indian.Buffer, len:Int)
	{
		untyped __cpp__('memmove({0},{1},{2})',dest,src,len);
	}

	@:extern inline public static function memcpy(dest:indian.Buffer, src:indian.Buffer, len:Int)
	{
		m_memcpy(dest,src,len);
	}

	static function m_memcpy(dest:indian.Buffer, src:indian.Buffer, len:Int)
	{
		untyped __cpp__('memcpy({0},{1},{2})',dest,src,len);
	}

	@:extern inline public static function memcmp(ptr1:indian.Buffer, ptr2:indian.Buffer, len:Int):Int
	{
		return m_memcmp(ptr1,ptr2,len);
	}

	static function m_memcmp(ptr1:indian.Buffer, ptr2:indian.Buffer, len:Int):Int
	{
		return untyped __cpp__('memcmp({0},{1},{2})',ptr1,ptr2,len);
	}

	@:extern inline public static function strlen(ptr:indian.Buffer):Int
	{
		return m_strlen(ptr);
	}

	static function m_strlen(ptr:indian.Buffer):Int
	{
		return untyped __cpp__('strlen((const char *) (void *) {0})',ptr);
	}
}
