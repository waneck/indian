package indian.buf;

typedef PtrData<T> =
#if INDIAN_EMULATE_BUFFER
	haxe.io.BytesData;
#elseif cpp
	cpp.Pointer<Void>;
#elseif cs
	cs.system.IntPtr;
#elseif (js && nodejs)
	indian._internal.nodejs.Buffer;
#elseif js
	js.html.ArrayBuffer;
#elseif java
	java.nio.ByteBuffer;
// #elseif python
#elseif neko
	haxe.io.BytesData;
#else
	haxe.io.BytesData;
#end
