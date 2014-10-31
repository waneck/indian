package indian.types;
import indian.*;

abstract CString(indian.Buffer) from indian.Buffer
{
	inline public function new(ptr)
	{
		this = ptr;
	}

	public static function fromString(arg)
	{
	}
}
