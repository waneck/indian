package indian;
import indian.types.*;

/**
	This is equivalent to a `void *` pointer in C. It's a pointer, but its value is not known.
	All `indian.Ptr` types can be interpreted as `AnyPtr`, and it can be used outside an unsafe context
 **/
abstract AnyPtr(AnyPtr_t) from AnyPtr_t
{
	public static var size(get,never):Int;
	/**
		Adds an offset to the value of a pointer
	**/
	@:op(A+B) public function advance(nth:Int):AnyPtr;

	/**
		Subtracts an offset to the value of a pointer
	**/
	@:op(A-B) public function subtract(nth:Int):AnyPtr;

	/**
		Converts the pointer to an Int value
	**/
	public function toInt():Int;

	public function toInt64():Int64;
}
