package indian;

#if java
@:classCode('
	public static final boolean _is64 = (indian.AnyPtr.size == 8);
')
#end
class Infos
{
	public static var is64(get,never):Bool;

	@:extern inline private static function get_is64():Bool
#if cpp
	#if HXCPP_M64
		return true;
	#else
		return false;
#else
		return _is64;
#end

#if java
	@:extern private static var _is64:Bool(default,null);
#else
	private static var _is64:Bool(default,null) = AnyPtr.size == 8;
#end
}
