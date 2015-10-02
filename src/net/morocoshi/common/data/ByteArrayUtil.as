package net.morocoshi.common.data 
{
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import net.morocoshi.common.loaders.ClassAliasUtil;
	import net.morocoshi.moja3d.loader.M3DInfo;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ByteArrayUtil 
	{
		
		public function ByteArrayUtil() 
		{
		}
		
		static public function clone(ba:ByteArray):ByteArray
		{
			var data:ByteArray = new ByteArray();
			data.writeBytes(ba, 0, ba.bytesAvailable);
			return data;
		}
		
		/**
		 * オブジェクトをAMFオブジェクト化する
		 * @param	object
		 * @return
		 */
		static public function toAMF(object:*):ByteArray 
		{
			var data:ByteArray = new ByteArray();
			data.writeObject(object);
			return data;
		}
		
	}

}