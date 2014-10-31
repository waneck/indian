package indian.types.encoding;

@:dce class Encoding
{
	public static var Utf8(default,null):Encoding = new Utf8();
	public static var Utf32(default,null):Encoding = new Utf32();

	/**
		Gets the byte length needed to convert `string` (assuming native target encoding) to a byte array
	**/
	public function getByteLength(string:String):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `source` (byte array in UTF32 encoding) with exact byte length `byteLength` to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.
		If `source` fits entirely into `out`, the function will return the byte length used. Otherwise - the operation will not complete entirely
		and the function will return `maxByteLength + 1`

		It is safe to pass the exact same pointer `source` to `out`.
	**/
	public function fromUtf32(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	@:extern inline private var checkPointer(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxLen:Int):Void
	{
		if (source != out)
		{
			if (out > source && out < (source + maxLen))
				throw EncodingError.OverlappingSource;
		}
	}

	/**
		Converts `source` encoded with current encoding to the byte array specified in `out` - encoded in UTF32.
		The conversion will not exceed the length defined by `maxByteLength`.
		If `source` fits entirely into `out`, the function will return the byte length used. Otherwise - the operation will not complete entirely
		and the function will return `maxByteLength + 1`

		It is safe to pass the exact same pointer `source` to `out`. If `source` however points to a location that partially overlaps `out`,
		this function will throw and the operation will fail.
	**/
	public function toUtf32(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `string` (assuming native target enconding) to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.
		If `source` fits entirely into `out`, the function will return the byte length used. Otherwise - the operation will not complete entirely
		and the function will return `maxByteLength + 1`
	**/
	public function fromString(string:String, out:indian.Buffer, maxByteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `buf`, with byte length `length` into a String enconded on the native target enconding
	**/
	public function toString(buf:indian.Buffer, length:Int):String
	{
		return throw "Not Implemented";
	}

	/**
		Returns encoding name
	**/
	public function name():String
	{
		return throw "Not Implemented";
	}
}
