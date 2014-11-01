package indian._impl.java;
import java.sun.misc.Unsafe;

@:suppressWarnings("deprecation")
class Unsafe
{
	public static var unsafe(default,null):java.sun.misc.Unsafe = {
		try
		{
			var ctor = java.Lib.toNativeType(java.sun.misc.Unsafe).getDeclaredConstructor(new java.NativeArray(0));
			ctor.setAccessible(true);
			cast ctor.newInstance(new java.NativeArray(0));
		}
		catch(e:Dynamic)
		{
			trace('Unsafe is not supported on this platform. Error:',e);
			null;
		}
	}
}
