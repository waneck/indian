#include "common.h"

static value tau_i64_mul( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) * val_uint64(i) );
}
DEFINE_PRIM(tau_i64_mul, 2);

static value tau_i64_div ( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) / val_uint64(i) );
}
DEFINE_PRIM(tau_i64_div , 2);

static value tau_i64_mod ( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) % val_uint64(i) );
}
DEFINE_PRIM(tau_i64_mod , 2);

static value tau_i64_add( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) + val_uint64(i) );
}
DEFINE_PRIM(tau_i64_add, 2);

static value tau_i64_sub( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) - val_uint64(i) );
}
DEFINE_PRIM(tau_i64_sub, 2);

static value tau_i64_shr ( value this1, value i)
{
	return alloc_uint64( ( (long long int) val_uint64(this1) ) >> val_any_int(i) );
}
DEFINE_PRIM(tau_i64_shr , 2);

static value tau_i64_ushr( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) >> val_any_int(i) );
}
DEFINE_PRIM(tau_i64_ushr, 2);

static value tau_i64_shl( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) << val_any_int(i) );
}
DEFINE_PRIM(tau_i64_shl, 2);

static value tau_i64_and ( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) & val_uint64(i) );
}
DEFINE_PRIM(tau_i64_and , 2);

static value tau_i64_or ( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) | val_uint64(i) );
}
DEFINE_PRIM(tau_i64_or , 2);

static value tau_i64_xor ( value this1, value i)
{
	return alloc_uint64( val_uint64(this1) ^ val_uint64(i) );
}
DEFINE_PRIM(tau_i64_xor , 2);

static value tau_i64_compare( value this1, value i2 )
{
	hx_uint64 ii1 = val_uint64(this1), ii2 = val_uint64(i2);
	return alloc_int( ii1 > ii2 ? 1 : (ii1 < ii2) ? -1 : 0 );
}
DEFINE_PRIM(tau_i64_compare, 2);

static value tau_i64_make( value high, value low )
{
	hx_uint64 ilow = (hx_uint64) ((unsigned int) val_any_int(low) );
	hx_uint64 ihigh = (hx_uint64) ((unsigned int) val_any_int(high) );
	hx_uint64 ret = (ihigh << 32) | ilow;
	// printf("%lld (%lld), %lld  - %llx == %llx\n\n",ihigh, ihigh << 32,ilow,ilow,ret);
	return alloc_uint64(ret);
}
DEFINE_PRIM(tau_i64_make, 2);

static value tau_i64_to_int( value i )
{
	return alloc_best_int( (int) val_uint64(i) );
}
DEFINE_PRIM(tau_i64_to_int, 1);

static value tau_i64_to_str( value this1 )
{
	char str[25];
	sprintf(str, "%lld", (val_uint64(this1)));
	return alloc_string(str);
}
DEFINE_PRIM(tau_i64_to_str, 1);

static value tau_i64_to_hex( value this1 )
{
	char str[19];
	sprintf(str, "0x%016llx", val_uint64(this1));
	return alloc_string(str);
}
DEFINE_PRIM(tau_i64_to_hex, 1);
