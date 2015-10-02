package net.morocoshi.common.loaders.fbx.materials 
{
	import net.morocoshi.common.loaders.fbx.FBXElement;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXTexture extends FBXElement
	{
		public var fullPath:String;
		
		public function FBXTexture(node:FBXNode) 
		{
			super(node);
		}
		
		override public function parse(node:FBXNode):void 
		{
			super.parse(node);
			
			name = (node.TextureName? node.TextureName[0][0] : node.$args[1]).split("::")[1];
			fullPath = node.FileName? node.FileName[0][0] : "";

		}
		
	}

}