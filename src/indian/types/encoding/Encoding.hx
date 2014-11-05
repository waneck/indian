package indian.types.encoding;
import indian.*;
import indian.Indian.*;

@:unsafe @:dce class Encoding
{
	public var terminationBytes(default,null):Int;
	public var name(default,null):String;
	var isUtf32(default,null):Bool = false;

	/**
		Converts `source` (byte array in UTF32 encoding) with exact byte length `byteLength` (excluding the \0 terminator) to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxOutByteLength`.

		- `byteLength` and `maxOutByteLength` cannot be more than 0xFFFF in this point

		@returns the amount of source bytes read and written in the operation
	**/
	private function convertFromUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,outMaxByteLength:Int):EncodingReturn
	{
		return throw "Not Implemented";
	}

	/**
		Converts `source` with exact byte length `byteLength` (excluding the \0 terminator) encoded with current encoding to the byte array specified in `out` - encoded in UTF32.
		The conversion will not exceed the length defined by `maxOutByteLength`.

		- `byteLength` and `maxOutByteLength` cannot be more than 0xFFFF in this point

		@returns the amount of source bytes read and written in the operation
	**/
	private function convertToUtf32(source:indian.Buffer,srcoffset:Int,byteLength:Int, out:indian.Buffer,outoffset:Int,outMaxByteLength:Int):EncodingReturn
	{
		return throw "Not Implemented";
	}

	/**
		Called internally to get the byte length of unknown length when needed
	 **/
	private function getByteLength(buf:Buffer):Int
	{
		return throw "Not Implemented";
	}

	public function addTermination(buf:Buffer, pos:Int):Void
	{
		throw "Not Implemented";
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` (excluding the \0 terminator) and encoded with encoding `sourceEncoding` to the byte array specified in `out`,
		and with max length `maxOutByteLength` and encoded by `this`.

		@returns the amount of source bytes written
	**/
	private function _convertFromEncoding(source:indian.Buffer,srcoffset:Int,byteLength:Int,sourceEncoding:Encoding, out:indian.Buffer,outoffset:Int,maxOutByteLength:Int):Int
	{
#if assertations
		if (maxOutByteLength < 0) throw 'assert: byteLength: $byteLength ; maxOutByteLength: $maxOutByteLength';
#end
		if (this == sourceEncoding || this.name == sourceEncoding.name)
		{
			if (byteLength < 0)
				byteLength = getByteLength(source);
			var outlen = byteLength;
			if (maxOutByteLength < outlen)
				outlen = maxOutByteLength;

			if (source != out)
				Buffer.blit(source,srcoffset, out,outoffset, outlen);
			return outlen;
		} else if (this.isUtf32) {
			var written = 0,
					read = 0;
			while (written < maxOutByteLength && ( byteLength < 0 || read < byteLength))
			{
				var srclen = byteLength - read;
				if (srclen > 0xFFF0) srclen = 0xFFF0;
				var outlen = maxOutByteLength - written;
				if (outlen > 0xFFF0) outlen = 0xFFF0;
				var er = sourceEncoding.convertToUtf32(source,srcoffset+read,srclen, out,outoffset+written,outlen);
				if (er.isEmpty())
					break;
				read += er.read;
				written += er.written;
			}
			return written;
		} else if (sourceEncoding.isUtf32) {
			var written = 0,
					read = 0;
			while (written < maxOutByteLength && ( byteLength < 0 || read < byteLength))
			{
				var srclen = byteLength - read;
				if (srclen > 0xFFF0) srclen = 0xFFF0;
				var outlen = maxOutByteLength - written;
				if (outlen > 0xFFF0) outlen = 0xFFF0;
				var er = this.convertFromUtf32(source,srcoffset+read,srclen, out,outoffset+written,outlen);
				if (er.isEmpty())
					break;
				read += er.read;
				written += er.written;
			}
			return written;
		} else {
			//use UTF32 intermediate representation
			var written = 0,
					read = 0;
			var neededBuf = byteLength << 2;
			if (neededBuf > 256) neededBuf = 256;
			var j = 0;
			autofree(buf = $stackalloc(neededBuf), {
				while(written < maxOutByteLength && ( byteLength < 0 || read < byteLength) )
				{
					var er = sourceEncoding.convertToUtf32(source,srcoffset+read,byteLength - read, buf,0,neededBuf);
					if (er.isEmpty())
						break;
					read += er.read;
					er = this.convertFromUtf32(buf,0,er.written, out,outoffset + written,maxOutByteLength - written);
					written += er.written;
				}
			});
			return written;
		}
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` (excluding the \0 terminator) and encoded with encoding `sourceEncoding` to the byte array specified in `out`,
		and with max length `maxOutByteLength` and encoded by `this`.
		If `byteLength` is less than 0, the length is inferred by the first encoding-dependent terminator sequence found.

		@returns the amount of source bytes written
	**/
	public function convertFromEncoding(source:indian.Buffer,byteLength:Int,sourceEncoding:Encoding, out:indian.Buffer,maxOutByteLength:Int):Int
	{
#if assertations
		if (source == null || sourceEncoding == null || out == null || maxOutByteLength < 0) throw 'assert: $source $sourceEncoding $out $maxOutByteLength';
#end
		var read = 0,
				written = 0;
		var srclen = byteLength - read;
		var outlen = maxOutByteLength - written;
		var er = _convertFromEncoding(source,read,srclen,sourceEncoding, out,written,outlen);
		written += er;
		return written;
	}

	/**
		Converts the byte array `source`, with byte length `byteLength` (excluding the \0 terminator) and encoded with encoding `this` to the byte array specified in `out`,
		and with max length `maxOutByteLength` and encoded by `outEncoding`.
		If `byteLength` is less than 0, the length is inferred by the first encondig terminator sequence found.

		@returns the amount of source bytes written
	**/
	inline public function convertToEncoding(source:indian.Buffer, byteLength:Int, out:indian.Buffer, maxOutByteLength:Int, outEncoding:Encoding):Int
	{
		return outEncoding.convertFromEncoding(source,byteLength,this,out,maxOutByteLength);
	}

	/**
		Returns the number of unicode code points that exist in `buf` with byte length `byteLength`.
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		If the encoding is not unicode, a character mapping will be used so that the returned length is still in unicode code point units.
	 **/
	public function count(buf:Buffer,byteLength:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Gets the byte offset for the unicode code point at position `pos` on buffer `buf`, with length `byteLength`
		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		If the encoding is not unicode, a character mapping will be used so that the position count is still in unicode code point units.
	**/
	public function getPosOffset(buf:Buffer, byteLength:Int, pos:Int):Int
	{
		return throw "Not Implemented";
	}

	/**
		Returns the needed byte length to exactly convert from string `str`.
		If `addTerminator` is true, adds space for the terminator as well
	**/
	public function neededLength(str:String, addTerminator:Bool):Int
	{
		return throw "Not Implemented";
	}

	/**
		Converts `string` (assuming native target enconding) to the byte array specified in `out`.
		The conversion will not exceed the length defined by `maxOutByteLength`.
		If `source` fits entirely into `out`, the function will return `byteLength`. Otherwise - the operation will not complete entirely
		and the function will return the amount of source bytes consumed.
		If `reserveTermination` is true, an extra space is reserved for the termination bytes. Termination will always be added if there are enough bytes.

		If `byteLength` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		@returns the amount of bytes written
	**/
	public function convertFromString(string:String, out:indian.Buffer, maxOutByteLength:Int, reserveTermination:Bool):Int
	{
		if (string.length == 0 && maxOutByteLength <= 0)
			return 0;
#if assertations
		if (string == null || out == null || maxOutByteLength < 0) throw 'assert: ${string==null} $out $maxOutByteLength';
#end
		// some input checking
		var origMaxByte = maxOutByteLength,
				termBytes = terminationBytes;

		if (reserveTermination) maxOutByteLength -= termBytes;
		if (maxOutByteLength <= 0)
		{
			if (maxOutByteLength == 0 && origMaxByte > 0)
			{
				this.addTermination(out,0);
				return termBytes;
			} else {
				return 0;
			}
		}

		var written = _convertFromString(string,out,maxOutByteLength);
		if (written <= (origMaxByte - termBytes))
			this.addTermination(out,written);
		return written;
	}

	/**
		This is where the actual work is done. Override this one
	**/
	private function _convertFromString(string:String, out:indian.Buffer, maxOutByteLength:Int):Int
	{
		var readLen = string.length;
#if (cs || java || js)
		readLen = readLen << 1;
#end
		var origMaxByte = maxOutByteLength,
				termBytes = terminationBytes;

		var written = 0,
				read = 0;
		pin(str = $ptr(string), {
			var curLen = readLen - read;
			var curOut = maxOutByteLength - written;
#if !(cs || java || js) // UTF-8
			var re = this._convertFromEncoding(str,read,curLen,Utf8.cur, out,written,curOut);
#else // UTF-16
			var re = this._convertFromEncoding(str,read,curLen,Utf16.cur, out,written,curOut);
#end
			written += re;
		});
		return written;
	}

	/**
		Converts `source`, with byte length `length` into a String enconded on the native target enconding.
		If `length` is less than 0, the source size will be inferred by looking for the encoding-dependent termination codepoint.
		The `length` parameter should not consider the \0 termination indicator as part of the length
	**/
	public function convertToString(source:indian.Buffer, length:Int, hasTermination:Bool):String
	{
		if (length <= 0)
			return '';
#if assertations
		if (source == null) throw 'assert: $source';
#end
		if (hasTermination) length -= this.terminationBytes;

		var ret = new StringBuf();
		// first convert into
		var neededBuf = length << 2;
		if (neededBuf > 256) neededBuf = 256;
		var read = 0;
		autofree(tmp = $stackalloc(neededBuf), {
			while(length < 0 || read < length)
			{
				var sendLen = length - read;
				if (sendLen > 0xFFF0) sendLen = 0xFFF0;
				var r = this.convertToUtf32(source,read,sendLen, tmp,0,neededBuf);

				if (r.isEmpty()) //found terminator
					break;

				read += r.read;
				for (i in 0...(r.written >> 2))
				{
					var cp = tmp.getInt32(i<<2);
#if !(cs || java || js) // UTF-8
					if (cp <= 0x7f)
					{
						ret.addChar(cp);
					} else if (cp <= 0x7FF) {
						ret.addChar(0xC0 | (cp >> 6));
						ret.addChar(0x80 | (cp & 0x3F));
					} else if (cp <= 0xFFFF) {
						ret.addChar( 0xE0 | (cp >> 12) );
						ret.addChar( 0x80 | ((cp >> 6) & 0x3F) );
						ret.addChar( 0x80 | (cp & 0x3F) );
					} else if (cp <= 0x10FFFF) {
						ret.addChar( 0xF0 | (cp >> 18) );
						ret.addChar( 0x80 | ((cp >> 12) & 0x3F) );
						ret.addChar( 0x80 | ((cp >> 6) & 0x3F) );
						ret.addChar( 0x80 | (cp & 0x3F) );
					} else {
						// invalid
						ret.addChar(0xef); ret.addChar(0xbf); ret.addChar(0xbd);
					}
#else // UTF-16
					if (cp < 0x10000)
					{
						ret.addChar(cp);
					} else if (cp <= 0x10FFFF) {
						ret.addChar( (cp >> 10) + 0xD7C0 );
						ret.addChar( (cp & 0x3FF) + 0xDC00 );
					} else {
						//invalid - shouldn't happen
						ret.addChar(0xFFFD);
					}
#end
				}
			}
		});

		return ret.toString();
	}

	public function toString()
	{
		return name + ' Encoding';
	}
}

abstract EncodingReturn(Int)
{
	public static inline var MAX_VALUE = 0xFFFF;

	public var written(get,never):Int;
	public var read(get,never):Int;

	@:extern inline public function new(read,written,?pos:haxe.PosInfos)
	{
#if assertations
		if (written > MAX_VALUE || read > MAX_VALUE)
		{
			haxe.Log.trace('throwing error. read: $read, written: $written',pos);
			throw 'assert: $written/$read';
		}
		// haxe.Log.trace('read: $read, written: $written',pos);
#end
		this = ((written & 0xFFFF) << 16) | (read & 0xFFFF);
	}

	@:extern inline private function get_written():Int
	{
		return (this >>> 16);
	}

	@:extern inline private function get_read():Int
	{
		return this & 0xFFFF;
	}

	@:extern inline public function isEmpty()
	{
		return this == 0;
	}
}
