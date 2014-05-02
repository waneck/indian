package indian.buf;

/**
	Represents a memory address associated with an unmanaged resource.
	Provides a mechanism to free resources and may finalize instances when the last GcHandle associated with the said address is collected.

## Remarks
	The finalizer interface **may not be available on all implementations**, so in order to be true cross-target, it should be used only
	to detect leaked objects, and `dispose` must still always be called.
	Moreover, the actual size occupied by the referenced handle is opaque to the Gargabe Collector, so more memory may be used than it is necessary.
**/
abstract GcHandle(GcHandleData) from GcHandleData to GcHandleData
{
	@:extern inline public function new(data:GcHandleData)
	{
		this = data;
	}

	public function isNull():Bool
	{
	}

	@:to inline public function pointer():Ptr
	{
	}

	@:to inline public function mem():MemoryChunk
	{
	}

	public function dispose():Void
	{
	}
}


class GcHandleData //implements IDisposable
{
	public function dispose()
	{
	}

#if (cpp || neko || java || cs)
	public function hasFinalizer():Bool
	{
	}

	/**
		Sets the finalizer to this object. Unless `allowOverride` is set to true, no other function may be set
		after `fn` is set.

		@throws InvalidOperation when the finalizer is already set and `allowOverride` was set to `false` at the time it was first set.
	**/
	public function setFinalizer(fn:GcHandleData->Void, allowOverride=false)
	{
	}
#end
}
