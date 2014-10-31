package indian._impl;

typedef PointerType<T> =
#if cpp
	cpp.Pointer<T>
#elseif cs
#if !unsafe
#error The Pointer type needs -D unsafe to be defined
#end
	cs.Pointer<T>
#elseif java
	indian._impl.java.Pointer
#elseif neko
	Dynamic
#else
	taurine.mem.RawMem
#end;
