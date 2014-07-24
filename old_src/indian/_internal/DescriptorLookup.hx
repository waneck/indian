package indian._internal;
import haxe.Int64;

class DescriptorLookup
{
	private static var btree = new indian.ds.BTree();

	/**
		Sets the length of the pointer if it wasn't set before.
		@throws UnsafeOperation if the length was already set
		@throws InvalidArgument if the length is less than or equal to zero
	**/
	public static function setLength(addr:IntPtr, len:Int)
	{
	}

	public static function setLength64(addr:IntPtr, len:Int64)
	{
	}

	/**
		Gets the length of the pointer if it was set.
		If the pointer wasn't set before, returns 0
	**/
	public static function getLength(addr:IntPtr):Int
	{
	}

	/**
		Frees the length of the address
		@throws InvalidArgument if the length isn't set
	**/
	public static function freeLength(addr:IntPtr)
	{
	}
}
