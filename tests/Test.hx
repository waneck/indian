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
		// var buffer:Buffer = null;
// #if java
		// var buffer = indian._internal.java.Pointer.alloc(1024);
		var buffer:Buffer = cast null;
		buffer = test(buffer);
// #end
		if (buffer != null)
		{
			trace(buffer.getUInt8(1));
			buffer.setUInt8(1,1);
			trace(buffer.getUInt8(1));
			trace(buffer.getUInt16(2));
			buffer.setUInt16(2,2);
			trace(buffer.getUInt16(2));
			trace(buffer.getInt32(3));
			buffer.setInt32(3,3);
			trace(buffer.getInt32(3));
			trace(buffer.getFloat32(4));
			buffer.setFloat32(4,4);
			trace(buffer.getFloat32(4));
		}
		var runner = new Runner();

		runner.addCase(new indian.test.PointerTest());

		var report = new utest.ui.text.PrintReport(runner);
		runner.run();

#if sys
		// Sys.exit(report.allOk() ? 0 : 1);
#end
	}

	@:unsafe static function test(a:Buffer)
	{
		return a;
	}

}
