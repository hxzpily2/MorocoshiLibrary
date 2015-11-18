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
		
		static public function deleteArray(data:Array):void
		{
			if (data == null) return;
			
			var n:int = data.length;
			for (var i:int = 0; i < n; i++) 
			{
				delete data[i];
			}
			trace(data);
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