package indian.test;
import utest.Assert;
import utest.Assert.*;
import indian.*;
import indian.types.*;

@:unsafe class StructTests
{
	public function new()
	{
	}

#if (cs || cpp)
	public function test_struct_plain()
	{
		var s = new Offset1();
		s.i8 = cast 1;
		s.i16 = cast 2;
		s.i32 = 3;
		s.i32_2 = 4;
		s.i64 = Int64.make(0,2);
		s.i8_2 = cast 6;
		s.f = 7.7;
		s.i8_3 = cast 8;
		s.s = 9.9;

		var ptr = Indian.addr(s);
		equals(ptr.i8, cast 1);
		equals(ptr.i16, cast 2);
		equals(ptr.i32, 3);
		equals(ptr.i32_2, 4);
		isTrue(ptr.i64.eq(Int64.make(0,2)));
		equals(ptr.i8_2, cast 6);
		equals(ptr.f, 7.7);
		equals(ptr.i8_3, cast 8);
		floatEquals(ptr.s, 9.9);
	}
#end

	public function test_struct_offset1()
	{
		var len = Offset1.bytesize * 10 + 4;
		var ptr:POffset1 = Indian.alloc(len);
		var tofree = ptr;
		var buf = ptr.asBuffer();
		for (i in 0...len)
			buf.setUInt8(i,0xff);

		for (i in 0...10)
		{
			ptr.i8 = cast 1*i;
			ptr.i16 = cast 2*i;
			ptr.i32 = 3*i;
			ptr.i32_2 = 4*i;
			ptr.i64 = Int64.make(i,5);
			ptr.i8_2 = cast 6*i;
			ptr.f = 7.7*i;
			ptr.i8_3 = cast 8*i;
			ptr.s = 9.9*i;
			ptr++;
		}
		ptr = tofree;
		for (i in 0...10)
		{
			var buf = ptr.asBuffer();
			equals(0,Offset1.offset_i8);
			equals(1*i,buf.getUInt8(0));

			equals(2,Offset1.offset_i16);
			equals(2*i,buf.getUInt16(2));

			equals(4,Offset1.offset_i32);
			equals(3*i,buf.getInt32(4));

			equals(8,Offset1.offset_i32_2);
			equals(4*i,buf.getInt32(8));

			if (Infos.nix32)
			{
				equals(12,Offset1.offset_i64);
				isTrue(buf.getInt64(12).eq(Int64.make(i,5)));

				equals(20,Offset1.offset_i8_2);
				equals(6*i,buf.getUInt8(20));

				equals(24,Offset1.offset_f);
				equals(7.7*i,buf.getFloat64(24));

				equals(32,Offset1.offset_i8_3);
				equals(8*i,buf.getUInt8(32));

				equals(36,Offset1.offset_s);
				floatEquals(9.9*i,buf.getFloat32(36));
			} else {
				equals(16,Offset1.offset_i64);
				isTrue(buf.getInt64(16).eq(Int64.make(i,5)));

				equals(24,Offset1.offset_i8_2);
				equals(6*i,buf.getUInt8(24));

				equals(32,Offset1.offset_f);
				equals(7.7*i,buf.getFloat64(32));

				equals(40,Offset1.offset_i8_3);
				equals(8*i,buf.getUInt8(40));

				equals(44,Offset1.offset_s);
				floatEquals(9.9*i,buf.getFloat32(44));
			}
			ptr += 1;
		}
		var dif = ptr.asAny().toIntPtr() - tofree.asAny().toIntPtr();
		if (Infos.nix32)
		{
			equals(40 * 10, dif.toInt());
		} else {
			equals(48 * 10, dif.toInt());
		}

		for (i in (Offset1.bytesize * 10)...len)
			equals(buf.getUInt8(i), 0xff);
		Indian.free(tofree);
	}

	public function test_struct_offset2()
	{
		var len = Offset2.bytesize * 10 + 4;
		var ptr:POffset2 = Indian.alloc(len);
		var tofree = ptr;
		var buf = ptr.asBuffer();
		for (i in 0...len)
			buf.setUInt8(i,0xff);

		for (i in 0...10)
		{
			ptr.i8 = cast i - 1;

			ptr.off1.i8 = cast 1*i;
			ptr.off1.i16 = cast 2*i;
			ptr.off1.i32 = 3*i;
			ptr.off1.i32_2 = 4*i;
			ptr.off1.i64 = Int64.make(i,5);
			ptr.off1.i8_2 = cast 6*i;
			ptr.off1.f = 7.7*i;
			ptr.off1.i8_3 = cast 8*i;
			ptr.off1.s = 9.9*i;

			ptr.i8_2 = cast i + 2;

			ptr++;
		}
		ptr = tofree;
		for (i in 0...10)
		{
			var buf = ptr.asBuffer();
			equals(0,Offset2.offset_i8);
			equals((i-1) & 0xFF,buf.getUInt8(0));


			equals(ptr.off1.i8, cast 1*i);
			equals(ptr.off1.i16, cast 2*i);
			equals(ptr.off1.i32, 3*i);
			equals(ptr.off1.i32_2, 4*i);
			isTrue(ptr.off1.i64.eq(Int64.make(i,5)));
			equals(ptr.off1.i8_2, cast 6*i);
			floatEquals(ptr.off1.f, 7.7*i);
			equals(ptr.off1.i8_3, cast 8*i);
			floatEquals(ptr.off1.s, 9.9*i);

			if (Infos.is64)
			{
				equals(8, Offset2.offset_off1);
				equals(Offset2.offset_i8_2, 56);
			} else if (Infos.nix32)
			{
				equals(4, Offset2.offset_off1);
				equals(Offset2.offset_i8_2, 44);
			} else {
				equals(4, Offset2.offset_off1);
				equals(Offset2.offset_i8_2, 52);
			}
			ptr++;
		}
		var dif = ptr.asAny().toIntPtr() - tofree.asAny().toIntPtr();
		if (Infos.is64)
			equals(64 * 10, dif.toInt());
		else if (Infos.nix32)
			equals(48 * 10, dif.toInt());
		else
			equals(56 * 10, dif.toInt());

		for (i in (Offset2.bytesize * 10)...len)
			equals(0xff, buf.getUInt8(i));
		Indian.free(tofree);
	}

	public function test_linked_list()
	{
		var ll:PLinkedList = null;
		for (i in 0...10)
		{
			var ll2:PLinkedList = Indian.alloc(LinkedList.bytesize);
			ll2.next = ll;
			ll2.val = cast i;
			ll = ll2;
		}

		var i = 10;
		while (ll != null)
		{
			equals(ll.val, --i);
			ll = ll.next;
		}
		equals(i,0);
	}
}

typedef Offset1 = Struct<{
	i8:UInt8,			// off 0
	i16:UInt16,		// off 2
	i32:Int,			// off 4
	i32_2:Int,		// off 8
	i64:Int64,		// off 12 (nix+32) / 16
	i8_2:UInt8,		// off 20 / 24
	f:Float,			// off 24 / 32
	i8_3:UInt8,		// off 32 / 40
	s:Single,			// off 36 / 44
}>;
//total structure: 40 / 48

typedef POffset1 = Ptr<Offset1>;

// This will test a struct inside a struct
typedef Offset2 = Struct<{
	i8:UInt8,     // off 0
	off1:Offset1, // off 4 (32) / 8 (64)
	i8_2:UInt8      // off 44 (lin32) / 52 (32) / 56 (64)
}>;
//total structure: 48 (lin32) / 56 (32) / 64 (64)

typedef POffset2 = Ptr<Offset2>;

typedef LinkedList = Struct<{
	val:UInt16,           // off 0
	next:PLinkedList  // off 4 (32) / 8
}>;
//total structure: 8(32) / 16(64)

typedef PLinkedList = Ptr<LinkedList>;

//test structs with pointers
//test structs with IntPtr
//test recursive structs
//test setting a struct that is contained in another struct
