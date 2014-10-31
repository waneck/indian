package indian.types.encoding;

@:unsafe @:dce class Encoding
{
	public static var Utf8(default,null) = new Utf8();
	public static var Utf32(default,null) = new Utf32();

	/**
		Converts `source` (byte array in UTF32 encoding) with exact byte length `byteLength` to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `throwErrors` is true, an invalid input will throw an error; Otherwise it will replace it by a valid character (probably `?` or unicode
		replacement character, `�` - U+FFFD)
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromUtf32(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int, throwErrors=false):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `source` encoded with current encoding to the byte array specified in `out` - encoded in UTF32.
		The conversion will not exceed the length defined by `maxByteLength`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `throwErrors` is true, an invalid input will throw an error; Otherwise it will replace it by a valid character (probably `?` or unicode
		replacement character, `�` - U+FFFD)
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertToUtf32(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int, throwErrors=false):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` and encoded with encoding `sourceEncoding` to the byte array specified in `out`,
		and with max length `maxByteLength` and encoded by `this`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `throwErrors` is true, an invalid input will throw an error; Otherwise it will replace it by a valid character (probably `?` or unicode
		replacement character, `�` - U+FFFD)
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromEncoding(source:indian.Buffer, byteLength:Int, sourceEncoding:Encoding, out:indian.Buffer, maxByteLength:Int):Int
	{
		if (this == sourceEncoding || this.name() == sourceEncoding.name())
		{
			if (source != out)
				Buffer.blit(source, 0, out, 0, byteLength);
			return byteLength;
		} else if (this.isUtf32()) {
			return sourceEncoding.convertToUtf32(source,byteLength, out,maxByteLength);
		} else if (sourceEncoding.isUtf32()) {
			return this.convertFromUtf32(source,byteLength, out,maxByteLength);
		} else {
			// check if we need an extra buffer
		}
	}

	private function isUtf32():Bool
	{
		return false;
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` and encoded with encoding `sourceEncoding` to the byte array specified in `out`,
		and with max length `maxByteLength` and encoded by `this`.

		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `throwErrors` is true, an invalid input will throw an error; Otherwise it will replace it by a valid character (probably `?` or unicode
		replacement character, `�` - U+FFFD)
		If `out` is null, the conversion will not be performed and the total number of bytes needed to perform the conversion will be returned.

		It is safe to pass the exact same pointer `source` to `out`. This may cause a temporary buffer to be used, so use this with care.
		@returns the amount of source bytes consumed in the operation
	**/
	inline public function convertToEncoding(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxByteLength:Int, outEncoding:Encoding):Int
	{
		return outEncoding.convertFromEncoding(source,byteLength,this,out,maxByteLength);
	}

	/**
		Converts `string` (assuming native target enconding) to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxByteLength`.
		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		@returns the amount of source bytes consumed in the operation
	**/
	public function convertFromString(string:String, out:indian.Buffer, maxByteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `buf`, with byte length `length` into a String enconded on the native target enconding.
	**/
	public function convertToString(buf:indian.Buffer, length:Int):String
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

	public function toString()
	{
		return name() + ' Encoding';
	}
}
