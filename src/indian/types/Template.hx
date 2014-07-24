package indian.types;

typedef Template =
#if cpp
	cpp.Template
#elseif cs
	cs.StdTypes.Template
#elseif java
	java.StdTypes.Template
#else
	Int
#end;

