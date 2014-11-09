package indian._macro;

abstract LayoutAgg(LayoutAggData) from LayoutAggData
{
	@:extern inline public function new()
	{
		this = [for (name in Layout.platforms) { name:name, offset:0 }];
	}

	public function align(layout:Layout)
	{
	}

	public function add(layout:Layout)
	{
	}
}

typedef LayoutAggData = Array<{ offset:Int, name:String }>
