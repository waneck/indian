package indian.buf;

/**
	A MemoryChunk represents a pointer to a natively-allocated memory chunk.
**/
class MemoryChunk
{
	/**
		Returns the buffer length if it was set.

		If the buffer has no length set, returns `0`
		If the buffer's length is too big to store in an `Int`, returns a negative value
	**/
	public var length(get,never):Int;

	public var length64(get,never):Int64;

	/**
		Gets the containing memory chunk if available.
	**/
	public var parent(get,never):Null<MemoryChunk>;

	/**
		Sets the buffer length if it wasn't set yet.

		@throws `UnsafeOperation` if the buffer length was already set and has a different value than `len`
	**/
	public function setLength(len:Int):Void;

	public function setLength64(len:Int64):Void;
	/**
		Returns a `MemoryChunk` buffer pointing to the same address as `this`, but which doesn't throw any `UnsafeOperation` error
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
}
