package indian;

@:genericBuild(indian._internal.PtrBuild.build())
extern class HeapPtr<T> implements ArrayAccess<T>
{
	/**
		Returns the pointer to the n-th element
	**/
	@:op(A+B) public function advance(nth:Int):Ptr<T>;

	/**
		Reinterprets the pointer as an `indian.Buffer`
	**/
	@:to public function asBuffer():Buffer;

	@:to public function asAny():AnyPtrHeap;

	/**
		Dereferences the pointer to the actual `T` object. If the actual `T` object is a Struct, and
		the underlying platform doesn't support naked structs, this field won't be available.
	**/
	public function dereference():T;

	/**
		Reinterprets the current pointer as a pointer to another value type.
		The use of this function instead of performing an unsafe cast is needed in order for the code to work on all targets.
	**/
	public function reinterpret<To>():HeapPtr<To>;

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

	/**
		Casts itself to the stack-restricted Ptr type
	**/
	@:to public function asPtr():Ptr<T>;
}

