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
		var encodings = [Utf8.cur, Utf16.cur, Utf32.cur];
		var strings = [
			'Hello, World',
			'Just a normal ASCII string here!'
		];
		for (s in strings)
		{
			for (e1 in encodings)
			{
				var l1 = e1.neededLength(s, true);
				autofree(
					b1e1 = $alloc(l1),
					b2e1 = $alloc(Std.int(l1/2)),
					b3e1 = $alloc(l1*2),
					b4e1 = $alloc(l1-1),
				{
					//test from string
					e1.convertFromString(s,b1e1,l1,true);
					switch(e1.name())
					{
						case 'UTF-8':
							for (i in 0...s.length)
								Assert.equals(s.charCodeAt(i), b1e1.getUInt8(i));
						case 'UTF-16':
							for (i in 0...s.length)
								Assert.equals(s.charCodeAt(i), b1e1.getUInt16(i<<1));
						case 'UTF-32':
							for (i in 0...s.length)
								Assert.equals(s.charCodeAt(i), b1e1.getInt32(i<<2));
						case _:
							Assert.fail();
					}
				});
			}
		}
	}

	public function test_very_simple()
	{
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

	// public function test_string()
	// {
	// 	var encodings = [Utf8.cur, Utf16.cur, Utf32.cur];
	// 	var strings = [
	// 		'Hello, World',
	// 		'Olá, Mundo',
	// 		'¡Hola mundo!',
	// 		'привет мир',
	// 		'STARGΛ̊TE SG-1, a = v̇ = r̈, a⃑ ⊥ b⃑', //combining characters
	// 		'Σὲ γνωρίζω ἀπὸ τὴν κόψη', //greek polytonic
	// 		'Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσ\nκειν, ὦ ἄνδρες ᾿Αθηναῖοι', //greek
	// 		'გთხოვთ ახლავე გაიაროთ რეგისტრა\nცია Unicode-ის მეათე საერთაშორისო', //georgian
	// 		'Зарегистрируйтесь сейчас \nна Десятую Международную Конференцию по', //russian
	// 		'๏ แผ่นดินฮั่นเสื่อมโทรมแสนสังเวช  พระปกเกศกองบู๊กู้ขึ้นใหม่', //thai - 2 columns
	// 		'ሰማይ አይታረስ ንጉሥ አይከሰስ።', //ethiopian
	// 		'ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ \nᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ', //runes
	// 		'⡌⠁⠧⠑ ⠼⠁⠒  ⡍⠜⠇⠑⠹⠰⠎ ⡣⠕⠌', //braille
	// 		'ABCDEFGHIJKLMNOPQRSTUVWXYZ /012345\n6789', //compact font
	// 		'∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː\n⍎אԱა', //more compact
	// 		'Hello world, Καλημέρα κ\nόσμε, コンニチハ', //more hello worlds
	// 	];
	// 	for (s in strings)
	// 	{
	// 		for (e1 in encodings)
	// 		{
	// 			// for (e2 in encodings)
	// 			{
	// 				var l1 = e1.neededLength(s);
	// 						// l2 = e2.neededLength(s);
	// 				autofree(
	// 					b1e1 = $alloc(l1),
	// 					// b1e2 = $alloc(l2),
	// 					b2e1 = $alloc(Std.int(l1/2)),
	// 					// b2e2 = $alloc(Std.int(l2/2)),
	// 					b3e1 = $alloc(l1*2),
	// 					// b3e2 = $alloc(l2*2),
	// 				{
	// 					// test back and forth
	// 					e1.convertFromString(s,b1e1,l1);
	// 					var s2 = e1.convertToString(b1e1,l1);
	// 					Assert.equals(s,s2);
	// 					trace(e1,l1);
	// 					trace(s.length,s2.length);
	// 					trace(s,s2,s == s2);
	// 					// Assert.equals(l1,r);
	// 				});
	// 			}
	// 		}
	// 	}
	// }

	//- string -> encoding and back. with same obj, exact length, less length and much more length
	//- encoding -> encoding and back. same obj, exact length, less length and much more length
	//- encoding -> utf32 and back. same obj, exact length, less length and much more length
	//- length 0 objects
}
