package indian;

/**
	This class binds a pointer to a finalizer. When this reference of GcRef is garbage collected, its finalizer is called.
**/
class GcRef
{
	public var ref(default,null):AnyPtr;

	public function new(ptr:AnyPtr, size:Int=0, ?finalizer:GcRef->Void)
	{
	}

	private static function defaultFinalizer(ref:GcRef)
	{
	}
}
