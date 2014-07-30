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
		var runner = new Runner();

		runner.addCase(new indian.test.PointerTests());
		runner.addCase(new indian.test.Int64Tests());

		var report = new utest.ui.text.PrintReport(runner);
		runner.run();

#if sys
		// Sys.exit(report.allOk() ? 0 : 1);
#end
	}

}
