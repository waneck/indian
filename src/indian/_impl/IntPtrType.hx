package indian._impl;

typedef IntPtrType =
#if cs
	cs.system.IntPtr
#elseif cpp
	indian._impl.cpp.IntPtr
#else
	PointerType<Dynamic>
#end

