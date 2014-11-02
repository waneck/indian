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
