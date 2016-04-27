package net.morocoshi.moja3d.atlas 
{
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.resources.TextureAtlasResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TextureAtlasData 
	{
		public var items:Vector.<TextureAtlasItem>;
		public var group:Object;
		
		public function TextureAtlasData(resource:TextureResource, xml:XML)
		{
			//group = { };
			items = new Vector.<TextureAtlasItem>;
			for each(var node:XML in xml.SubTexture)
			{
				var item:TextureAtlasItem = new TextureAtlasItem();
				item.name = XMLUtil.getAttrString(node, "name", "");
				item.x = XMLUtil.getAttrNumber(node, "x", 0);
				item.y = XMLUtil.getAttrNumber(node, "y", 0);
				item.width = XMLUtil.getAttrNumber(node, "width", 1);
				item.height = XMLUtil.getAttrNumber(node, "height", 1);
				item.rotate = XMLUtil.getAttrBoolean(node, "rotate", false);
				item.resource = resource;
				items.push(item);
			}
		}
		
		public function getTextures(prefix:String):TextureAtlasResource
		{
			var result:TextureAtlasResource = new TextureAtlasResource();
			for each(var item:TextureAtlasItem in items)
			{
				if (item.name.indexOf(prefix) == 0)
				{
					result.items.push(item);
				}
			}
			result.numFrames = result.items.length;
			return result;
		}
		
		public function getTexture(name:String):TextureAtlasResource
		{
			var result:TextureAtlasResource = new TextureAtlasResource();
			for each(var item:TextureAtlasItem in items)
			{
				if (item.name == name)
				{
					result.items.push(item);
					break;
				}
			}
			result.numFrames = result.items.length;
			return result;
		}
		
	}

}