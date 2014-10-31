package indian;
import indian.Buffer in HeapPtr;

/**
	This class provides allocation / deallocation and address-related operations that are made available in
	a more safe manner through the `indian.Indian` interface
**/
@:unsafe class Memory
{
	/**
		Allocates non-gc heap bytes, and returns a pointer to it.
		Any memory allocated with this method *must* be freed by calling `Memory.free`
	**/
	inline public static function alloc(bytesLength:Int):HeapPtr
	{
#if cpp
		return cast indian._impl.cpp.Memory.alloc(bytesLength);
#elseif neko
		return cast indian._impl.neko.PointerHelper.alloc(bytesLength);
#elseif java
		return cast indian._impl.java.Pointer.alloc(bytesLength);
#elseif cs
		return cast cs.system.runtime.interopservices.Marshal.AllocHGlobal(bytesLength).ToPointer();
#else
#error 'Unsupported platform'
#end
	}

	inline public static function free(ptr:HeapPtr):Void
	{
#if cpp
		indian._impl.cpp.Memory.free(cast ptr);
#elseif neko
		indian._impl.neko.PointerHelper.free(ptr);
#elseif java
		indian._impl.java.Pointer.free(cast ptr);
#elseif cs
		var ptr:cs.Pointer<Void> = cast ptr;
		cs.system.runtime.interopservices.Marshal.FreeHGlobal(new cs.system.IntPtr(ptr));
#else
#error 'Unsupported platform'
#end
	}
}
