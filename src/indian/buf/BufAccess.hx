package indian.buf;

/**

**/
abstract BufAccess(BufAccessData)
{
	/**
		Dereferences the pointer at `offset` to another buffer; Returns `null` if it points to `null`.
		Warning: if the address points to an invalid memory location, it might segfault and cause an irecoverable error
	**/
	public function dereference(offset:Int):Null<Buffer>
	{
	}

	/**
		Sets the address of `bufToPoint`
	**/
	public function setAddressOf(offset:Int, bufToPoint:Null<Buffer>):Void
	{
	}
}
