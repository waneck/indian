package indian._impl;

typedef AnyPtrType =
#if java
	indian._impl.java.Pointer
#elseif cs
	cs.system.IntPtr
#elseif cpp
	cpp.Pointer<Dynamic>
#elseif neko
	Dynamic
#else
#errpr "Not supported"
#end
