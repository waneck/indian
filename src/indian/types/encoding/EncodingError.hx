package indian.types.encoding;

/**
	Any Encoding-related error will result in an `EncodingError`
**/
enum EncodingError
{
	InvalidEncoding(encoding:String, col:Int, char:Int);
}
