package indian;
import indian.buf.*;

class MemChunk
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
	public var parent(get,never):Null<Ptr>;

	/**
		Sets the buffer length if it wasn't set yet.

		@throws `UnsafeOperation` if the buffer length was already set and has a different value than `len`
	**/
	public function setLength(len:Int):Void;

	public function setLength64(len:Int64):Void;

	public function getPointer():Ptr;

	public function advanceBytes(nbytes:Int):MemChunk
	{
	}

	public function advanceBytes64(nbytes:Int64):MemChunk
	{
	}

	/**
		Gets a buffer from the pointer.
		The returned buffer can only be stored in the stack - it cannot be stored in fields nor captured by functions
	**/
	inline public function buffer():Buffer
	{
		return new Buffer(this);
	}
}
