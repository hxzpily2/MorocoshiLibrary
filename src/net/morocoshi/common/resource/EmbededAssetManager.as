package net.morocoshi.common.resource
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	
	/**
	 * 埋め込みアセットの管理
	 * 
	 * @author	tencho
	 */
	public class EmbededAssetManager
	{
		//[Embed(source = "xxxx.atf", mimeType = "application/octet-stream")] public var xxxx:Class;
		//[Embed(source = "xxxx.png")] public var xxxx:Class;
		
		private var byteArrayCache:Object;
		
		public function EmbededAssetManager()
		{
			clearCache();
		}
		
		public function clearCache():void
		{
			byteArrayCache = {};
		}
		
		public function getResource(cls:Class):*
		{
			var key:String = String(cls);
			var result:* = byteArrayCache[key];
			if(result == null)
			{
				var data:* = new cls();
				if (data is Bitmap)
				{
					result = byteArrayCache[key] = Bitmap(new cls()).bitmapData;
				}
				else if (data is ByteArray)
				{
					result = byteArrayCache[key] = data as ByteArray;
				}
			}
			return result;
		}
		
	}
}