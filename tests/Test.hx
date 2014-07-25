import indian.*;
import indian.Struct;
class Test
{
	static function main()
	{
		var x:Ptr<Int> = 10;
		trace(x);
		$type(x);
		$type(Struct.test(10));
	}

}
