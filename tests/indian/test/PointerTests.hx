package indian.test;
import utest.Assert;
import indian.*;
import indian.types.*;

@:unsafe class PointerTests
{

	public function new()
	{
	}

	public function test_basic_types()
	{
		Assert.equals(4,IntPtr.byteSize);
		Assert.equals(2,IntPtr.power);
		Assert.equals(8,FloatPtr.byteSize);
		Assert.equals(3,FloatPtr.power);

		var ptr:Ptr<Int> = alloc(10*4);
		for (i in 0...10)
			ptr[i] = (1 << 24) + i;
		for (i in 0...10)
			Assert.equals(ptr[i],(1 << 24) + i);
		checkCanary(ptr,10*4);
		Indian.free(ptr);

		var ptr:Ptr<Float> = alloc(10*8);
		for (i in 0...10)
			ptr[i] = (1 << 31) * 10.5 + i;
		for (i in 0...10)
			Assert.equals(ptr[i],(1 << 31) * 10.5 + i);
		var ptr2 = ptr;
		for (i in 0...10)
			Assert.equals(ptr2++.dereference(),(1 << 31) * 10.5 + i);
		checkCanary(ptr,10*8);
		Indian.free(ptr);

		var ptr:Ptr<Single> = alloc(10*4);
		for (i in 0...10)
			ptr[i] = i + i / 10;
		for (i in 0...10)
			Assert.floatEquals(ptr[i],i + i / 10);
		var ptr2 = ptr;
		for (i in 0...10)
			Assert.floatEquals(ptr2++.dereference(),i + i / 10);
		checkCanary(ptr,10*4);
		Indian.free(ptr);

		var ptr:Ptr<UInt16> = alloc(10*2);
		for (i in 0...10)
			ptr[i] = (1 << 8) + i;
		for (i in 0...10)
			Assert.equals(ptr[i],(1 << 8) + i);
		var ptr2 = ptr;
		for (i in 0...10)
			Assert.equals(ptr2++.dereference(),(1 << 8) + i);
		checkCanary(ptr,10*2);
		Indian.free(ptr);

		var ptr:Ptr<UInt8> = alloc(10);
		for (i in 0...10)
			ptr[i] = (1 << 8) + i;
		for (i in 0...10)
			Assert.equals(ptr[i],i);
		var ptr2 = ptr;
		for (i in 0...10)
			Assert.equals(ptr2++.dereference(),i);
		var ptr3:Ptr<Int> = ptr.asAny();
		if (Buffer.littleEndian)
			Assert.equals(0x03020100, ptr3[0]);
		else
			Assert.equals(0x00010203, ptr3[0]);
		checkCanary(ptr,10);
		Indian.free(ptr);

		var ptr:Ptr<Bool> = alloc(10);
		for (i in 0...10)
			ptr[i] = (i & 6) == 0;
		for (i in 0...10)
			Assert.equals(ptr[i],(i&6) == 0);
		checkCanary(ptr,10);
		Indian.free(ptr);

		Assert.notEquals(0, ptr.asAny().toInt());
		Assert.isTrue(0 != ptr.asAny().toInt64());
	}

	public function test_ptr_ptr()
	{
		trace(PtrPtr.byteSize);
		trace(PtrPtr.power);
		var ptr:Ptr<Int> = alloc(32 * 4);
		for (i in 0...32)
			ptr[i] = i;

		var ptrptr:Ptr<Ptr<Int>> = alloc(4 * AnyPtr.size);
		for (i in 0...4)
			ptrptr[i] = ptr + i * 2;

		Assert.equals(0,ptrptr[0][0]);
		Assert.equals(1,ptrptr[0][1]);
		Assert.equals(2,ptrptr[0][2]);
		Assert.equals(2,ptrptr[1][0]);
		Assert.equals(3,ptrptr[1][1]);
		Assert.equals(4,ptrptr[1][2]);
		Assert.equals(4,ptrptr[2][0]);
		Assert.equals(6,ptrptr[3][0]);
		Assert.equals(7,ptrptr[3][1]);
		Assert.equals(8,ptrptr[3][2]);

		var pp = ptrptr;
		for (i in 0...4)
		{
			Assert.equals(i*2,pp++.dereference().dereference());
		}
		pp = ptrptr;
		for (i in 0...4)
		{
			var pp = pp++;
			pp[0] += 1;
			Assert.equals(i*2+1,pp.dereference().dereference());
		}

		Indian.free(ptr);
		Indian.free(ptrptr);
	}

	private static function alloc(size:Int)
	{
		var size = size + 16;
		var ret = Indian.alloc(size);
		ret.set(0,0xff,size);
		return ret;
	}

	private static function getCanary(ptr:Buffer,size:Int):Bool
	{
		for (i in 0...16)
		{
			if (ptr.getUInt8(size+i) != 0xFF)
				return false;
		}
		return true;
	}

	private static function checkCanary(ptr:Buffer,size:Int)
	{
		Assert.isTrue(getCanary(ptr,size));
	}

}

typedef IntPtr = Ptr<Int>;
typedef FloatPtr = Ptr<Float>;
typedef PtrPtr = Ptr<IntPtr>;

