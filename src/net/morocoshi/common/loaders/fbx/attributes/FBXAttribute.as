package net.morocoshi.common.loaders.fbx.attributes 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXAttribute 
	{
		public var id:Number;
		public var param:Object = { };
		
		public function FBXAttribute(node:FBXNode = null) 
		{
			if (node) parse(node);
		}
		
		public function parse(node:FBXNode):void 
		{
			id = node.$args[0];
			param = FBXParser.parseProperties(node.Properties70);
		}
		
	}

}