package indian.buf;

/**
	A Ptr represents a pointer to a natively-allocated memory chunk.
**/
abstract Ptr<T>(PtrData<T>)
{
	inline public function new(pointer)
	{
		this = pointer;
	}

	inline public function descriptor():MemChunk
	{
	}

	inline public function eq(to:Ptr<T>):Bool
	{

	}

	@:deprecated("Do not use the equality operator with pointers as it's not reliable. Use `eq' instead")
	@:op(A == B) inline public function equals(to:Ptr<T>):Bool
	{
		return eq(to);
	}

	@:deprecated("Do not use the equality operator with pointers as it's not reliable. Use `eq' instead")
	@:op(A != B) inline public function notEquals(to:Ptr<T>):Bool
	{
		return !eq(to);
	}
}
