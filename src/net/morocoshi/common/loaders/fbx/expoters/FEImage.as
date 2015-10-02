package net.morocoshi.common.loaders.fbx.expoters 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用の画像データ
	 * 
	 * @author tencho
	 */
	public class FEImage 
	{
		
		public var id:Number;
		public var name:String;
		public var path:String;
		
		public function FEImage() 
		{
			
		}
		
		public function changePath():void
		{
			var list:Array = path.split(".");
			list.pop();
			path = list.join(".") + ".png";
		}
		
		public function toFBXNode():FBXNode
		{
			var node:FBXNode = new FBXNode(null, [id, "Texture::" + name, ""]);
			node.addValue("Type", ["TextureVideoClip"]);
			node.addValue("Version", [202]);
			node.addValue("TextureName", ["Texture::" + name]);
			var p70:Array = [
				["UVSet", "KString", "", "", "UVChannel_1"],
				["UseMaterial", "bool", "", "", 1]
			];
			FBXParser.addPropertyNode(node, p70);
			node.addValue("FileName", [path]);
			node.addValue("RelativeFilename", [path]);
			node.addValue("ModelUVTranslation", [0, 0]);
			node.addValue("ModelUVScaling", [1, 1]);
			node.addValue("Texture_Alpha_Source", ["None"]);
			node.addValue("Cropping", [0, 0, 0, 0]);
			return node;
		}
		
	}

}