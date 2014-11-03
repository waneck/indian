#include "common.h"

/** `pinning` and address get **/
value tau_strptr(value str)
{
	val_check(str,string);
	return alloc_ptr(val_string(str));
}
DEFINE_PRIM(tau_strptr,1);

/** pointer manipulation helpers **/

value tau_memmove(value src_ptr, value src_pos, value dest_ptr, value dest_pos, value len)
{
	char *src = (char *) val_ptr(src_ptr);
	char *dest = (char *) val_ptr(dest_ptr);

	memmove( dest + ( (size_t) val_int64(dest_pos) ), src + ( (size_t) val_int64(src_pos) ), (size_t) val_uint64(len) );
	return val_null;
}
DEFINE_PRIM(tau_memmove,5);

value tau_memcpy(value src_ptr, value src_pos, value dest_ptr, value dest_pos, value len)
{
	char *src = (char *) val_ptr(src_ptr);
	char *dest = (char *) val_ptr(dest_ptr);

	memcpy( dest + ( (size_t) val_int64(dest_pos) ), src + ( (size_t) val_int64(src_pos) ), (size_t) val_uint64(len) );
	return val_null;
}
DEFINE_PRIM(tau_memcpy,5);

value tau_memcmp(value ptr1_ptr, value ptr1_pos, value ptr2_ptr, value ptr2_pos, value len)
{
	char *ptr1 = (char *) val_ptr(ptr1_ptr);
	char *ptr2 = (char *) val_ptr(ptr2_ptr);

	return alloc_int(memcmp( ptr1 + ( (size_t) val_int64(ptr1_pos) ), ptr2 + ( (size_t) val_int64(ptr2_pos) ), (size_t) val_uint64(len) ));
}
DEFINE_PRIM(tau_memcmp,5);

value tau_physcmp(value ptr1_ptr, value ptr2_ptr)
{
	void *ptr1 = (void *) val_ptr(ptr1_ptr);
	void *ptr2 = (void *) val_ptr(ptr2_ptr);

	if (ptr1 < ptr2)
		return alloc_int(-1);
	else if (ptr1 > ptr2)
		return alloc_int(1);
	else
		return alloc_int(0);
}
DEFINE_PRIM(tau_physcmp,2);

value tau_strlen(value ptr, value offset)
{
	char *ptr1 = (char *) val_ptr(ptr);
	return alloc_int( strlen((const char *) (ptr1 + ( (size_t) val_int64(offset) ))) );
}
DEFINE_PRIM(tau_strlen,2);

value tau_ptr_of_buffer( value buf )
{
	// val_check(buf, buffer);
	val_check(buf,string);
	return alloc_ptr( val_string(buf) );
}
DEFINE_PRIM(tau_ptr_of_buffer,1);

value tau_alloc( value len )
{
	return alloc_ptr(calloc(1, (size_t) val_uint64(len) ));
}
DEFINE_PRIM(tau_alloc,1);

value tau_free( value ptr )
{
	free(val_ptr(ptr));
	return val_null;
}
DEFINE_PRIM(tau_free,1);

value tau_ptr_add( value ptr, value offset )
{
	return alloc_ptr( (void *) (( (char *) val_ptr(ptr) ) + ( (size_t) val_int64(offset) )) );
}
DEFINE_PRIM(tau_ptr_add,2);

value tau_get_ui8(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_int(*src);
}
DEFINE_PRIM(tau_get_ui8,2);

value tau_get_ui16(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_int(*( (unsigned short *) src ) );
}
DEFINE_PRIM(tau_get_ui16,2);

value tau_get_i32(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_best_int(*( (int *) src ) );
}
DEFINE_PRIM(tau_get_i32,2);

value tau_get_i64(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_uint64(*( (hx_uint64 *) src ) );
}
DEFINE_PRIM(tau_get_i64,2);

value tau_get_f32(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_float((double) *( (float *) src ) );
}
DEFINE_PRIM(tau_get_f32,2);

value tau_get_f64(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_float(*( (double *) src ) );
}
DEFINE_PRIM(tau_get_f64,2);

value tau_set_ui8(value ptr, value base_addr, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	src[0] = val_any_int(val);
	return val;
}
DEFINE_PRIM(tau_set_ui8,3);

value tau_set_ui16(value ptr, value base_addr, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	( (unsigned short *) src )[0] = val_any_int(val);
	return val;
}
DEFINE_PRIM(tau_set_ui16,3);

value tau_set_i32(value ptr, value base_addr, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	( (int *) src )[0] = val_any_int(val);
	return val;
}
DEFINE_PRIM(tau_set_i32,3);

value tau_set_i64(value ptr, value base_addr, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	( (hx_uint64 *) src )[0] = val_uint64(val);
	return val;
}
DEFINE_PRIM(tau_set_i64,3);

value tau_set_f32(value ptr, value base_addr, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	( (float *) src )[0] = val_number(val);
	return val;
}
DEFINE_PRIM(tau_set_f32,3);

value tau_set_f64(value ptr, value base_addr, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	( (double *) src )[0] = val_number(val);
	return val;
}
DEFINE_PRIM(tau_set_f64,3);

value tau_read_string_len(value ptr, value base_addr, value size)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	val_check(size,int);
	int ssize = val_any_int(size);
	return copy_string( (const char *) src, ssize );
}
DEFINE_PRIM(tau_read_string_len,3);

value tau_read_string(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_string( ( const char * ) src );
}
DEFINE_PRIM(tau_read_string,2);

value tau_write_string_len(value ptr, value base_addr, value size, value string)
{
	unsigned char *addr = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		addr += (size_t) val_int64(base_addr);
	}
	val_check(size,int);
	val_check(string,string);
	int len = val_strlen(string);
	int isize = val_any_int(size);
	if (isize < len)
	{
		len = isize;
	}
	memcpy( addr, val_string(string), len );
	if (len < isize)
		addr[len] = '\0'; //for compat
	return alloc_int(len);
}
DEFINE_PRIM(tau_write_string_len,5);

value tau_write_string(value ptr, value base_addr, value string)
{
	unsigned char *addr = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		addr += (size_t) val_int64(base_addr);
	}
	val_check(string,string);
	int len = val_strlen(string);
	memcpy( addr, val_string(string), len );
	addr[len] = '\0';
	return alloc_int(len);
}
DEFINE_PRIM(tau_write_string,3);

value tau_set_ptr(value ptr, value base_addr, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	( (void **) src )[0] = val_ptr(val);
	return val;
}
DEFINE_PRIM(tau_set_ptr,3);

value tau_get_ptr(value ptr, value base_addr)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_int64(base_addr);
	}
	return alloc_ptr(*( (void **) src ) );
}
DEFINE_PRIM(tau_get_ptr,2);
