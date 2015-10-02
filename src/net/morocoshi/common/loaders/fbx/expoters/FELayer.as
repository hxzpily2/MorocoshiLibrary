package net.morocoshi.common.loaders.fbx.expoters 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用のレイヤーデータ
	 * 
	 * @author tencho
	 */
	public class FELayer 
	{
		public var id:Number;
		public var name:String = "";
		public var color:Array = [0.5, 0.5, 0.5];
		public var freeze:Boolean = false;
		public var show:Boolean = true;
		
		public function FELayer() 
		{
		}
		
		public function toFBXNode():FBXNode
		{
			var node:FBXNode = new FBXNode(null, [id, "DisplayLayer::" + name, "DisplayLayer"]);
			var p70:Array = [
				["Color", "ColorRGB", "Color", "", color[0], color[1], color[2]],
				["Show", "bool", "", "", int(show)],
				["Freeze", "bool", "", "", int(freeze)],
				["LODBox", "bool", "", "", 0]
			];
			FBXParser.addPropertyNode(node, p70);
			return node;
		}
		
	}

}