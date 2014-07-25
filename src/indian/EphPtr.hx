package indian;

/**
	An Ephemeral Pointer is a pointer that cannot be stored in any field or captured by an anoymous function.
	It should only live in the stack.

	The ephemeral pointer has the same methods as its underlying Ptr<> type, and all Ptr<>s can
	be cast into an EphPtr<>, but no EphPtr<> should be cast into a Ptr<>.
	It is good practise to annotate functions that take a Ptr but do not store them as an EphPtr.
**/
@:genericBuild(indian._internal.PtrBuild.build())
extern class EphPtr<T> implements ArrayAccess<T>
{
	/**
		Returns the size of the type `T`, if known (not Ptr<Dynamic>). Otherwise returns `0`
	**/
	public var bytesSize(default,never):Int;

	/**
		Dereferences the pointer to the actual `T` object. If the actual `T` object is a Struct, and
		the underlying platform doesn't support naked structs, this field won't be available.
	**/
	public function dereference():T;
}
