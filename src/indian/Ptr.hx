package indian;

@:genericBuild(indian._internal.PtrBuild.build())
extern class Ptr<T> implements ArrayAccess<T>
{
	/**
		Returns the size of the type `T`, if known (not Ptr<Dynamic>). Otherwise returns `0`
	**/
	public var bytesSize(default,never):Int;

	/**
		Dereferences the pointer to the actual `T` object.
	**/
	public function dereference():T;
}
