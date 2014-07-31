package indian._internal.cpp;

@:keep @:unreflective class Memory
{
	@:extern inline public static function alloc(nbytes:Int):indian._internal.PointerType<Dynamic>
	{
		return untyped __cpp__('malloc({0})',nbytes);
	}

	@:extern inline public static function m_free(ptr:indian._internal.PointerType<Dynamic>)
	{
		untyped __cpp__('free({0})',nbytes);
	}

	@:extern inline public static function m_memmove(dest:indian._internal.PointerType<cpp.Int8>, src:indian._internal.PointerType<cpp.Int8>, len:Int)
	{
		untyped __cpp__('memmove({0},{1},{2})',dest,src,len);
	}

	@:extern inline public static function m_memcpy(dest:indian._internal.PointerType<cpp.Int8>, src:indian._internal.PointerType<cpp.Int8>, len:Int)
	{
		untyped __cpp__('memcpy({0},{1},{2})',dest,src,len);
	}
}
