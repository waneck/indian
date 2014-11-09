package indian;

/**
	This is a special type which will generate struct type definitions.
	In platforms that support it, structs are stack-allocated.

	Otherwise, they are only accessible when used through a pointer -
	even if that pointer is a pointer to another struct that contains the struct
**/
@:genericBuild(indian._macro.StructBuild.build())
extern class Struct<T>
{
	/*macro*/ static function create<T>(?tdef:{}):Struct<T>;
	/*macro*/ static function alloc<T>(?tdef:{}):Ptr<Struct<T>>;
	/*macro*/ static function stackalloc<T>(?tdef:{}):Ptr<Struct<T>>;

	static function array<T>(size:Int):Ptr<Struct<T>>;
	static function stackarray<T>(size:Int):Ptr<Struct<T>>;

	static var bytesize:Int;

	// function copy():Struct<T>;
	/*macro*/ function with(tdef:{}):Struct<T>;
	// function address():Ptr<Struct<T>>;
	// function equals(to:Struct<T>):Bool;
}
