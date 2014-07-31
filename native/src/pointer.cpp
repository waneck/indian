#include "common.h"

/** pointer manipulation helpers **/

value tau_memmove(value src_ptr, value src_pos, value dest_ptr, value dest_pos, value len)
{
	char *src = (char *) val_ptr(src_ptr);
	char *dest = (char *) val_ptr(dest_ptr);

	memmove( dest + ( (size_t) val_uint64(dest_pos) ), src + ( (size_t) val_uint64(src_pos) ), (size_t) val_uint64(len) );
	return val_null;
}
DEFINE_PRIM(tau_memmove,5);

value tau_memcpy(value src_ptr, value src_pos, value dest_ptr, value dest_pos, value len)
{
	char *src = (char *) val_ptr(src_ptr);
	char *dest = (char *) val_ptr(dest_ptr);

	memcpy( dest + ( (size_t) val_uint64(dest_pos) ), src + ( (size_t) val_uint64(src_pos) ), (size_t) val_uint64(len) );
	return val_null;
}
DEFINE_PRIM(tau_memcpy,5);

value tau_ptr_of_buffer( value buf )
{
	// val_check(buf, buffer);
	val_check(buf,string);
	return alloc_ptr( val_string(buf) );
}
DEFINE_PRIM(tau_ptr_of_buffer,1);

value tau_get_ui8(value ptr, value base_addr, value offset)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		return alloc_int(*(src + val_any_int(offset)));
	} else if (!val_is_null(offset)) {
		return alloc_int(*(src + val_uint64(offset)));
	}
	return alloc_int(*src);
}
DEFINE_PRIM(tau_get_ui8,3);

value tau_get_ui16(value ptr, value base_addr, value offset)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	return alloc_int(*( (unsigned short *) src ) );
}
DEFINE_PRIM(tau_get_ui16,3);

value tau_get_i32(value ptr, value base_addr, value offset)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	return alloc_best_int(*( (int *) src ) );
}
DEFINE_PRIM(tau_get_i32,3);

value tau_get_i64(value ptr, value base_addr, value offset)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	return alloc_uint64(*( (hx_uint64 *) src ) );
}
DEFINE_PRIM(tau_get_i64,3);

value tau_get_f32(value ptr, value base_addr, value offset)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	return alloc_float((double) *( (float *) src ) );
}
DEFINE_PRIM(tau_get_f32,3);

value tau_get_f64(value ptr, value base_addr, value offset)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	return alloc_float(*( (double *) src ) );
}
DEFINE_PRIM(tau_get_f64,3);


value tau_set_ui8(value ptr, value base_addr, value offset, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	src[0] = val_any_int(val);
	return val;
}
DEFINE_PRIM(tau_set_ui8,4);

value tau_set_ui16(value ptr, value base_addr, value offset, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	( (unsigned short *) src )[0] = val_any_int(val);
	return val;
}
DEFINE_PRIM(tau_set_ui16,4);

value tau_set_i32(value ptr, value base_addr, value offset, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	( (int *) src )[0] = val_any_int(val);
	return val;
}
DEFINE_PRIM(tau_set_i32,4);

value tau_set_i64(value ptr, value base_addr, value offset, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	( (int *) src )[0] = val_uint64(val);
	return val;
}
DEFINE_PRIM(tau_set_i64,4);

value tau_set_f32(value ptr, value base_addr, value offset, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	( (float *) src )[0] = val_float(val);
	return val;
}
DEFINE_PRIM(tau_set_f32,4);

value tau_set_f64(value ptr, value base_addr, value offset, value val)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	( (double *) src )[0] = val_float(val);
	return val;
}
DEFINE_PRIM(tau_set_f64,4);

value tau_read_string_len(value ptr, value base_addr, value offset, value size)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	val_check(size,int);
	int ssize = val_any_int(size);
	return copy_string( (const char *) src, ssize );
}
DEFINE_PRIM(tau_read_string_len,4);

value tau_read_string(value ptr, value base_addr, value offset)
{
	unsigned char *src = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		src += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		src += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		src += (size_t) val_uint64(offset);
	}
	return alloc_string( ( const char * ) src );
}
DEFINE_PRIM(tau_read_string,3);

value tau_write_string_len(value ptr, value base_addr, value offset, value size, value string)
{
	unsigned char *addr = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		addr += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		addr += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		addr += (size_t) val_uint64(offset);
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

value tau_write_string(value ptr, value base_addr, value offset, value string)
{
	unsigned char *addr = (unsigned char *) val_ptr(ptr);
	if (!val_is_null(base_addr))
	{
		addr += (size_t) val_uint64(base_addr);
	}
	if (val_is_any_int(offset))
	{
		addr += (size_t) val_any_int(offset);
	} else if (!val_is_null(offset)) {
		addr += (size_t) val_uint64(offset);
	}
	val_check(string,string);
	int len = val_strlen(string);
	memcpy( addr, val_string(string), len );
	addr[len] = '\0';
	return alloc_int(len);
}
DEFINE_PRIM(tau_write_string,4);
