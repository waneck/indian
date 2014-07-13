package indian.buf;

/**
	Represents a Pointer to an unmanaged memory chunk or to the stack.

	Shouldn't point to a managed memory location - thus avoiding the problems with moving GC's, pinning and managed memory layout
**/
class Ptr<T>
{
#if cpp
	var value:cpp.Pointer<T>;
#elseif cs
	var value:cs.system.IntPtr;
#else
	var value:haxe.Int64;
#end
}
