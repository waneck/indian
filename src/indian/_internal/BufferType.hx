package indian._internal;

typedef BufferType =
#if cpp
	cpp.Pointer<cpp.UInt8>
#elseif cs
#if !unsafe
#error The Buffer type needs -D unsafe to be defined
#end
	cs.Pointer<cs.StdTypes.UInt8>
#elseif java
	indian._internal.java.Pointer
#elseif neko
	Dynamic
#else
	taurine.mem.RawMem
#end;
