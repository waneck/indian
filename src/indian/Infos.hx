package indian;

class Infos
{
	public static var is64(get,never):Bool;
	@:readOnly private static var _is64:Bool(default,never) = (AnyPtr.size == 8);

	@:extern inline private static function get_is64():Bool
#if cpp
	#if HXCPP_M64
		return true;
	#else
		return false;
#else
		return _is64;
#end

}
