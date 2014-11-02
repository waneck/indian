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

	static function main()
	{
		var map = new Map();
		map[10] = 10;
		var runner = new Runner();

		runner.addCase(new indian.test.PointerTests());
		runner.addCase(new indian.test.Int64Tests());
		runner.addCase(new indian.test.BufferTests());
		runner.addCase(new indian.test.IndianTests());

		var report = new utest.ui.text.PrintReport(runner);
		runner.run();

#if sys
		// Sys.exit(report.allOk() ? 0 : 1);
#end
	}

}
