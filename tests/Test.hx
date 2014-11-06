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
		var ptr:Ptr<Int> = Indian.alloc(255);
		for (i in 0...10)
			ptr[i] = i;
		for (i in 0...10)
			trace(ptr[i]);
		// var any = AnyPtr.fromPointer(cast ptr);
		// trace(any);
		var runner = new Runner();

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

typedef A = Ptr<Int>;
