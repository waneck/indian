package indian.types;

abstract IntBool(Int) from Int
{
	@:from @:extern inline public static function fromBool(b:Bool):IntBool
	{
		return b ? 1 : 0;
	}

	@:to inline public function toBool():Bool
	{
		return this != 0;
	}
}
