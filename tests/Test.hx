package ;
import utest.Runner;
import utest.ui.Report;
import indian.*;

/**
 * ...
 * @author waneck
 */
class Test
{

	@:unsafe static function main()
	{
		var s:Ptr<S> = Indian.alloc(256);
		trace(s.x);
		s.x = 10;
		s.a = 22.2;
		trace(s.x,s.a);
		var runner = new Runner();

		runner.addCase(new indian.test.MiscTests());
		runner.addCase(new indian.test.PointerTests());
		runner.addCase(new indian.test.Int64Tests());
		runner.addCase(new indian.test.BufferTests());
		runner.addCase(new indian.test.IndianTests());
		runner.addCase(new indian.test.UnicodeTests());

		var report = new utest.ui.text.PrintReport(runner);
		runner.run();

#if sys
		Sys.exit(untyped report.result.stats.isOk ? 0 : 1);
#end
	}

}

typedef S = Struct<{
	var x:Int;
	var a:Float;
}>;

// class S1 implements Struct
// {
// 	public var i:Int;
// }
