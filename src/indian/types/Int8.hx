package indian.types;

typedef Int8 =
#if cpp
	cpp.Int8
#elseif cs
	cs.StdTypes.Int8
#elseif java
	java.StdTypes.Int8
#else
	Int
#end;
