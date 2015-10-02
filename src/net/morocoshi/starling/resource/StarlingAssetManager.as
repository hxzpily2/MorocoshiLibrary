package net.morocoshi.starling.resource
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import net.morocoshi.common.resource.EmbededAssetManager;
	import starling.textures.Texture;
	
	/**
	 * Startling用の埋め込みアセットを管理
	 * 
	 * @author tencho
	 */
	public class StarlingAssetManager extends EmbededAssetManager
	{
		
		public function StarlingAssetManager()
		{
			super();
		}
		
		public function getTexture(cls:Class, scale:Number = 1, mipmap:Boolean = true, async:Function = null, repeat:Boolean = false):Texture
		{
			var resource:* = getResource(cls);
			if(resource is ByteArray)
			{
				return Texture.fromAtfData(resource, scale, mipmap, async, repeat);
			}
			if(resource is BitmapData)
			{
				return Texture.fromBitmapData(resource, mipmap, false, scale, "bgra", repeat);
			}
			return null;
		}
		
	}
}