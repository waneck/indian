package indian._macro;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Context.*;
import indian._macro.BuildHelper.*;

using haxe.macro.Tools;

class StructBuild
{
	public static function build():Array<Field>
	{
		var cl = getLocalClass().get();
		return null;
	}
}
