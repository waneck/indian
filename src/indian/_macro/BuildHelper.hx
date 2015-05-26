package indian._macro;
import haxe.macro.Context;
import haxe.macro.Context.*;
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

	static var regex = ~/typedef[ \t\n]+([A-Za-z0-9_]+)/g;

	public static function tryGetDeclaringTypedef():Null<{ pack:Array<String>, name:String }>
	{
		var r = getPosInfos(currentPos());
		try
		{
			var f = sys.io.File.read(r.file);
			f.seek(r.min, SeekBegin);
			var data = f.readString(r.max - r.min);
			f.close();
			if (regex.match(data))
			{
				var pack = getLocalModule().split('.');
				pack.pop();
				return { pack:pack, name:regex.matched(1) };
			}
		}
		catch(e:Dynamic) {}

		return null;
	}
}
