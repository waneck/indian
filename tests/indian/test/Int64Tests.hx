package indian.test;
import indian.types.Int64;
import indian.types.Int64.*;
import utest.Assert;

//FIXME: cover all operations and overflow test
class Int64Tests
{

	public function new() {

	}

	public function test() {
		Assert.equals( ofInt(1).toInt(), 1 );
		Assert.equals( ofInt( -1).toInt(), -1 );
		Assert.equals( ofInt(156).toString(), "156" );

		var v = ofInt(1 << 20);
		Assert.equals( (v + ""), "1048576" );

		var p40 = v.shl(20);
		trace(p40.toString(),v.toString());
		Assert.equals( p40.toString(), "1099511627776" );

		Assert.equals( ofInt(1).shl(0).toString(), "1" );

		Assert.equals(Int64.ofInt(0).toString(), "0");
	}

	public function testMath() {
		var a = Int64.make(0, 0x239B0E13);
		var b = Int64.make(0, 0x39193D1B);
		var c = a * b;

		Assert.equals( c.toString(), "572248275467371265" );
		trace((c + "") + " should be 572248275467371265"); // but gives 7572248271172403969 in javascript

		var a = Int64.make(0, 0xD3F9C9F4);
		var b = Int64.make(0, 0xC865C765);
		var c = a * b;
		Assert.equals( c.toString(), "-6489849317865727676" );

		var a = Int64.make(0, 0x9E370301);
		var b = Int64.make(0, 0xB0590000);
		var c = a + b;
		Assert.equals( c.toString(), "5613028097" );

		var a = Int64.make(0xFFF21CDA, 0x972E8BA3);
		var b = Int64.make(0x0098C29B, 0x81000001);
		var c = a * b;
		#if !as3
		var expected = Int64.make(0xDDE8A2E8, 0xBA2E8BA3);
		Assert.equals( expected.compare(c), 0 );
		#end
	}

	// tests taken from https://github.com/candu/node-int64-native/blob/master/test/int64.js
	public function testCompare()
	{
    var a = ofInt(2),
        b = ofInt(3);
		Assert.isTrue(a == a);
		Assert.isTrue(b == b);
		Assert.equals(a.compare(a), 0);
		Assert.equals(a.compare(b), -1);
		Assert.equals(b.compare(a), 1);
	}

	public function testBits()
	{
	  var x = make(0xfedcba98,0x76543210);
    var y = x & (ofInt(0xffff)),
        z = x | (ofInt(0xffff)),
        w = x ^ (make(0xffffffff,0xffffffff));
    Assert.equals(y.toHex(), '0x0000000000003210');
    Assert.equals(z.toHex(), '0xfedcba987654ffff');
    Assert.equals(w.toHex(), '0x0123456789abcdef');
    Assert.equals((x & 0xffff).toHex(), '0x0000000000003210');
    Assert.equals((x | 0xffff).toHex(), '0xfedcba987654ffff');
    Assert.equals((x ^ 0xffff).toHex(), '0xfedcba987654cdef');
    Assert.equals((x & make(0x1,0xffffffff)).toHex(), '0x0000000076543210');
    Assert.equals((x | make(0x1,0xffffffff)).toHex(), '0xfedcba99ffffffff');
    Assert.equals((x ^ make(0x1, 0xffffffff)).toHex(), '0xfedcba9989abcdef');
    var a = ofInt(7),
        b = a << 1;
    Assert.equals(b.toHex(), '0x000000000000000e');
	}

	public function testAdd()
	{
		var a = ofInt(3),
				b = ofInt(2),
				c = make(0xffffffff,0xfffffffe);
		trace(a+b);
		Assert.isTrue( (a + b) == ofInt(5) );
		Assert.isTrue( (a + 4) == ofInt(7) );
		Assert.isTrue( (c + 3) == ofInt(1) );
		// numbers larger than int32
		Assert.equals( (a + make(0x1, 0)).toHex(), '0x0000000100000003');
	}
}
