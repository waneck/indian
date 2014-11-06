package indian._impl;

typedef AnyPtrType =
#if cs
	cs.system.IntPtr
#else
	PointerType<Dynamic>
#end
