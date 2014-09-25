package indian.types.encoding;

class Encoding
{
	/**
		Gets the byte length needed to convert `string` (assuming native target encoding) to a byte array
	**/
	public function getByteLength(string:String):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `string` (assuming native target enconding) to the byte array specified in `out`.
		If `maxLength` is greater than 0, conversion will not exceed the length defined, and the function will return `false`.
		Otherwise - if `string` fits entirely into `out`, the function will return `true`
	**/
	public function fromString(string:String, out:indian.Buffer, maxLength:Int):Bool
	{
		return throw "Not Implemented";
	}

	/**
		Converts `buf`, with `length` into a String enconded on the native target enconding
	**/
	public function toString(buf:indian.Buffer, length:Int):String
	{
		return throw "Not Implemented";
	}
}
