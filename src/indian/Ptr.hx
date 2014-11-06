package indian;

/**
	A Pointer cannot be stored in any heap field or captured by an anoymous function. It should only live in the stack.

	The pointer has the same methods as its underlying HeapPtr<> type, and all HeapPtr<>s can
	be cast into a Ptr<>, but no Ptr<> should be cast into a HeapPtr<>.
	It is good practise to only annotate types as HeapPtr<> if it is really necessary
**/
@:genericBuild(indian._macro.PtrBuild.build())
extern class Ptr<T> implements ArrayAccess<T>
{
	/**
		Returns the pointer to the n-th element
	**/
	@:op(A+B) public function advance(nth:Int):Ptr<T>;

	@:op(++A) public function incr():Ptr<T>;
	@:op(A++) public function postIncr():Ptr<T>;
	@:op(--A) public function decr():Ptr<T>;
	@:op(A--) public function postDecr():Ptr<T>;

	/**
		Reinterprets the pointer as an `indian.Buffer`
	**/
	@:to public function asBuffer():Buffer;

	@:to public function asAny():AnyPtr;

	/**
		Dereferences the pointer to the actual `T` object. If the actual `T` object is a Struct, and
		the underlying platform doesn't support naked structs, this field won't be available.
	**/
	public function dereference():T;

	/**
		Reinterprets the current pointer as a pointer to another value type.
		The use of this function instead of performing an unsafe cast is needed in order for the code to work on all targets.
	**/
	public function reinterpret<To>():Ptr<To>;

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
