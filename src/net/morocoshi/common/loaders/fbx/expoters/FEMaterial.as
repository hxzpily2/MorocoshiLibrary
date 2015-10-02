package net.morocoshi.common.loaders.fbx.expoters 
{
	import flash.display.BlendMode;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用のマテリアルデータ
	 * 
	 * @author tencho
	 */
	public class FEMaterial 
	{
		/**[自動設定]FBXの関連付けID番号*/
		public var id:Number;
		/**[自動設定]FBX文字列化時になんか使う*/
		public var index:Number = -1;
		
		public var name:String;
		public var diffuseColor:Array = [0, 0, 0];
		public var ambientColor:Array = [0, 0, 0];
		public var glowColor:Array = [0, 0, 0];
		/**多分使わない*/
		public var specularColor:Array = [0.9, 0.9, 0.9];
		/**不透明度*/
		public var alpha:Number = 1;
		/**今のとこdiffuseしかない。setDiffuseTexture()で設定する*/
		public var texture:Object = { };
		public var doubleSided:Boolean = false;
		public var userData:Object = { };
		public var blendMode:String = BlendMode.NORMAL;
		//public var overlayTexturePath:String = "";
		
		public function FEMaterial() 
		{
		}
		
		public function toFBXNode():FBXNode
		{
			var node:FBXNode = new FBXNode(null, [id, "Material::" + name, ""]);
			node.addValue("Version", [102]);
			node.addValue("ShadingModel", ["phong"]);
			node.addValue("MultiLayer", [0]);
			var p70:Array = [
				["ShadingModel", "KString", "", "", "phong"],
				["EmissiveFactor", "double", "Number", "", 0],
				["AmbientColor", "ColorRGB", "Color", ""].concat(ambientColor),
				["DiffuseColor", "ColorRGB", "Color", ""].concat(diffuseColor),
				["TransparentColor", "ColorRGB", "Color", "", 1, 1, 1],
				["TransparencyFactor", "double", "Number", "", 1 - alpha],
				["SpecularColor", "ColorRGB", "Color", ""].concat(specularColor),
				["SpecularFactor", "double", "Number", "", 0],
				["ShininessExponent", "double", "Number", "", 2],
				["DoubleSided", "Bool", "", "A+U", int(doubleSided)],
				["BlendMode", "KString", "", "A+U", blendMode],
				//["OverlayTexture", "KString", "", "A+U", overlayTexturePath],
				//["有効", "Bool", "", "A+U", 0],
				["Emissive", "Vector3D", "Vector", "", 1, 0, 0],
				["Ambient", "Vector3D", "Vector", ""].concat(ambientColor),
				["Diffuse", "Vector3D", "Vector", ""].concat(diffuseColor),
				["Specular", "Vector3D", "Vector", "", 0, 0, 0],
				["Shininess", "double", "Number", "", 2],
				["Opacity", "double", "Number", "", alpha],
				["Reflectivity", "double", "Number", "", 0]
			];
			FBXParser.addPropertyNode(node, p70);
			return node;
		}
		
		public function setDiffuseTexture(image:FEImage):void 
		{
			texture.DiffuseColor = image;
		}
		
	}

}