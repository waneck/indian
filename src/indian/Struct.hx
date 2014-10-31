package indian;

/**
	This is a special type which will generate struct type definitions.
	In platforms that support it, structs are stack-allocated.

	Otherwise, they are only accessible when used through a pointer -
	even if that pointer is a pointer to another struct that contains the struct
**/
@:genericBuild(indian._internal.PtrBuild.build())
extern class Struct<T>
{
	private static function alloc<T>(?tdef:{}):Ptr<Struct<T>>;
#if STACKALLOC
	private static function stackalloc<T>(size:Int):Ptr<Struct<T>>;
#end
	private static function array<T>(size:Int):Ptr<Struct<T>>;
	function copy():Struct<T>;
	/*macro*/ function with(tdef:{}):Struct<T>;
	function address():Ptr<Struct<T>>;
	function equals(to:Struct<T>):Bool;
}
