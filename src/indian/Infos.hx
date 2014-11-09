package indian;

class Infos
{
	public static var is64(get,never):Bool;
	public static var isWindows(get,never):Bool;
	@:readOnly private static var _is64(default,never):Bool = (AnyPtr.size == 8);
	@:readOnly private static var _isWindows(default,never):Bool = (Sys.systemName() == "Windows");

	@:extern inline private static function get_is64():Bool
#if cpp
	#if HXCPP_M64
		return true;
	#else
		return false;
	#end
#else
		return _is64;
#end

	@:extern inline private static function get_isWindows():Bool
#if (cpp && !HXCPP_CROSS)
		return indian._macro.InfoHelper.isWindows();
#else
		return _is64;
#end
}
