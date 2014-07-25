package indian._internal;
#if macro
import haxe.macro.Context.*;
#end

// Some code generation definitions for the target platform
class Platform
{
	public static var structType(default,null):StructType =
#if macro
		if (defined('cs'))
			SClass
		else if (defined('cpp'))
			SUntypedMagic
		else
			SUnsupported
#elseif cs
		SClass
#elseif cpp
		SUntypedMagic
#else
		SUnsupported
#end;

		public static var pointerToStructType(default,null):PtrStructType =
}


enum StructType
{
	/**
		The platform supports declaration of structs as classes, so a real class type is generated
		Supported platforms: c#
	**/
	SClass;
	/**
		The underlying platform supports declaration of structs but does not exposes them.
		Some platform magic will need to be done
		Supported platforms: cpp
	**/
	SUntypedMagic;
	/**
		The underlying platform does not support declaration of structs. "Naked" structs will not be available
	**/
	SUnsupported;
}

enum PtrStructType
{
	/**
		A Pointer to a struct is natively supported
	**/
	PNative;

	/**
		A Pointer to a struct is
	**/
	PBuffer;
}
