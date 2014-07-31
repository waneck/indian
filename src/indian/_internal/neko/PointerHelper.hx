package indian._internal.neko;
import neko.Lib;

class PointerHelper
{
	public static var getFloat32:Dynamic = Lib.load('indian','tau_get_f32',2);
	public static var getFloat64:Dynamic = Lib.load('indian','tau_get_f64',2);
	public static var getPointer:Dynamic = Lib.load('indian','tau_get_ptr',2);
	public static var getUInt8:Dynamic = Lib.load('indian','tau_get_ui8',2);
	public static var getUInt16:Dynamic = Lib.load('indian','tau_get_ui16',2);
	public static var getInt32:Dynamic = Lib.load('indian','tau_get_i32',2);
	public static var getInt64:Dynamic = Lib.load('indian','tau_get_i64',2);
	public static var setUInt8:Dynamic = Lib.load('indian','tau_set_ui8',3);
	public static var setUInt16:Dynamic = Lib.load('indian','tau_set_ui16',3);
	public static var setInt32:Dynamic = Lib.load('indian','tau_set_i32',3);
	public static var setInt64:Dynamic = Lib.load('indian','tau_set_i64',3);
	public static var setFloat32:Dynamic = Lib.load('indian','tau_set_f32',3);
	public static var setFloat64:Dynamic = Lib.load('indian','tau_set_f64',3);
	public static var setPointer:Dynamic = Lib.load('indian','tau_set_ptr',3);

	public static var alloc:Dynamic = Lib.load('indian','tau_alloc',1);
	public static var free:Dynamic = Lib.load('indian','tau_free',1);
	public static var add:Dynamic = Lib.load('indian','tau_ptr_add',2);

	public static var memmove:Dynamic = Lib.load('indian','tau_memmove',5);
}
