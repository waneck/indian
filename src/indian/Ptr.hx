package indian;

/**
	A Pointer cannot be stored in any heap field or captured by an anoymous function. It should only live in the stack.

	The pointer has the same methods as its underlying HeapPtr<> type, and all HeapPtr<>s can
	be cast into a Ptr<>, but no Ptr<> should be cast into a HeapPtr<>.
	It is good practise to only annotate types as HeapPtr<> if it is really necessary
**/
@:genericBuild(indian._internal.PtrBuild.build())
extern class Ptr<T> implements ArrayAccess<T>
{
	/**
		Returns the pointer to the n-th element
	**/
	@:op(A+B) public function advance(nth:Int):Ptr<T>;

	/**
		Reinterprets the pointer as an `indian.Buffer`
	**/
	@:to public function asBuffer():Buffer;

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
