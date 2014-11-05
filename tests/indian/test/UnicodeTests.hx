package indian.test;
import indian.types.encoding.*;
import indian.Indian.*;
import utest.Assert;

@:unsafe class UnicodeTests
{
	public function new()
	{
	}

	public function test_simple()
	{
		trace('testing simple');
		var encodings = [Utf8.cur, Utf16.cur, Utf32.cur];
		var strings = [
			'Hello, World',
			'Just a normal ASCII string here!',
			'We only\n\rtest\r\n ASCII strings here. Promise!',
			'',
		];
		for (s in strings)
		{
			trace(s);
			for (e1 in encodings)
			{
				trace(e1);
				var l1 = e1.neededLength(s, true);
				var l1by2 = e1.neededLength(s.substr(0,Std.int(s.length/2)),true);
				autofree(
					b1 = $alloc(l1),
					b2 = $alloc(l1by2),
					b3 = $alloc(l1<<1),
					b4 = $alloc(l1-1),
				{
					//test from string
					for (i in 0...l1) b1.setUInt8(i,0xff);
					e1.convertFromString(s,b1,l1,true);
					checkEncodedString(e1, s,b1, s.length);
					Assert.equals(0, b1.getUInt8(l1-1));

					e1.convertFromString(s,b2,l1by2,true);
					checkEncodedString(e1,s,b2,Std.int(s.length/2));
					for (i in 0...(l1<<1)) b3.setUInt8(i,0xff);
					e1.convertFromString(s,b3,l1<<1,true);
					checkEncodedString(e1,s,b3,s.length);
					if (s.length > 0)
					{
						Assert.equals(0, b3.getUInt8(l1-1));
						Assert.equals(0xFF, b3.getUInt8(l1));
					}

					e1.convertFromString(s,b4,l1-1,true);
					checkEncodedString(e1, s,b4, s.length-1);
					if (s.length > 0)
						Assert.equals(0, b4.getUInt8(l1-e1.terminationBytes-1));

					for (i in 0...(l1-1)) b4.setUInt8(i,0xff);
					e1.convertFromString(s,b4,l1-1,false);
					checkEncodedString(e1, s,b4, s.length);

					for (i in 0...l1) b1.setUInt8(i,0xff);
					e1.convertFromString(s,b1,l1-1,false);
					checkEncodedString(e1, s,b1, s.length);
					Assert.equals(0xFF, b1.getUInt8(l1-1)); //no terminator

					e1.convertFromString(s,b1,l1,true); //add terminator again

					//round trip
					inline function strEq(s1:String, s2:String, ?pos:haxe.PosInfos)
					{
						var msg = 'For $e1, expected "$s1" (${s1.length}), but got "$s2" (${s2.length})';
						Assert.equals(s1,s2,msg,pos);
					}

					var s2:String = null;
					s2 = e1.convertToString(b1,l1,true);
					strEq(s,s2);
					s2 = e1.convertToString(b2,l1by2,true);
					var len = s.length>>1;
					strEq(s.substr(0,len),s2);
					s2 = e1.convertToString(b3,l1,true);
					strEq(s,s2);
					s2 = e1.convertToString(b4,l1-e1.terminationBytes,false);
					strEq(s,s2);

					//take off the termination bit
					s2 = e1.convertToString(b1,l1-e1.terminationBytes,false);
					strEq(s,s2);
					s2 = e1.convertToString(b2,l1by2-e1.terminationBytes,false);
					strEq(s.substr(0,(s.length>>1)),s2);
					s2 = e1.convertToString(b3,l1-e1.terminationBytes,false);
					strEq(s,s2);
					s2 = e1.convertToString(b4,l1-e1.terminationBytes,false);
					strEq(s,s2);

				});
			}
		}
	}

	inline private static function checkEncodedString(encoding:Encoding, str:String, buf:Buffer, len:Int, ?pos:haxe.PosInfos)
	{
		switch(encoding.name)
		{
			case 'UTF-8':
				for (i in 0...len)
				{
					var exp = str.charCodeAt(i),
							got = buf.getUInt8(i);
					var msg = 'For $encoding expected char ${String.fromCharCode(exp)}($exp), but got ${String.fromCharCode(got)}($got) at $i (string (${str.length}) $str)';
					Assert.equals(str.charCodeAt(i), buf.getUInt8(i), msg, pos);
				}
			case 'UTF-16':
				for (i in 0...len)
				{
					var exp = str.charCodeAt(i),
							got = buf.getUInt16(i<<1);
					var msg = 'For $encoding expected char ${String.fromCharCode(exp)}($exp), but got ${String.fromCharCode(got)}($got) at $i (string (${str.length}) $str)';
					Assert.equals(str.charCodeAt(i), buf.getUInt16(i<<1),msg, pos);
				}
			case 'UTF-32':
				for (i in 0...len)
				{
					var exp = str.charCodeAt(i),
							got = buf.getInt32(i<<2);
					var msg = 'For $encoding expected char ${String.fromCharCode(exp)}($exp), but got ${String.fromCharCode(got)}($got) at $i (string (${str.length}) $str)';
					Assert.equals(str.charCodeAt(i), buf.getInt32(i<<2),msg, pos);
				}
			case _:
				Assert.fail();
		}
	}

	public function test_very_simple()
	{
		trace('test very simple');
		var encodings = [Utf8.cur, Utf16.cur, Utf32.cur];
		var strings = [
			'Hello, World',
			'Just a normal ASCII string here!',
			'Olá, Mundo',
			'¡Hola mundo!',
			'привет мир',
			'STARGΛ̊TE SG-1, a = v̇ = r̈, a⃑ ⊥ b⃑', //combining characters
			'Σὲ γνωρίζω ἀπὸ τὴν κόψη', //greek polytonic
			'Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσ\nκειν, ὦ ἄνδρες ᾿Αθηναῖοι', //greek
			'გთხოვთ ახლავე გაიაროთ რეგისტრა\nცია Unicode-ის მეათე საერთაშორისო', //georgian
			'Зарегистрируйтесь сейчас \nна Десятую Международную Конференцию по', //russian
			'๏ แผ่นดินฮั่นเสื่อมโทรมแสนสังเวช  พระปกเกศกองบู๊กู้ขึ้นใหม่', //thai - 2 columns
			'ሰማይ አይታረስ ንጉሥ አይከሰስ።', //ethiopian
			'ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ \nᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ', //runes
		];
		for (s in strings)
		{
			var len = s.length;
			pin(str = $ptr(s), {
				for (i in 0...s.length)
				{
#if (java || cs || js)
					Assert.equals(s.charCodeAt(i), str.getUInt16(i<<1));
#else
					Assert.equals(s.charCodeAt(i), str.getUInt8(i));
#end
				}
			});
		}
	}

	public function test_empty()
	{
		trace('test empty');
		var encodings = [Utf8.cur, Utf16.cur, Utf32.cur];
		autofree(
			buf1 = $stackalloc(128),
			buf2 = $stackalloc(128),
		{
			var s = '';
			for (enc in encodings)
			{
				trace(enc);
				buf1.set(0, 0xff, 128);
				trace(1);
				buf2.set(0, 0xff, 128);
				trace(1);
				enc.convertFromString(s,buf1,128,true);
				trace(1);
				Assert.equals(0,buf2.cmp(buf1 + enc.terminationBytes,128 - enc.terminationBytes));
				trace(1);
				var s2 = enc.convertToString(buf1,-1,true);
				trace(1);
				Assert.equals(0,buf2.cmp(buf1 + enc.terminationBytes,128 - enc.terminationBytes));
				trace(1);
				Assert.equals(s,s2);
				trace(1);
			}
		});
	}

	public function test_lengths()
	{
		trace('test lengths');
		var encodings = [Utf8.cur, Utf16.cur, Utf32.cur];
		var strings = [
			'ᛒニ𝄞',
			'ニ',
			'𝄞',
			'𝒞',
			'䷀',
			'䷀䷁䷂䷃'
		];
		var lengths = [1,64,128,256,512,0x7FFF];
		var utf32 = Utf32.cur;
		for (s in strings)
		{
			var glyph = s;
			for (e1 in encodings)
			{
				for (e2 in encodings)
				{
					for (len in lengths)
					{
						var s = {
							var str = new StringBuf();
							for (i in 0...len)
							{
								str.add(s);
							}
							str.toString();
						};
						var l1 = e1.neededLength(s,true),
								l2 = e2.neededLength(s,true),
								l3 = utf32.neededLength(s,true);
						autofree(
							buf1 = $alloc(l1),
							buf2 = $alloc(l2),
							buf_u32_1 = $alloc(l3),
							buf_u32_2 = $alloc(l3),
						{
							buf1.set(0, 0x7c, l1);
							trace("====================================");
							trace(glyph,e1,e2,len);
							// test back and forth
							e1.convertFromString(s,buf1,l1,true);
							var s2 = e1.convertToString(buf1,l1,true);
							trace(s.length,s2.length);
							var msg = 's2: For glyph "$glyph" and length $len, the encoding $e1 has shown different contents: ${s.length} and ${s2.length}';
							if (s != s2)
							{
								trace(s,s2);
							}
							Assert.equals(s.length,s2.length,msg);
							Assert.equals(s,s2,msg);
							var pos = e1.convertToEncoding(buf1,l1, buf2,l2, e2);
							trace(pos,l2);
							// e2.addTermination(buf2,pos);
							var s3 = e2.convertToString(buf2,l2,true);
							var msg = 's3: For glyph "$glyph" and length $len, the encoding $e2 has shown different contents: ${s2.length} and ${s3.length}';
							Assert.equals(s2.length,s3.length,msg);
							Assert.equals(s2,s3,msg);
							if (s2 != s3 || s2.length != s3.length)
							{
								trace(s,s2,s3);
							}
							var msg = 's3: For glyph "$glyph" and length $len, the encoding $e2 has shown different contents: ${s.length} and ${s3.length}';
							Assert.equals(s.length,s3.length,msg);
							Assert.equals(s,s3,msg);
							var msg = 'glyph $glyph length $len e1 $e1 e2 $e2 count: ${e1.count(buf1,l1)},${e2.count(buf2,l2)}';
							Assert.equals(e1.count(buf1,l1),e2.count(buf2,l2),msg);
							var msg = 'glyph $glyph length $len e1 $e1 e2 $e2 count: ${e1.count(buf1,-1)},${e2.count(buf2,-1)}';
							Assert.equals(e1.count(buf1,-1),e2.count(buf2,-1),msg);
							// autofree(
							// 	buf1c = $alloc(l1),
							// {
							// 	buf1c.set(0, 0xff, l1);
							// 	trace('converting');
							// 	var pos = e2.convertToEncoding(buf2,l2, buf1c,l1, e1);
							// 	e1.addTermination(buf1c,pos);
							// 	var msg = 'For glyph "$glyph" and length $len, the encodings $e1 and $e2 have shown different contents when converting from $e2 to $e1: ${buf1.cmp(buf1c,l1)}';
							// 	Assert.equals(0, buf1.cmp(buf1c,l1), msg);
							// 	if (buf1.cmp(buf1c,l1) != 0)
							// 	{
							// 		trace(e1);
							// 		trace(buf1.add(l1-130).hexString(130));
							// 		trace(buf1c.add(l1-130).hexString(130));
							// 		// trace(e1,e2, buf1.cmp(buf1c,l1));
							// 		// trace(e1.convertToString(buf1c,l1,true) == s);
							// 		// trace(e1.convertToString(buf1c,l1,true));
							// 		// trace(buf1.hexString(l1));
							// 		// trace(buf1c.hexString(l1));
							// 		// trace(buf2.hexString(l2));
							// 	}
							// });
						});
					}
				}
			}
		}
	}

	public function test_string()
	{
		trace('test string');
		var encodings = [Utf8.cur, Utf16.cur, Utf32.cur];
		var strings = [
			'Hello, World',
			'Olá, Mundo',
			'¡Hola mundo!',
			'привет мир',
			'STARGΛ̊TE SG-1, a = v̇ = r̈, a⃑ ⊥ b⃑', //combining characters
			'Σὲ γνωρίζω ἀπὸ τὴν κόψη', //greek polytonic
			'Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσ\nκειν, ὦ ἄνδρες ᾿Αθηναῖοι', //greek
			'გთხოვთ ახლავე გაიაროთ რეგისტრა\nცია Unicode-ის მეათე საერთაშორისო', //georgian
			'Зарегистрируйтесь сейчас \nна Десятую Международную Конференцию по', //russian
			'๏ แผ่นดินฮั่นเสื่อมโทรมแสนสังเวช  พระปกเกศกองบู๊กู้ขึ้นใหม่', //thai - 2 columns
			'ሰማይ አይታረስ ንጉሥ አይከሰስ።', //ethiopian
			'ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ \nᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ', //runes
			'⡌⠁⠧⠑ ⠼⠁⠒  ⡍⠜⠇⠑⠹⠰⠎ ⡣⠕⠌', //braille
			'ABCDEFGHIJKLMNOPQRSTUVWXYZ /012345\n6789', //compact font
			'∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː\n⍎אԱა', //more compact
			'Hello world, Καλημέρα κ\nόσμε, コンニチハ', //more hello worlds
			''
		];
		var utf32 = Utf32.cur;
		for (s in strings)
		{
			for (e1 in encodings)
			{
				for (e2 in encodings)
				{
					var l1 = e1.neededLength(s,true),
							l2 = e2.neededLength(s,true),
							l3 = utf32.neededLength(s,true);
					autofree(
						buf1 = $alloc(l1),
						buf2 = $alloc(l2),
						buf_u32_1 = $alloc(l3),
						buf_u32_2 = $alloc(l3),
					{
						buf1.set(0, 0x7c, l1);
						// test back and forth
						e1.convertFromString(s,buf1,l1,true);
						var s2 = e1.convertToString(buf1,l1,true);
						Assert.equals(s,s2);
						e1.convertToEncoding(buf1,l1, buf2,l2, e2);
						var s3 = e2.convertToString(buf2,l2,true);
						Assert.equals(s,s3);
						autofree(
							buf1c = $alloc(l1),
						{
							buf1c.set(0, 0xff, l1);
							trace('converting');
							e2.convertToEncoding(buf2,l2, buf1c,l1, e1);
							Assert.equals(0, buf1.cmp(buf1c,l1));
							if (buf1.cmp(buf1c,l1) != 0)
							{
								trace(e1,e2, buf1.cmp(buf1c,l1));
								trace(e1.convertToString(buf1c,l1,true) == s);
								trace(e1.convertToString(buf1c,l1,true));
								trace(buf1.hexString(l1));
								trace(buf1c.hexString(l1));
								trace(buf2.hexString(l2));
							}
						});
					});
				}
			}
		}
	}

	//- string -> encoding and back. with same obj, exact length, less length and much more length
	//- encoding -> encoding and back. same obj, exact length, less length and much more length
	//- encoding -> utf32 and back. same obj, exact length, less length and much more length
	//- length 0 objects
}
