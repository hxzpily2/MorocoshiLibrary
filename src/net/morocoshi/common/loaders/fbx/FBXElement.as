package net.morocoshi.common.loaders.fbx 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class FBXElement 
	{
		public var id:Number;
		public var name:String;
		public var param:Object;
		
		public function FBXElement(node:FBXNode = null) 
		{
			if (node)
			{
				parse(node);
			}
		}
		
		public function parse(node:FBXNode):void
		{
			if (node == null)
			{
				throw new Error("FBXNodeがnullです。");
			}
			
			id = node.$args[0];
			name = node.$args[1].split("::")[1];
			
			if (node.Properties70)
			{
				param = FBXParser.parseProperties(node.Properties70);
			}
		}
		
	}

}