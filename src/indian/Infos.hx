package indian;

class Infos
{
	public static var is64(get,never):Bool;
	public static var isWindows(get,never):Bool;
	public static var win64(get,never):Bool;
	public static var win32(get,never):Bool;
	public static var nix64(get,never):Bool;
	public static var nix32(get,never):Bool;
	@:readOnly private static var _is64(default,never):Bool = (AnyPtr.size == 8);
	@:readOnly private static var _isWindows(default,never):Bool = (Sys.systemName() == "Windows");
	@:readOnly private static var _win64(default,never):Bool = isWindows && is64;
	@:readOnly private static var _win32(default,never):Bool = isWindows && !is64;
	@:readOnly private static var _nix64(default,never):Bool = !isWindows && is64;
	@:readOnly private static var _nix32(default,never):Bool = !isWindows && !is64;

	@:extern inline private static function get_is64():Bool
#if (cpp && !HXCPP_CROSS)
	#if HXCPP_M64
		return true;
	#else
		return indian._macro.InfoHelper.isM64();
	#end
#else
		return _is64;
#end

	@:extern inline private static function get_isWindows():Bool
#if (cpp && !HXCPP_CROSS)
		return indian._macro.InfoHelper.isWindows();
#else
		return _isWindows;
#end

	@:extern inline private static function get_win64():Bool
#if (cpp && !HXCPP_CROSS)
		return isWindows && is64;
#else
		return _win64;
#end
	@:extern inline private static function get_win32():Bool
#if (cpp && !HXCPP_CROSS)
		return isWindows && !is64;
#else
		return _win32;
#end

	@:extern inline private static function get_nix64():Bool
#if (cpp && !HXCPP_CROSS)
		return !isWindows && is64;
#else
		return _nix64;
#end
	@:extern inline private static function get_nix32():Bool
#if (cpp && !HXCPP_CROSS)
		return !isWindows && !is64;
#else
		return _nix32;
#end
}
