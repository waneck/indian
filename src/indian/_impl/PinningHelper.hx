package indian._impl;

class PinningHelper
{
	@:extern inline public static function pointerOfArray<T>(arr:Array<T>):PointerType<T>
	{
#if cpp
		return untyped __cpp__("{0}->GetBase()",arr);
#elseif cs
#else
#end
	}

	@:extern inline public static function pointerOfVector<T>(arr:haxe.ds.Vector<T>):PointerType<T>
	{
#if cpp
		return untyped __cpp__("{0}->GetBase()",arr);
#elseif cs
#else
#end
	}

	@:extern inline public static function pointerOfString(arr:haxe.ds.Vector<T>):BufferType
	{
#if cpp
#elseif cs
#else
#end
	}

#if cs
	@:extern inline public static function pointerOfNative<T>(arr:cs.NativeArray<T>):PointerType<T>
	{
	}
#end
}
