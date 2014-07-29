#ifndef TAU_COMMON_H
#define TAU_COMMON_H 1
#include <hx/CFFI.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SET_FIELD(obj,f,val) { \
	static field field_ ##f = val_id( #f ); \
	alloc_field(obj , field_ ##f , val); \
}

#define SET_FIELD_i(obj,f,val) SET_FIELD(obj,f,alloc_int(val))
#define SET_ENUM(obj,e) SET_FIELD(obj,e,alloc_int(e))
#ifdef HX_LINUX
	#define		SET_ENUM_LINUX(obj,e) SET_ENUM(obj,e)
	#define		SET_ENUM_MAC(obj,e) SET_FIELD(obj,e,alloc_int(0))
#else
	#define		SET_ENUM_LINUX(obj,e) SET_FIELD(obj,e,alloc_int(0))
	#ifdef HX_MACOS
		#define	SET_ENUM_MAC(obj,e) SET_ENUM(obj,e)
	#else
		#define SET_ENUM_MAC(obj,e) SET_FIELD(obj,e,alloc_int(0))
	#endif
#endif


typedef unsigned long long hx_uint64;
typedef unsigned short hx_ui16;
typedef unsigned char hx_ui8;

hx_uint64 val_uint64(value v);
value alloc_uint64(hx_uint64 v);

void *val_ptr(value ptr);
value alloc_ptr(void *ptr);

#endif
