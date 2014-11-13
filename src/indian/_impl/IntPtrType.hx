package indian._impl;

typedef IntPtrType =
#if cs
	cs.system.IntPtr
#else
	PointerType<Dynamic>
#end

