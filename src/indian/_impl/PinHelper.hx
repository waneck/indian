package indian._impl;
import indian.*;
import indian.types.*;

class PinHelper
{
	public static function string(s:String):Buffer
	{
#if neko
		return indian._impl.neko.PointerHelper.strptr(untyped s.__s);
#elseif java
		var ret = Indian.alloc(s.length << 1);
		JavaStringCopy.stringCopy(s,ret);
		return ret;
#else
		var ret = Indian.alloc(s.length << 1);
		var chr:Int = -1,
				i = -1;
		while ( !StringTools.isEof(chr = StringTools.fastCodeAt(s,++i)) )
		{
			ret.setUInt16(i<<1,chr);
		}
		return ret;
#end
	}

	@:generic public static function array<T>(arr:Array<T>):Buffer
	{
		return null;
	}

	private static function array_Int(arr:Array<Int>):Buffer
	{
		var buf = Indian.alloc(arr.length << 2);
		for (i in 0...arr.length)
		{
			buf.setInt32(i<<2, arr[i]);
		}
		return buf;
	}

	private static function array_Float(arr:Array<Float>):Buffer
	{
		var buf = Indian.alloc(arr.length << 3);
		for (i in 0...arr.length)
		{
			buf.setFloat64(i<<3, arr[i]);
		}
		return buf;
	}

	private static function array_Single(arr:Array<Single>):Buffer
	{
		var buf = Indian.alloc(arr.length << 2);
		for (i in 0...arr.length)
		{
			buf.setFloat32(i<<2, arr[i]);
		}
		return buf;
	}

	private static function array_indian_types_UInt16(arr:Array<UInt16>):Buffer
	{
		var buf = Indian.alloc(arr.length << 1);
		for (i in 0...arr.length)
		{
			buf.setUInt16(i<<1, arr[i]);
		}
		return buf;
	}

	private static function array_indian_types_UInt8(arr:Array<UInt8>):Buffer
	{
		var buf = Indian.alloc(arr.length << 1);
		for (i in 0...arr.length)
		{
			buf.setUInt8(i, arr[i]);
		}
		return buf;
	}

	@:generic public static function vector<T>(arr:haxe.ds.Vector<T>):Buffer
	{
		return null;
	}

	private static function vector_Int(arr:haxe.ds.Vector<Int>):Buffer
	{
		var buf = Indian.alloc(arr.length << 2);
		for (i in 0...arr.length)
		{
			buf.setInt32(i<<2, arr[i]);
		}
		return buf;
	}

	private static function vector_Float(arr:haxe.ds.Vector<Float>):Buffer
	{
		var buf = Indian.alloc(arr.length << 3);
		for (i in 0...arr.length)
		{
			buf.setFloat64(i<<3, arr[i]);
		}
		return buf;
	}

	private static function vector_Single(arr:haxe.ds.Vector<Single>):Buffer
	{
		var buf = Indian.alloc(arr.length << 2);
		for (i in 0...arr.length)
		{
			buf.setFloat32(i<<2, arr[i]);
		}
		return buf;
	}

	private static function vector_indian_types_UInt16(arr:haxe.ds.Vector<UInt16>):Buffer
	{
		var buf = Indian.alloc(arr.length << 1);
		for (i in 0...arr.length)
		{
			buf.setUInt16(i<<1, arr[i]);
		}
		return buf;
	}

	private static function vector_indian_types_UInt8(arr:haxe.ds.Vector<UInt8>):Buffer
	{
		var buf = Indian.alloc(arr.length << 1);
		for (i in 0...arr.length)
		{
			buf.setUInt8(i, arr[i]);
		}
		return buf;
	}

}

#if java
//TODO clean this up. Check performance and maybe eliminate this.
@:final @:nativeGen class JavaStringCopy
{
	public var value(default,null):Int64;
	public var offset(default,null):Int64;

	function new(value,offset)
	{
		this.value = value;
		this.offset = offset;
	}

	private static var cur = {
		try
		{
			var str = java.Lib.toNativeType(String),
					unsafe = indian._impl.java.Unsafe.unsafe;

			inline function getOffset(f:String)
				return unsafe.objectFieldOffset(str.getDeclaredField(f));
			var val = getOffset('value'),
					off = try getOffset('offset') catch(e:Dynamic) cast -1;
			new JavaStringCopy(val,off);
		}
		catch(e:Dynamic)
		{
			null;
		}
	};

	public static function stringCopy(from:String, to:Buffer)
	{
		var cur = cur;
		if (cur != null)
		{
			var unsafe = indian._impl.java.Unsafe.unsafe;
			var off = cur.offset;
			var val:CharArray = cast unsafe.getObject(from, cur.value),
					offset = off == -1 ? 0 : unsafe.getInt(from, off);
			JavaCharArray.arrayCopy(val, offset, to);
		} else {
			var chr:Int = -1,
					i = -1;
			while ( !StringTools.isEof(chr = StringTools.fastCodeAt(from,++i)) )
			{
				to.setUInt16(i<<1,chr);
			}
		}
	}
}

@:final @:nativeGen class JavaCharArray
{
	public var baseOffset(default,null):Int64;

	function new(offset)
	{
		this.baseOffset = offset;
	}

	private static var cur = {
		try
		{
			var cls:java.lang.Class<Dynamic> = untyped __java__('char[].class'),
					unsafe = indian._impl.java.Unsafe.unsafe;
			new JavaCharArray(unsafe.arrayBaseOffset(cls));
		}
		catch(e:Dynamic)
		{
			null;
		}
	};

	public static function arrayCopy(from:CharArray, offset:Int, to:Buffer)
	{
		var cur = cur;
		if (cur != null)
		{
			var unsafe = indian._impl.java.Unsafe.unsafe,
					baseOffset = cur.baseOffset;
			// var len = Std.int(Math.floor( (from.length - offset) / 4 ));
			// var len = Std.int(Math.ceil( (from.length - offset) / 2));
			for (i in offset...from.length)
			{
				to.setUInt16(i<<1,unsafe.getInt(from,baseOffset + (i<<1)));
				// to.setInt64(i << 3, unsafe.getLong(from,baseOffset + i << 3));
			}
		} else {
			for (i in offset...from.length)
			{
				to.setUInt16(i<<1, cast from[i]);
			}
		}
	}
}

typedef CharArray = java.NativeArray<java.StdTypes.Char16>;
#end
