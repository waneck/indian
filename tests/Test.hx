import indian.*;
class Test
{
	static function main()
	{
		trace("hello world");
		var data:IntPtr<Int> = null;
		var d2 = data.pcast(String);
		$type(d2);
	}

}
