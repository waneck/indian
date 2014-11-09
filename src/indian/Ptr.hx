package indian;

/**
	The `indian.Ptr<>` class is a special class that works like a template - building a different pointer object for each different type used.
	Each `indian.Ptr<>` type can be cast to and from `indian.AnyPtr`, which can be seen as a `super type` of all the Pointer types.

	Pointers to type parameters are not supported and will be compiled as `indian.AnyPtr`
**/
@:genericBuild(indian._macro.PtrBuild.build())
extern class Ptr<T> implements ArrayAccess<T>
{
	/**
		The size in bytes of each element
	**/
	public static var bytesize:Int;

	/**
		Returns the pointer to the n-th element
	**/
	@:op(A+B) public function advance(nth:Int):Ptr<T>;

	@:op(++A) public function incr():Ptr<T>;
	@:op(A++) public function postIncr():Ptr<T>;
	@:op(--A) public function decr():Ptr<T>;
	@:op(A--) public function postDecr():Ptr<T>;

	/**
		Creates a `Ptr<T>` type from an `indian.Buffer` type
	**/
	@:from public static function fromBuffer<T>(buf : indian.Buffer) : Ptr<T>;

	@:from public static function fromAny<T>(any : indian.AnyPtr) : Ptr<T>;

	/**
		Reinterprets the pointer as an `indian.Buffer`
	**/
	@:to public function asBuffer():Buffer;

	/**
		Reinterprets the pointer as `indian.AnyPtr`.
		Use this to safely cast between different `Ptr<>` types

		Example:
		```haxe
			var ptr:Ptr<Int> = getSomePtr();
			var ptrFloat:Ptr<Float> = ptr.asAny(); //will be correctly cast to `Ptr<Float>` on all targets
		```
	**/
	@:to public function asAny():AnyPtr;

	/**
		Dereferences the pointer to the actual `T` object. If the actual `T` object is a Struct, and
		the underlying platform doesn't support naked structs, this field won't be available.
	**/
	public function dereference():T;

	/**
		Gets the concrete `T` reference. If the underlying type is a struct, and
		the underlying platform doesn't support structs, this field won't be available
	**/
	@:arrayAccess public function get(idx:Int):T;

	/**
		Sets the concrete `T` reference. If the underlying type is a struct, and
		the underlying platform doesn't support structs, this field won't be available
	**/
	@:arrayAccess public function set(idx:Int, val:T):T;
}
