package indian._macro.helpers;
using StringTools;

class ShortPack
{
	var pack2short:Map<String,String> = new Map();
	var short2pack:Map<String,String> = new Map();

	public function new()
	{
	}

	public function encode(pack:Array<String>, name:String)
	{
		return switch (pack)
		{
			case []:
				switch (name)
				{
					case 'UInt8':
						'B';
					case 'UInt16':
						'S';
					case 'Bool':
						'Z';
					case 'Single':
						'F';
					case 'Float':
						'D';
					case 'Int':
						'I';
					case 'Int64':
						'J';
					case _:
						'L' + name;
				}
			case ['indian','structs']:
				name;
			case ['indian','pointers']:
				name;
			case _:
				'L' + getShortPack(pack) + name;
		}
	}

	public function getShortPack(packarr:Array<String>):String
	{
		var pack = packarr.join('.').trim();
		if (pack == '') return '';

		var ret = pack2short[pack];
		if (ret != null)
			return ret;
		var nchars = [ for (r in packarr) 1 ];
		var curChar = 0;
		while(true)
		{
			var trial = new StringBuf(),
					i = 0;
			for (pack in packarr)
			{
				var nchar = nchars[i++];
				trial.add(pack.substr(0,nchar));
			}
			var r = trial.toString();
			var ret = short2pack[r];
			if (ret == null)
			{
				short2pack[r] = pack;
				pack2short[pack] = r;
				return r;
			}

			var firstChar = curChar;
			while(true)
			{
				var nchar = (nchars[curChar] += 1);
				if (nchar <= packarr[curChar].length)
				{
					curChar++;
					if (curChar >= nchars.length) curChar = 0;
					break;
				}
				if (++curChar >= nchars.length)
				{
					curChar = 0;
				}
				if (curChar == firstChar) // tried them all
				{
					var ret = pack2short[pack] = '$' + packarr.join("$");
					short2pack[ret] = pack;
					return ret;
				}
			}
		}
	}

}
