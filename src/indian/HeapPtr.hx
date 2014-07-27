package indian;

@:genericBuild(indian._internal.PtrBuild.build())
extern class HeapPtr<T> implements ArrayAccess<T>
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

	/**
		Casts itself to the stack-restricted Ptr type
	**/
	@:to public function toPtr():Ptr<T>;
}

