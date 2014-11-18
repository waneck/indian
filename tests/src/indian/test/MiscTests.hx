package indian.test;
import utest.Assert.*;
import indian._macro.helpers.*;

class MiscTests
{
	public function new()
	{
	}

	public function test_shortpack()
	{
		var ctx = new ShortPack();
		equals('a',ctx.getShortPack(['ab']));
		equals("$a",ctx.getShortPack(['a']));
		equals('ac',ctx.getShortPack(['ab','c']));
		equals('abc',ctx.getShortPack(['abd','c']));
		equals('ab',ctx.getShortPack(['a','b']));
		equals('ac',ctx.getShortPack(['ab','c']));
		equals("$a$b$c",ctx.getShortPack(['a','b','c']));
		equals("a_c",ctx.getShortPack(['a_b','cd']));
		equals("a_cd",ctx.getShortPack(['a_b','cde']));
		equals("a_bcd",ctx.getShortPack(['a_b','cdef']));
		equals("a_",ctx.getShortPack(['a_']));
		equals("a_b",ctx.getShortPack(['a_','b']));
		equals("a_bc",ctx.getShortPack(['a_bc']));
		equals("$a_b$c",ctx.getShortPack(['a_b','c']));
	}

}
