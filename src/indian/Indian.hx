package indian;
import indian.Buffer;

@:unsafe class Indian
{
	/**
		Allocates non-gc heap bytes, and returns a pointer to it.
		Any memmory allocated with this method *must* be freed by calling `Indian.free`
	**/
	public static function alloc(bytesLength:Int):Buffer
	{
#if cpp
		return cast indian._internal.cpp.Memory.alloc(bytesLength);
#elseif neko
		return cast indian._internal.neko.PointerHelper.alloc(bytesLength);
#elseif java
		return cast indian._internal.java.Pointer.alloc(bytesLength);
#elseif cs
		return cast cs.system.runtime.interopservices.Marshal.AllocHGlobal(bytesLength).ToPointer();
#else
#error 'Unsupported platform'
#end
	}

	/**
		Tries to allocate a memory of size `bytesLength` in the stack.
		The success of the operation depends on the platform support for it.
		If it is not possible to allocate in the stack, `bytesLength` will be allocated in the heap instead.
		Any memory allocated with this method *must* be freed by calling `Indian.stackfree`
	**/
	macro public static function stackalloc(bytesLength:Int):Buffer
	{
	}

	/**
		Frees the memory allocated by `stackalloc`.
	**/
	macro public static function stackfree(ptr:Buffer)
	{
	}

	inline public static function supportsStackAlloc():Bool
	{
#if (cpp || cs)
		return true;
#else
		return false;
#end
	}
}
