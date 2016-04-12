package net.morocoshi.common.data 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author tencho
	 */
	public class DataUtil 
	{
		
		public function DataUtil() 
		{
			
		}
		
		/**
		 * digitの桁に合うように数値の前に0をつける
		 * @param	num
		 * @param	digit
		 */
		static public function hex(num:int, digit:int):String
		{
			var result:String = String(num);
			var n:int = digit - result.length;
			for (var i:int = 0; i < n; i++) 
			{
				result = "0" + result;
			}
			return result;
		}
		
		static public function deleteArray(data:Array):void
		{
			if (data == null) return;
			
			var n:int = data.length;
			for (var i:int = 0; i < n; i++) 
			{
				delete data[i];
			}
		}
		
		static public function deleteObject(data:Object):void
		{
			if (data == null) return;
			
			for (var key:String in data)
			{
				delete data[key];
			}
		}
		
		static public function deleteVector(data:*):void 
		{
			if (data == null) return;
			
			var n:int = data.length;
			for (var i:int = 0; i < n; i++) 
			{
				data[i] = null;
			}
		}
		
	}

}