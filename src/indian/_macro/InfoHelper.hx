package indian._macro;

class InfoHelper
{
	macro public static function isWindows()
	{
		return macro $v{Sys.systemName() == "Windows"};
	}
}
