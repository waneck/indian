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
			autofree(buf = alloc(256), {
				bufTest(buf,256);
				throw "exc";
			});
		}
		catch(e:Dynamic)
		{
			didThrow = true;
		}
		Assert.isTrue(didThrow);

		autofree(buf = stackalloc(256), buf2 = stackalloc(x), buf3 = alloc(256), buf4 = alloc(x), {
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
				arr1 = [1,2,3,4],
				arr2 = haxe.ds.Vector.fromArrayCopy([1.1,1.2,1.3,1.4]);
		str2.add('b');
		str2.add('c');
		var str2 = str2.toString();
		pin(p1 = ptr(str), p2 = ptr(str2), p3 = ptr(arr1), p4 = ptr(arr2), {
#if (cs || cpp)
			Assert.equals('a'.code, p1.getUInt8(0));
#else
			$type(p1);
			$type(p2);
			$type(p3);
			$type(p4);
#end
		});
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
