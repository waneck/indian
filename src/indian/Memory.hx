package indian;
import indian.Buffer in HeapPtr;

@:unsafe class Memory
{
	/**
		Allocates non-gc heap bytes, and returns a pointer to it.
		Any memory allocated with this method *must* be freed by calling `Memory.free`
	**/
	inline public static function alloc(bytesLength:Int):HeapPtr
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

	inline public static function free(ptr:HeapPtr):Void
	{
#if cpp
		indian._internal.cpp.Memory.m_free(cast ptr);
#elseif neko
		indian._internal.neko.PointerHelper.free(ptr);
#elseif java
		indian._internal.java.Pointer.free(cast ptr);
#elseif cs
		var ptr:cs.Pointer<Void> = cast ptr;
		cs.system.runtime.interopservices.Marshal.FreeHGlobal(new cs.system.IntPtr(ptr));
#else
#error 'Unsupported platform'
#end
	}
}
