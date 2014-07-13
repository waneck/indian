package indian.buf;

/**
	Represents a memory chunk associated with an unmanaged resource.
	Provides a mechanism to free resources and may finalize instances when the last GcHandle associated with the said address is collected.

## Remarks
	The finalizer interface **may not be available on all implementations**, so in order to be true cross-target, it should be used only
	to detect leaked objects, and `dispose` must still always be called.
	Moreover, the actual size occupied by the referenced handle is opaque to the Gargabe Collector, so more memory may be used than it is necessary.
**/
class MemoryChunk
{
	/**
		Returns the buffer length if it was set.

		If the buffer has no length set, returns `0`
		If the buffer's length is too big to store in an `Int`, returns a negative value

		@throws `ObjectDisposed` if root object was already disposed
	**/
	public var length(get,never):Int;

	public var length64(get,never):Int64;

	/**
		Gets the containing memory chunk if available.

		@throws `ObjectDisposed` if root object was already disposed
	**/
	public var parent(get,never):Null<MemoryChunk>;

	/**
		Sets the buffer length if it wasn't set yet.

		@throws `UnsafeOperation` if the buffer length was already set and has a different value than `len`
		@throws `ObjectDisposed` if root object was already disposed
	**/
	public function setLength(len:Int):Void;

	public function setLength64(len:Int64):Void;
	/**
		Returns a `MemoryChunk` buffer pointing to the same address as `this`, but doesn't throw any `UnsafeOperation` error
		@throws `ObjectDisposed` if root object was already disposed
	**/
	public function unsafe():UnsafeMemoryChunk;

	/**
		Creates a new view starting at offset `bytesOffset`.

		If `newLength` is set, also sets the length of the view. Otherwise `this.length - bytesOffset` will be used.

		@throws `OutOfBounds` error if `bytesOffset` is greater than `this.length` or if `bytesOffset + newLength` is greater than `this.length`
		@throws `UnsafeOperation` if `this` has no `length` set.
	**/
	public function view(bytesOffset:Int, ?newLength:Int):MemoryChunk;

	public function view64(bytesOffset:Int64, ?newLength:Int64):MemoryChunk;

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

	public function dispose():Void
	{
	}
}
