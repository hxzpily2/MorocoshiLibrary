package net.morocoshi.moja3d.resources 
{
	import flash.utils.Dictionary;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TextureAtlasResource extends TextureResource 
	{
		
		public var items:Vector.<TextureAtlasItem>;
		public var numFrames:int;
		
		public function TextureAtlasResource() 
		{
			numFrames = 0;
			items = new Vector.<TextureAtlasItem>;
			
			super();
		}
		
		override public function upload(context3D:ContextProxy, async:Boolean = false, complete:Function = null):Boolean 
		{
			var cache:Dictionary = new Dictionary();
			for each(var item:TextureAtlasItem in items)
			{
				if (item.resource && !cache[item.resource])
				{
					cache[item.resource] = true;
					item.resource.upload(context3D, async, complete);
				}
			}
			cache = null;
			
			return false;
		}
		
		public function getTextureResourceAt(frame:int):TextureResource 
		{
			if (numFrames == 0) return null;
			return items[frame % numFrames].resource;
		}
		
		public function getSamplingOptionAt(frame:int):String 
		{
			if (numFrames == 0) return "";
			return items[frame % numFrames].resource.getSamplingOption();
		}
		
	}

}