package indian.test;
import utest.Assert;
import indian.*;

@:unsafe class PointerTests
{

	public function new()
	{
	}

	public function test_basic()
	{
		Assert.equals(4,IntPtr.byteSize);
		Assert.equals(2,IntPtr.power);

		var ptr:Ptr<Int> = allocC(10*4);
		for (i in 0...10)
			ptr[i] = (1 << 24) + i;
		for (i in 0...10)
			Assert.equals(ptr[i],(1 << 24) + i);
		checkCanary(ptr,10*4);
		Indian.free(ptr);
	}

	private static function allocC(size:Int)
	{
		var size = size + 16;
		var ret = Indian.alloc(size);
		ret.set(0,0xff,size);
		return ret;
	}

	private static function checkCanary(ptr:Buffer,size:Int)
	{
		for (i in 0...16)
		{
			Assert.equals(0xff, ptr.getUInt8(size+i));
		}
	}

}

typedef IntPtr = Ptr<Int>;
