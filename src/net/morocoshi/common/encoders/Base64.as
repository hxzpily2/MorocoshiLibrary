package net.morocoshi.common.encoders
{
	import flash.utils.ByteArray;
	
	/**
	 * 元のソースはmx.utils.Base64Encoder
	 * ※機能はencodeのみ
	 */
	public class Base64
	{
		//static private const CHARSET_UTF_8:String = "UTF-8";
		static private const MAX_BUFFER_SIZE:uint = 32767;
		static private const ESCAPE_CHAR_CODE:Number = 61;
		static private const ALPHABET_CHAR_CODES:Array = [65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47];
		static private var newLine:int = 10;
		static private var insertNewLines:Boolean = true;
		static private var buffers:Array = [[]];
		static private var count:uint = 0;
		static private var line:uint = 0;
		static private var work:Array = [0, 0, 0];
		
		public function Base64()
		{
		}
		
		static public function encode(data:String):String
		{
			var currentIndex:uint = 0;
			var endIndex:uint = data.length;
			
			while (currentIndex < endIndex)
			{
				work[count] = data.charCodeAt(currentIndex);
				count++;
				if ((count == work.length) || ((endIndex - currentIndex) == 1))
				{
					encodeBlock();
					count = 0;
					work[0] = 0;
					work[1] = 0;
					work[2] = 0;
				}
				currentIndex++;
			}
			return flush();
		}
		
		static public function encodeUTFBytes(data:String):String
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(data);
			bytes.position = 0;
			return encodeBytes(bytes);
		}
		
		static public function encodeBytes(data:ByteArray):String
		{
			var n:int = data.length;
			var oldPosition:uint = data.position;
			data.position = 0;
			var currentIndex:uint = 0;
			var endIndex:uint = n;
			if (endIndex > data.length)
			{
				endIndex = data.length;
			}
			while (currentIndex < endIndex)
			{
				work[count] = data[currentIndex];
				count++;
				if ((count == work.length) || ((endIndex - currentIndex) == 1))
				{
					encodeBlock();
					count = 0;
					work[0] = 0;
					work[1] = 0;
					work[2] = 0;
				}
				currentIndex++;
			}
			data.position = oldPosition;
			return flush();
		}
		
		static private function flush():String
		{
			if (count > 0)
			{
				encodeBlock();
			}
			var result:String = drain();
			reset();
			return result;
		}
		
		static private function drain():String
		{
			var buffer:Array;
			var result:String = "";
			var i:uint;
			while (i < buffers.length)
			{
				buffer = (buffers[i] as Array);
				result = (result + String.fromCharCode.apply(null, buffer));
				i++;
			}
			buffers = [];
			buffers.push([]);
			return result;
		}
		
		static private function reset():void
		{
			buffers = [[]];
			count = 0;
			line = 0;
			work[0] = 0;
			work[1] = 0;
			work[2] = 0;
		}
		
		static private function encodeBlock():void
		{
			var currentBuffer:Array = buffers[buffers.length - 1] as Array;
			if (currentBuffer.length >= MAX_BUFFER_SIZE)
			{
				currentBuffer = [];
				buffers.push(currentBuffer);
			}
			currentBuffer.push(ALPHABET_CHAR_CODES[(work[0] & 0xFF) >> 2]);
			currentBuffer.push(ALPHABET_CHAR_CODES[((work[0] & 3) << 4) | ((work[1] & 240) >> 4)]);
			if (count > 1)
			{
				currentBuffer.push(ALPHABET_CHAR_CODES[((work[1] & 15) << 2) | ((work[2] & 192) >> 6)]);
			}
			else
			{
				currentBuffer.push(ESCAPE_CHAR_CODE);
			}
			if (count > 2)
			{
				currentBuffer.push(ALPHABET_CHAR_CODES[work[2] & 63]);
			}
			else
			{
				currentBuffer.push(ESCAPE_CHAR_CODE);
			}
			if (insertNewLines)
			{
				line += 4;
				if (line == 76)
				{
					currentBuffer.push(newLine);
					line = 0;
				}
			}
		}

	}
}