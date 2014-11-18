package indian.test;
import utest.Assert;
import indian.Indian.*;

@:unsafe class IndianTests
{
	public function new()
	{
	}

	public function test_alloca()
	{
		var buf = stackalloc(256);
		Assert.isTrue(buf != null);
		bufTest(buf,256);

		var x = 100;
		if (getTrue())
			x += 1000;
		var buf2 = stackalloc(x);
		Assert.isTrue(buf2 != null);
		bufTest16(buf2,x);

		stackfree(buf);
		stackfree(buf2);
	}

	public function test_auto()
	{
		var x = 100;
		if (getTrue())
			x += 1000;
		var didThrow = false;
		try
		{
			autofree(buf = $alloc(256), {
				bufTest(buf,256);
				throw "exc";
			});
		}
		catch(e:Dynamic)
		{
			didThrow = true;
		}
		Assert.isTrue(didThrow);

		autofree(buf = $stackalloc(256), buf2 = $stackalloc(x), buf3 = $alloc(256), buf4 = $alloc(x), {
			Assert.isTrue(buf != null);
			Assert.isTrue(buf2 != null);
			Assert.isTrue(buf3 != null);
			Assert.isTrue(buf4 != null);
			buf += 250;
			buf3 += 250;
			bufTest(buf,6);
			bufTest(buf3,6);

			buf2 += (x - 10);
			buf4 += (x - 10);
			bufTest16(buf2,10);
			bufTest16(buf4,10);
			buf = null;
			buf3 = null;

			return;
		});
	}

	public function test_fixed()
	{
		Assert.isTrue(true);
		var str = "a",
				str2 = new StringBuf(),
				arr1 = [0,1,2,3],
				arr2 = haxe.ds.Vector.fromArrayCopy([1.1,1.2,1.3,1.4]),
				big = [ for (i in 0...1000) i ];
		str2.add('b');
		str2.add('c');
		pin(p1 = $ptr(str), p2 = $ptr(str2.toString()), p3 = $ptr(arr1), p4 = $ptr(arr2), p5 = $ptr(big), {
			Assert.equals('a'.code, p1.getUInt8(0));
			Assert.equals('b'.code, p2.getUInt8(0));
			for (i in 0...4)
				Assert.equals(i, p3.getInt32(i*4));
			for (i in 0...4)
			{
				var val = 1 + (i + 1)/10;
				Assert.equals(val, p4.getFloat64(i*8));
			}
			for (i in 0...1000)
				Assert.equals(i, p5.getInt32(i*4));
			//no aligned pointer to the original structure
			p1++; p2++; p3++; p4++;p5++;
			str = null; str2 = null; arr1 = null; arr2 = null; big = null;
			doSomeWork();
			Assert.equals('a'.code, p1.getUInt8(-1));
			Assert.equals('b'.code, p2.getUInt8(-1));
			for (i in 0...4)
				Assert.equals(i, p3.getInt32(i*4-1));
			for (i in 0...4)
			{
				var val = 1 + (i + 1)/10;
				Assert.equals(val, p4.getFloat64(i*8-1));
			}
			for (i in 0...1000)
				Assert.equals(i, p5.getInt32(i*4-1));
		});
	}

	private function doSomeWork()
	{
		// this function is here to add some strain on the GC. We force GC to make a collection also, if we can
#if neko
		var j = 0;
#else
		for (j in 0...100)
#end
		{
			var arr1 = [],
					arr2 = new Map();
			for (i in 0...100000)
			{
				arr1.push(i);
				arr2[i] = i+"";
				}
			// please optimizer don't optimize everything away
			if (arr1[j] != j || arr2[j] != j + '')
			{
				Assert.fail();
			}
			if (j % 10 == 0)
			{
#if cs
				cs.system.GC.Collect();
				cs.system.GC.WaitForPendingFinalizers();
#elseif cpp
				cpp.vm.Gc.run(true);
				cpp.vm.Gc.compact();
#elseif java
				java.vm.Gc.run(true);
				java.vm.Gc.run(true);
#elseif neko
				neko.vm.Gc.run(true);
				neko.vm.Gc.run(true);
#end
			}
		}
	}

	private function getTrue()
	{
		return true;
	}

	function bufTest(buf:indian.Buffer, size:Int)
	{
		for (i in 0...size)
			buf.setUInt8(i,i);
		for (i in 0...size)
			Assert.equals(buf.getUInt8(i),i);
	}

	function bufTest16(buf:indian.Buffer, size:Int)
	{
		for (i in 0...(size >> 1))
			buf.setUInt16(i<<1,i);
		for (i in 0...(size >> 1))
			Assert.equals(buf.getUInt16(i<<1),i);
	}
}
