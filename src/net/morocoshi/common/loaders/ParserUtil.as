package net.morocoshi.common.loaders 
{
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParserUtil 
	{
		
		static private var bytes:ByteArray;
		
		public function ParserUtil() 
		{
		}
		
		static public function clone(data:*):*
		{
			if (!bytes) bytes = new ByteArray();
			bytes.writeObject(data);
			bytes.position = 0;
			var result:* = bytes.readObject();
			bytes.clear();
			return result;
		}
		
	}

}