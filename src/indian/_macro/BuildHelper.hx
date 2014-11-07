package indian._macro;
import indian._macro.helpers.*;
using StringTools;

class BuildHelper
{
	static var shortPack = new ShortPack();

	public static function getShortPack(packarr:Array<String>):String
	{
		return shortPack.getShortPack(packarr);
	}

	public static function shortType(pack:Array<String>,name:String)
	{
		return shortPack.encode(pack,name);
	}
}
