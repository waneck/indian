package indian._internal.cpp;

@:keep @:unreflective class Memory
{
	@:extern inline public static function alloc<T>(nbytes:Int):indian.Buffer
	{
		return untyped __cpp__('(unsigned char *) calloc(1,{0})',nbytes);
	}

	@:extern inline public static function m_free(ptr:indian._internal.PointerType<Dynamic>)
	{
		untyped __cpp__('free({0})',nbytes);
	}

	@:extern inline public static function m_memmove(dest:indian.Buffer, src:indian.Buffer, len:Int)
	{
		untyped __cpp__('memmove({0},{1},{2})',dest,src,len);
	}

	@:extern inline public static function m_memcpy(dest:indian.Buffer, src:indian.Buffer, len:Int)
	{
		untyped __cpp__('memcpy({0},{1},{2})',dest,src,len);
	}
}
