package indian;

import indian.Buffer in HeapPtr;

class Memory
{
	/**
		Allocates non-gc heap bytes, and returns a pointer to it.
		Any memmory allocated with this method *must* be freed by calling `Memory.free`
	**/
	public static function alloc(bytesLength:Int):HeapPtr
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
}
