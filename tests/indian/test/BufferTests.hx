package indian.test;
import indian.Buffer in RawMem;
import utest.Assert;

@:unsafe class BufferTests
{
	public function new()
	{
	}

	private function alloc(len:Int):RawMem
	{
		return indian.Memory.alloc(len);
	}

	private function free(r:RawMem,?pos:haxe.PosInfos):Void
	{
		return indian.Memory.free(r);
	}
	//tests from https://github.com/inexorabletash/polyfill/blob/master/tests/typedarray_tests.js
	//Copyright (C) 2010 Linden Research, Inc. Originally published at: https://bitbucket.org/lindenlab/llsd/
	private function stricterEqual(actual:Float, expected:Float, message:String, ?pos:haxe.PosInfos)
	{
		message = '($message) Expected $expected. Got $actual';
		if (Math.isNaN(expected))
		{
			Assert.isTrue(Math.isNaN(actual) && Math.isFinite(expected) == Math.isFinite(actual) && (actual > 0) == (expected > 0), message, pos);
		} else {
			Assert.floatEquals(expected, actual, message, pos);
		}
	}

	private function ui8equal(mem:RawMem, arr:Array<Int>, ?msg:String, ?pos:haxe.PosInfos)
	{
		if (msg == null) msg = "";
		for (i in 0...arr.length)
		{
			var msg = '($msg) Expected ${arr[i]}; got ${mem.getUInt8(i)} for index $i - $arr';
			Assert.equals(arr[i], mem.getUInt8(i), msg, pos);
		}
		// var msg = '($msg) Length mismatch: Expected ${arr.length}; got ${mem.byteLength}.';
		// Assert.equals(arr.length, mem.byteLength, msg, pos);
	}

	public function test_conversions()
	{
		var arr = alloc(4);
		arr.setUInt8(0,1);
		arr.setUInt8(1,2);
		arr.setUInt8(2,3);
		arr.setUInt8(3,4);

		ui8equal(arr, [1,2,3,4]);
		arr.setUInt16(0,0xFFFF);
		ui8equal(arr, [0xff,0xff,3,4]);
		arr.setUInt16(2,0xEEEE);
		ui8equal(arr, [0xff,0xff,0xee,0xee]);
		arr.setInt32(0,0x11111111);
		Assert.equals(arr.getUInt16(0), 0x1111);
		Assert.equals(arr.getUInt16(2), 0x1111);
		ui8equal(arr, [0x11,0x11,0x11,0x11]);
		free(arr);
	}

	public function test_signed_unsigned()
	{
		var mem = alloc(4);
		mem.setUInt8(0,123);
		Assert.equals(123, mem.getUInt8(0));
		mem.setUInt8(0,161);
		Assert.equals(161, mem.getUInt8(0));
		mem.setUInt8(0,-120);
		Assert.equals(136, mem.getUInt8(0));
		mem.setUInt8(0,-1);
		Assert.equals(0xff, mem.getUInt8(0));

		mem.setUInt16(0,3210);
		Assert.equals(3210, mem.getUInt16(0));
		mem.setUInt16(0,49232);
		Assert.equals(49232, mem.getUInt16(0));
		mem.setUInt16(0,-16384);
		Assert.equals(49152, mem.getUInt16(0));
		mem.setUInt16(0,-1);
		Assert.equals(0xFFFF, mem.getUInt16(0));
		free(mem);
	}

	public function test_float32_unpack()
	{
		// var littleEndian = alloc(2).isLittleEndian();
		var littleEndian = true;
		function fromBytes(arr:Array<Int>):Float
		{
			var ret = alloc(arr.length);
			if (!littleEndian)
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[i]);
			else
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[3-i]);
			var r = ret.getFloat32(0);
			free(ret);
			return r;
		}
		stricterEqual(fromBytes([0xff, 0xff, 0xff, 0xff]), Math.NaN, 'Q-NaN');
		stricterEqual(fromBytes([0xff, 0xc0, 0x00, 0x01]), Math.NaN, 'Q-NaN');

		stricterEqual(fromBytes([0xff, 0xc0, 0x00, 0x00]), Math.NaN, 'Indeterminate');

		stricterEqual(fromBytes([0xff, 0xbf, 0xff, 0xff]), Math.NaN, 'S-NaN');
		stricterEqual(fromBytes([0xff, 0x80, 0x00, 0x01]), Math.NaN, 'S-NaN');

		stricterEqual(fromBytes([0xff, 0x80, 0x00, 0x00]), Math.NEGATIVE_INFINITY, '-Infinity');

		stricterEqual(fromBytes([0xff, 0x7f, 0xff, 0xff]), -3.4028234663852886E+38, '-Normalized');
		stricterEqual(fromBytes([0x80, 0x80, 0x00, 0x00]), -1.1754943508222875E-38, '-Normalized');
		stricterEqual(fromBytes([0xff, 0x7f, 0xff, 0xff]), -3.4028234663852886E+38, '-Normalized');
		stricterEqual(fromBytes([0x80, 0x80, 0x00, 0x00]), -1.1754943508222875E-38, '-Normalized');

		// TODO: Denormalized values fail on Safari on iOS/ARM
		stricterEqual(fromBytes([0x80, 0x7f, 0xff, 0xff]), -1.1754942106924411E-38, '-Denormalized');
		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x01]), -1.4012984643248170E-45, '-Denormalized');

		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x00]), 0, '-0');
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x00]), 0, '+0');

		// TODO: Denormalized values fail on Safari on iOS/ARM
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x01]), 1.4012984643248170E-45, '+Denormalized');
		stricterEqual(fromBytes([0x00, 0x7f, 0xff, 0xff]), 1.1754942106924411E-38, '+Denormalized');

		stricterEqual(fromBytes([0x00, 0x80, 0x00, 0x00]), 1.1754943508222875E-38, '+Normalized');
		stricterEqual(fromBytes([0x7f, 0x7f, 0xff, 0xff]), 3.4028234663852886E+38, '+Normalized');

		stricterEqual(fromBytes([0x7f, 0x80, 0x00, 0x00]), Math.POSITIVE_INFINITY, '+Infinity');

		stricterEqual(fromBytes([0x7f, 0x80, 0x00, 0x01]), Math.NaN, 'S+NaN');
		stricterEqual(fromBytes([0x7f, 0xbf, 0xff, 0xff]), Math.NaN, 'S+NaN');

		stricterEqual(fromBytes([0x7f, 0xc0, 0x00, 0x00]), Math.NaN, 'Q+NaN');
		stricterEqual(fromBytes([0x7f, 0xff, 0xff, 0xff]), Math.NaN, 'Q+NaN');
	}

	public function test_float32_pack()
	{
		// var littleEndian = alloc(2).isLittleEndian();
		var littleEndian = true;
		function toBytes(v:Float):RawMem
		{
			var ret = alloc(4);
			ret.setFloat32(0,v);
			return ret;
		}
		var ui8equal = littleEndian ? function(b:RawMem, arr:Array<Int>, str:String, ?pos:haxe.PosInfos)
		{
			arr.reverse();
			return ui8equal(b,arr,str,pos);
		} : ui8equal;

		ui8equal(toBytes(Math.NEGATIVE_INFINITY), [0xff, 0x80, 0x00, 0x00], '-Infinity');

		ui8equal(toBytes(-3.4028235677973366e+38), [0xff, 0x80, 0x00, 0x00], '-Overflow');
		ui8equal(toBytes(-3.402824E+38), [0xff, 0x80, 0x00, 0x00], '-Overflow');

		ui8equal(toBytes(-3.4028234663852886E+38), [0xff, 0x7f, 0xff, 0xff], '-Normalized');
		ui8equal(toBytes(-1.1754943508222875E-38), [0x80, 0x80, 0x00, 0x00], '-Normalized');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(-1.1754942106924411E-38), [0x80, 0x7f, 0xff, 0xff], '-Denormalized');
		ui8equal(toBytes(-1.4012984643248170E-45), [0x80, 0x00, 0x00, 0x01], '-Denormalized');

		ui8equal(toBytes(-7.006492321624085e-46), [0x80, 0x00, 0x00, 0x00], '-Underflow');

		// unsupported -0
		// ui8equal(toBytes(-0), [0x80, 0x00, 0x00, 0x00], '-0');
		ui8equal(toBytes(0), [0x00, 0x00, 0x00, 0x00], '+0');

		ui8equal(toBytes(7.006492321624085e-46), [0x00, 0x00, 0x00, 0x00], '+Underflow');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(1.4012984643248170E-45), [0x00, 0x00, 0x00, 0x01], '+Denormalized');
		ui8equal(toBytes(1.1754942106924411E-38), [0x00, 0x7f, 0xff, 0xff], '+Denormalized');

		ui8equal(toBytes(1.1754943508222875E-38), [0x00, 0x80, 0x00, 0x00], '+Normalized');
		ui8equal(toBytes(3.4028234663852886E+38), [0x7f, 0x7f, 0xff, 0xff], '+Normalized');

		ui8equal(toBytes(3.402824E+38), [0x7f, 0x80, 0x00, 0x00], '+Overflow');
		ui8equal(toBytes(3.402824E+38), [0x7f, 0x80, 0x00, 0x00], '+Overflow');
		ui8equal(toBytes(Math.POSITIVE_INFINITY), [0x7f, 0x80, 0x00, 0x00], '+Infinity');

		// Allow any NaN pattern (exponent all 1's, fraction non-zero)
		// var nanbytes = toBytes(Math.NaN),
		// 		sign = extractbits(nanbytes, 31, 31),
		// 		exponent = extractbits(nanbytes, 23, 30),
		// 		fraction = extractbits(nanbytes, 0, 22);
		// ok(exponent === 255 && fraction !== 0, 'NaN');
	}

	public function test_float64_unpack()
	{
		// var littleEndian = alloc(2).isLittleEndian();
		var littleEndian = true;
		function fromBytes(arr:Array<Int>):Float
		{
			var ret = alloc(arr.length);
			if (!littleEndian)
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[i]);
			else
				for (i in 0...arr.length)
					ret.setUInt8(i,arr[7-i]);
			var r = ret.getFloat64(0);
			free(ret);
			return r;
		}

		stricterEqual(fromBytes([0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'Q-NaN');
		stricterEqual(fromBytes([0xff, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), Math.NaN, 'Q-NaN');

		stricterEqual(fromBytes([0xff, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.NaN, 'Indeterminate');

		stricterEqual(fromBytes([0xff, 0xf7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'S-NaN');
		stricterEqual(fromBytes([0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), Math.NaN, 'S-NaN');

		stricterEqual(fromBytes([0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.NEGATIVE_INFINITY, '-Infinity');

		stricterEqual(fromBytes([0xff, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), -1.7976931348623157E+308, '-Normalized');
		stricterEqual(fromBytes([0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), -2.2250738585072014E-308, '-Normalized');

		// TODO: Denormalized values fail on Safari iOS/ARM
		stricterEqual(fromBytes([0x80, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), -2.2250738585072010E-308, '-Denormalized');
		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), -4.9406564584124654E-324, '-Denormalized');

		stricterEqual(fromBytes([0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), -0, '-0');
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 0, '+0');

		// TODO: Denormalized values fail on Safari iOS/ARM
		stricterEqual(fromBytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), 4.9406564584124654E-324, '+Denormalized');
		stricterEqual(fromBytes([0x00, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), 2.2250738585072010E-308, '+Denormalized');

		stricterEqual(fromBytes([0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), 2.2250738585072014E-308, '+Normalized');
		stricterEqual(fromBytes([0x7f, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), 1.7976931348623157E+308, '+Normalized');

		stricterEqual(fromBytes([0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.POSITIVE_INFINITY, '+Infinity');

		stricterEqual(fromBytes([0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]), Math.NaN, 'S+NaN');
		stricterEqual(fromBytes([0x7f, 0xf7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'S+NaN');

		stricterEqual(fromBytes([0x7f, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), Math.NaN, 'Q+NaN');
		stricterEqual(fromBytes([0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]), Math.NaN, 'Q+NaN');
	}

	public function test_float64_pack()
	{
		// var littleEndian = alloc(2).isLittleEndian();
		var littleEndian = true;
		function toBytes(v:Float):RawMem
		{
			var ret = alloc(8);
			ret.setFloat64(0,v);
			return ret;
		}
		var ui8equal = littleEndian ? function(b:RawMem, arr:Array<Int>, str:String, ?pos:haxe.PosInfos)
		{
			arr.reverse();
			return ui8equal(b,arr,str,pos);
		} : ui8equal;

		ui8equal(toBytes(Math.NEGATIVE_INFINITY), [0xff, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '-Infinity');

		ui8equal(toBytes(-1.7976931348623157E+308), [0xff, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '-Normalized');
		ui8equal(toBytes(-2.2250738585072014E-308), [0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '-Normalized');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(-2.2250738585072010E-308), [0x80, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '-Denormalized');
		ui8equal(toBytes(-4.9406564584124654E-324), [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01], '-Denormalized');

		// unsupported -0
		// ui8equal(toBytes(-0), [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '-0');
		ui8equal(toBytes(0), [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '+0');

		// TODO: Denormalized values fail on Safari iOS/ARM
		ui8equal(toBytes(4.9406564584124654E-324), [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01], '+Denormalized');
		ui8equal(toBytes(2.2250738585072010E-308), [0x00, 0x0f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '+Denormalized');

		ui8equal(toBytes(2.2250738585072014E-308), [0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '+Normalized');
		ui8equal(toBytes(1.7976931348623157E+308), [0x7f, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff], '+Normalized');

		ui8equal(toBytes(Math.POSITIVE_INFINITY), [0x7f, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], '+Infinity');
	}

	public function test_strlen()
	{
		var vec = alloc(21);
		for ( i in 0...20 )
			vec.setUInt8(i,'0'.code);
		for (i in 0...20)
		{
			vec.setUInt8(20-i, 0);
			Assert.equals(RawMem.strlen(vec,0), 20-i);
			Assert.equals(RawMem.strlen(vec,19-i), 1);
		}
		free(vec);
	}

	public function test_blit()
	{
		var vec3 = alloc(7), vec4 = alloc(5);
		for (i in 0...5)
			vec4.setUInt8(i,0);
		for (i in 0...7)
			vec3.setUInt8(i,i);

		RawMem.blit(vec3, 0, vec4, 1, 3);
		Assert.equals(vec4.getUInt8(0), 0);
		Assert.equals(vec4.getUInt8(1), 0);
		Assert.equals(vec4.getUInt8(2), 1);
		Assert.equals(vec4.getUInt8(3), 2);
		Assert.equals(vec4.getUInt8(4), 0);

		RawMem.blit(vec3, 0, vec4, 0, 5);
		Assert.equals(vec4.getUInt8(0), 0);
		Assert.equals(vec4.getUInt8(1), 1);
		Assert.equals(vec4.getUInt8(2), 2);
		Assert.equals(vec4.getUInt8(3), 3);
		Assert.equals(vec4.getUInt8(4), 4);

		RawMem.blit(vec4, 1, vec3, 0, 4);
		Assert.equals(vec3.getUInt8(0), 1);
		Assert.equals(vec3.getUInt8(1), 2);
		Assert.equals(vec3.getUInt8(2), 3);
		Assert.equals(vec3.getUInt8(3), 4);
		Assert.equals(vec3.getUInt8(4), 4);
		Assert.equals(vec3.getUInt8(5), 5);
		Assert.equals(vec3.getUInt8(6), 6);

		RawMem.blit(vec3, 3, vec3, 0, 4);
		Assert.equals(vec3.getUInt8(0), 4);
		Assert.equals(vec3.getUInt8(1), 4);
		Assert.equals(vec3.getUInt8(2), 5);
		Assert.equals(vec3.getUInt8(3), 6);
		Assert.equals(vec3.getUInt8(4), 4);
		Assert.equals(vec3.getUInt8(5), 5);
		Assert.equals(vec3.getUInt8(6), 6);

		var vec5 = alloc(6);
		vec5.setUInt8(0,1);
		vec5.setUInt8(1,1);
		vec5.setUInt8(2,2);
		vec5.setUInt8(3,2);
		vec5.setUInt8(4,3);
		vec5.setUInt8(5,3);

		// test overlapping
		RawMem.blit(vec5,0, vec5,2, 4);
		Assert.equals(vec5.getUInt8(0), 1);
		Assert.equals(vec5.getUInt8(1), 1);
		Assert.equals(vec5.getUInt8(2), 1);
		Assert.equals(vec5.getUInt8(3), 1);
		Assert.equals(vec5.getUInt8(4), 2);
		Assert.equals(vec5.getUInt8(5), 2);

		//test large portions of memory
		function getMem()
		{
			var mem = alloc(255);
			for (i in 0...255)
				mem.setUInt8(i,i);
			return mem;
		}

		var src = getMem();

		// test different src/dest alignments
		for (i in 0...16)
			for (j in 0...16)
			{
				var dest = getMem();
				RawMem.blit(src,100 + i, dest, 50 + j, 100);
				for (k in 0...255)
				{
					if (k >= (50 + j) && k < (150 + j))
					{
						if (src.getUInt8(100+i+ (k - (50 + j))) != dest.getUInt8(k))
							Assert.fail('For index $k, of i $i and j $j, expected ${100+i+ (k - (50 + j))}; got ${dest.getUInt8(k)}');
					} else {
						if (dest.getUInt8(k) != k)
							Assert.equals(dest.getUInt8(k),k);
					}
				}
			}

		free(vec3); free(vec4); free(vec5);
	}

	public function test_compare()
	{
		function getMem()
		{
			var mem = alloc(16);
			for (i in 0...16)
				mem.setUInt8(i,i+0x70);
			return mem;
		}

		var src = getMem();
		for (result in [-3,-2,-1,0,1,2,3])
		{
			for (i in 0...16)
			{
				var dest = getMem();
				dest.setUInt8(i, dest.getUInt8(i) + result);
				if (result < 0)
				{
					Assert.isTrue(RawMem.compare(src,0,dest,0,16) > 0);
					if (RawMem.compare(src,0,dest,0,16) <= 0)
						trace(RawMem.compare(src,0,dest,0,16));
					Assert.isTrue(RawMem.compare(dest,0,src,0,16) < 0);
					Assert.isTrue(RawMem.compare(dest,0,src,0,i+1) < 0);
					if (i > 0)
						dest.setUInt8(i-1, dest.getUInt8(i) - result);
					Assert.isTrue(RawMem.compare(src,i,dest,i,16 - i) > 0);
				} else if (result == 0) {
					Assert.equals(RawMem.compare(src,0,dest,0,16), 0);
					Assert.equals(RawMem.compare(dest,0,src,0,16), 0);
				} else {
					Assert.isTrue(RawMem.compare(src,0,dest,0,16) < 0);
					Assert.isTrue(RawMem.compare(dest,0,src,0,16) > 0);
					Assert.isTrue(RawMem.compare(dest,0,src,0,i+1) > 0);
					if (i > 0)
						dest.setUInt8(i-1, dest.getUInt8(i) - result);
					Assert.isTrue(RawMem.compare(src,i,dest,i,16 - i) < 0);
				}
				free(dest);
			}
		}
	}

	public function test_int32_roundtrips()
	{
		var mem = alloc(4);
		var data = [
			0,
			1,
			-1,
			123,
			-456,
			0x80000000,
			0x7fffffff,
			0x12345678,
			0x87654321
		];

		for (d in data)
		{
			mem.setInt32(0,d);
			Assert.equals(mem.getInt32(0), d);
		}
		free(mem);
	}

	public function test_int16_roundtrips()
	{
		var mem = alloc(2);
		var data = [
			0,
			1,
				-1,
			123,
				-456,
			0xffff8000,
			0x00007fff,
			0x00001234,
			0xffff8765
		];

		for (d in data)
		{
			mem.setUInt16(0,d);
			if (d < 0)
				Assert.equals(mem.getUInt16(0), d & 0xFFFF);
			else
				Assert.equals(mem.getUInt16(0), d);
		}

		free(mem);
	}

	public function test_int8_roundtrips()
	{
		var mem = alloc(1);
		var data = [
			0,
			1,
				-1,
			123,
				-45,
			0xffffff80,
			0x0000007f,
			0x00000012,
			0xffffff87
		];

		for (d in data)
		{
			mem.setUInt8(0,d);
			if (d < 0)
				Assert.equals(mem.getUInt8(0), d & 0xFF);
			else
				Assert.equals(mem.getUInt8(0), d);
		}
		free(mem);
	}

	// static inline var LN2 = taurine.math.MacroMath.reduce(Math.log(2));
	static var LN2 = Math.log(2);

	public function test_float32_roundtrips()
	{
		var mem = alloc(4);
		var data = [
			0,
			1,
				-1,
			123,
				-456,

			1.2,
			1.23,
			1.234,

			1.234e-30,
			1.234e-20,
			1.234e-10,
			1.234e10,
			1.234e20,
			1.234e30,

			3.1415,
			6.0221415e+23,
			6.6260693e-34,
			6.67428e-11,
			299792458,

			0,
				-0,
			Math.POSITIVE_INFINITY,
			Math.NEGATIVE_INFINITY,
			Math.NaN
		];

		//Round p to n binary places of binary
		function precision(n,p) {
			if (p >= 52 || Math.isNaN(n) || n == 0 || !Math.isFinite(n))
			{
				return n;
			} else {
				var m = Math.pow(2, p - Math.floor(Math.log(n) / LN2));
				return Math.round(n * m) / m;
			}
		}

		inline function single(n) return precision(n,23);

		for (d in data)
		{
			mem.setFloat32(0,d);
			stricterEqual(single(mem.getFloat32(0)), single(d), d +"");
		}
		free(mem);
	}

	public function test_float64_roundtrips()
	{
		var mem = alloc(8);
		var data = [
			0,
			1,
			-1,
			123,
			-456,

			1.2,
			1.23,
			1.234,

			1.234e-30,
			1.234e-20,
			1.234e-10,
			1.234e10,
			1.234e20,
			1.234e30,

			3.1415,
			6.0221415e+23,
			6.6260693e-34,
			6.67428e-11,
			299792458,

			0,
			-0,
			Math.POSITIVE_INFINITY,
			Math.NEGATIVE_INFINITY,
			Math.NaN
		];

		for (d in data)
		{
			mem.setFloat64(0,d);
			stricterEqual(d, mem.getFloat64(0), d + "");
		}
		free(mem);
	}

	public function test_accessors()
	{
		var mem = alloc(8);
		for (i in 0...8)
			mem.setUInt8(i,0);
		var littleEndian = true;
		if (littleEndian)
		{
			ui8equal(mem, [0,0,0,0,0,0,0,0]);
			mem.setUInt8(0, 255);
			ui8equal(mem, [0xff, 0, 0, 0, 0, 0, 0, 0]);

			mem.setUInt8(1, -1);
			ui8equal(mem, [0xff, 0xff, 0, 0, 0, 0, 0, 0]);

			mem.setUInt16(2, 0x1234);
			ui8equal(mem, [0xff, 0xff, 0x34, 0x12, 0, 0, 0, 0]);

			mem.setUInt16(4, -1);
			ui8equal(mem, [0xff, 0xff, 0x34, 0x12, 0xff, 0xff, 0, 0]);

			mem.setInt32(1, 0x12345678);
			ui8equal(mem, [0xff, 0x78, 0x56, 0x34, 0x12, 0xff, 0, 0]);

			mem.setInt32(4, -2023406815);
			ui8equal(mem, [0xff, 0x78, 0x56, 0x34, 0x21, 0x43, 0x65, 0x87]);

			mem.setFloat32(0, 1.2E+38);
			ui8equal(mem, [0x52, 0x8e, 0xb4, 126, 0x21, 0x43, 0x65, 0x87]);

			mem.setFloat64(0, -1.2345678E+301);
			var ret = [0xfe, 0x72, 0x6f, 0x51, 0x5f, 0x61, 0x77, 0xe5];
			ret.reverse();
			ui8equal(mem, ret);

			for (i in 0...8)
				mem.setUInt8(i, 0x80 + i);
			//0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87
			Assert.equals(mem.getUInt8(0), 128);
			Assert.equals(mem.getUInt8(1), -127 & 0xFF);
			Assert.equals(mem.getUInt16(2), 33666);
			Assert.equals(mem.getUInt16(3), 33923);
			Assert.equals(mem.getUInt16(4), 34180);
			Assert.equals(mem.getInt32(4), -2021227132);
			Assert.equals(mem.getInt32(2), -2054913150);
			stricterEqual(mem.getFloat32(2), -1.932478247535851e-37, "");
			stricterEqual(mem.getFloat64(0), -3.116851295377095e-306, "");
		} else {
			ui8equal(mem, [0,0,0,0,0,0,0,0]);
			mem.setUInt8(0, 255);
			ui8equal(mem, [0xff, 0, 0, 0, 0, 0, 0, 0]);

			mem.setUInt8(1, -1);
			ui8equal(mem, [0xff, 0xff, 0, 0, 0, 0, 0, 0]);

			mem.setUInt16(2, 0x1234);
			ui8equal(mem, [0xff, 0xff, 0x12, 0x34, 0, 0, 0, 0]);

			mem.setUInt16(4, -1);
			ui8equal(mem, [0xff, 0xff, 0x12, 0x34, 0xff, 0xff, 0, 0]);

			mem.setInt32(1, 0x12345678);
			ui8equal(mem, [0xff, 0x12, 0x34, 0x56, 0x78, 0xff, 0, 0]);

			mem.setInt32(4, -2023406815);
			ui8equal(mem, [0xff, 0x12, 0x34, 0x56, 0x87, 0x65, 0x43, 0x21]);

			mem.setFloat32(2, 1.2E+38);
			ui8equal(mem, [0xff, 0x12, 0x7e, 0xb4, 0x8e, 0x52, 0x43, 0x21]);

			mem.setFloat64(0, -1.2345678E+301);
			ui8equal(mem, [0xfe, 0x72, 0x6f, 0x51, 0x5f, 0x61, 0x77, 0xe5]);

			for (i in 0...8)
				mem.setUInt8(i, 0x80 + i);
			Assert.equals(mem.getUInt8(0), 128);
			Assert.equals(mem.getUInt8(1), -127 & 0xFF);
			Assert.equals(mem.getUInt16(2), 33411);
			Assert.equals(mem.getUInt16(3), -31868 & 0xFFFF);
			Assert.equals(mem.getInt32(4), -2071624057);
			Assert.equals(mem.getInt32(2), -2105310075);
			// no unaligned access
			// stricterEqual(mem.getFloat32(2), -1.932478247535851e-37, "");
			stricterEqual(mem.getFloat64(0), -3.116851295377095e-306, "");
		}

		free(mem);
	}

	public function test_physcmp()
	{
		var buf = alloc(128);
		var buf2 = buf + 2;
		Assert.isTrue(buf2 > buf);
		Assert.isTrue(buf2 >= buf);
		Assert.isFalse(buf == buf2);
		Assert.isFalse(buf2 <= buf);
		Assert.isFalse(buf2 < buf);
		Assert.equals(-1, buf.physCompare(buf2));
		buf2--;
		Assert.isTrue(buf2 > buf);
		Assert.isTrue(buf2 >= buf);
		Assert.isFalse(buf == buf2);
		Assert.isFalse(buf2 <= buf);
		Assert.isFalse(buf2 < buf);
		Assert.equals(-1, buf.physCompare(buf2));
		buf2--;
		Assert.isFalse(buf2 > buf);
		Assert.isTrue(buf2 >= buf);
		Assert.isTrue(buf == buf2);
		Assert.isTrue(buf2 <= buf);
		Assert.isFalse(buf2 < buf);
		Assert.equals(0, buf.physCompare(buf2));
		buf2--;
		Assert.isFalse(buf2 > buf);
		Assert.isFalse(buf2 >= buf);
		Assert.isFalse(buf == buf2);
		Assert.isTrue(buf2 <= buf);
		Assert.isTrue(buf2 < buf);
		Assert.equals(1, buf.physCompare(buf2));

		buf2 = buf - 2;
		Assert.isTrue(buf > buf2);
		Assert.isTrue(buf >= buf2);
		Assert.isFalse(buf == buf2);
		Assert.isFalse(buf <= buf2);
		Assert.isFalse(buf < buf2);
		Assert.equals(1, buf.physCompare(buf2));
		buf2++;
		Assert.isTrue(buf > buf2);
		Assert.isTrue(buf >= buf2);
		Assert.isFalse(buf == buf2);
		Assert.isFalse(buf <= buf2);
		Assert.isFalse(buf < buf2);
		Assert.equals(1, buf.physCompare(buf2));
		buf2++;
		Assert.isFalse(buf > buf2);
		Assert.isTrue(buf >= buf2);
		Assert.isTrue(buf == buf2);
		Assert.isTrue(buf <= buf2);
		Assert.isFalse(buf < buf2);
		Assert.equals(0, buf.physCompare(buf2));
		buf2++;
		Assert.isFalse(buf > buf2);
		Assert.isFalse(buf >= buf2);
		Assert.isFalse(buf == buf2);
		Assert.isTrue(buf <= buf2);
		Assert.isTrue(buf < buf2);
		Assert.equals(-1, buf.physCompare(buf2));
		free(buf);
	}

	public function test_add()
	{
		var buf = alloc(64);
		var buf2 = buf + 30;
		for (i in 0...64)
			buf.setUInt8(i,i);
		Assert.equals(30,buf2.getUInt8(0));
		Assert.equals(31,buf2.getUInt8(1));
		Assert.equals(32,buf2.getUInt8(2));
		buf.setUInt8(32,100);

		Assert.equals(30,buf2.getUInt8(0));
		Assert.equals(31,buf2.getUInt8(1));
		Assert.equals(100,buf2.getUInt8(2));
		buf2 = buf2 - 15;
		Assert.equals(15,buf2.getUInt8(0));
		Assert.equals(16,buf2.getUInt8(1));
		Assert.equals(17,buf2.getUInt8(2));
		Assert.equals(100,buf2.getUInt8(17));
		buf = buf2 + 15;
		Assert.equals(30,buf.getUInt8(0));
		Assert.equals(31,buf.getUInt8(1));
		Assert.equals(100,buf.getUInt8(2));

		buf -= 30;
		free(buf);
	}

}
