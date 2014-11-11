package indian._impl;

typedef SafePtrType =
#if cs
	cs.system.IntPtr
#else
	PointerType<Dynamic>
#end

