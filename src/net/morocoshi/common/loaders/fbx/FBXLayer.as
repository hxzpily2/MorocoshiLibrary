package net.morocoshi.common.loaders.fbx 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXLayer 
	{
		public var id:Number = -1;
		public var name:String = "";
		public var visible:Boolean = true;
		public var freeze:Boolean = false;
		
		public function FBXLayer(node:FBXNode = null) 
		{
			if (node) parse(node);
		}
		
		public function parse(node:FBXNode):void
		{
			id = node.$args[0];
			name = node.$args[1].split("::")[1];
			var param:Object = FBXParser.parseProperties(node.Properties70);
			visible = param.Show;
			freeze = param.Freeze;
		}
		
	}

}