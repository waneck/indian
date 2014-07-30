#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif
#include "common.h"

extern "C" {
DEFINE_KIND(k_ui64);
DEFINE_KIND(k_raw_ui64);
DEFINE_KIND(k_ptr);
}

typedef struct {
	hx_uint64 value;
} i64_container;

hx_uint64 val_uint64(value v)
{
	if (val_is_any_int(v))
	{
		return (hx_uint64) (unsigned int) val_any_int(v);
	} else if (val_is_abstract(v)) {
		if (val_is_kind(v,k_ui64))
			return ((i64_container *) val_data(v))->value;
		else
			return (hx_uint64) val_data(v);
	} else if (val_is_object(v)) {
		static field id_high = val_id("high");
		static field id_low = val_id("low");
		value vhigh = val_field(v,id_high);
		value vlow = val_field(v,id_low);
		if (!val_is_any_int(vhigh) || !val_is_any_int(vlow))
		{
			buffer buf = alloc_buffer( "(val_uint64) Invalid haxe.Int64 parameter: " );
			val_buffer(buf,v);
			val_throw( buffer_to_string(buf) );
		}
		return ( ((hx_uint64) val_any_int(vhigh)) << 32 ) | ( (hx_uint64) val_any_int(vlow) );
	} else if (val_is_float(v)) {
		return (hx_uint64) val_float(v);
	} else {
		{
			buffer buf = alloc_buffer( "(val_uint64) Invalid Int64 parameter: " );
			val_buffer(buf,alloc_int(val_type(v)));
			val_buffer(buf,alloc_string(", "));
			val_buffer(buf,v);
			val_throw( buffer_to_string(buf) );
		}
		return 0ULL;
	}
}

static void i64_container_finalize( value v ) 
{
	free( val_data(v) );
#ifndef HXCPP_COMPATIBLE
	val_kind(v) = NULL;
#endif
}

value alloc_uint64(hx_uint64 v)
{
	if (v <= 0xFFFFFFFFULL) {
		return alloc_best_int( (int) v );
	} else if (sizeof(hx_uint64) <= sizeof(void *)) {
		return alloc_abstract(k_raw_ui64, (void *) v);
	} else {
		// only on 32-bit
		i64_container *container = (i64_container *) malloc( sizeof(i64_container) );
		container->value = v;
		value ret = alloc_abstract(k_ui64, container);
		val_gc(ret,i64_container_finalize);
		return ret;
	}
}

void *val_ptr(value ptr)
{
	if (val_is_abstract(ptr))
	{
		// We won't check if it's of kind k_ptr, because other libs may want to
		// use it, and this is an unsafe library after all
		return val_data(ptr);
	} else if (val_is_null(ptr)) {
		return NULL;
	}

	buffer buf = alloc_buffer("Invalid pointer: ");
	val_buffer(buf,ptr);
	val_throw( buffer_to_string(buf) );
	return NULL;
}

value alloc_ptr(void *ptr)
{
	return alloc_abstract(k_ptr, ptr);
}
