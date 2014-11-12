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

	public function test_struct_offset()
	{
		var ptr:POffset1 = Indian.alloc(256);
		ptr.i8 = cast 1;
		ptr.i16 = cast 2;
		ptr.i32 = 3;
		ptr.i32_2 = 4;
		ptr.i64 = Int64.make(0,2);
		ptr.i8_2 = cast 6;
		ptr.f = 7.7;
		ptr.i8_3 = cast 8;
		ptr.s = 9.9;

		var buf = ptr.asBuffer();
		equals(0,Offset1.offset_i8);
		equals(1,buf.getUInt8(0));

		equals(2,Offset1.offset_i16);
		equals(2,buf.getUInt16(2));

		equals(4,Offset1.offset_i32);
		equals(3,buf.getInt32(4));

		equals(8,Offset1.offset_i32_2);
		equals(4,buf.getInt32(8));

		if (Infos.nix32)
		{
			equals(12,Offset1.offset_i64);
			isTrue(buf.getInt64(12).eq(Int64.make(0,2)));

			equals(20,Offset1.offset_i8_2);
			equals(6,buf.getUInt8(20));

			equals(24,Offset1.offset_f);
			equals(7.7,buf.getFloat64(24));

			equals(32,Offset1.offset_i8_3);
			equals(8,buf.getUInt8(32));

			equals(36,Offset1.offset_s);
			floatEquals(9.9,buf.getFloat32(36));
		} else {
			equals(16,Offset1.offset_i64);
			isTrue(buf.getInt64(16).eq(Int64.make(0,2)));
			trace(buf.getInt64(16).toString());

			equals(24,Offset1.offset_i8_2);
			equals(6,buf.getUInt8(24));

			equals(32,Offset1.offset_f);
			equals(7.7,buf.getFloat64(32));

			equals(40,Offset1.offset_i8_3);
			equals(8,buf.getUInt8(40));

			equals(44,Offset1.offset_s);
			floatEquals(9.9,buf.getFloat32(44));
		}

		Indian.free(ptr);
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

typedef POffset1 = Ptr<Offset1>;
