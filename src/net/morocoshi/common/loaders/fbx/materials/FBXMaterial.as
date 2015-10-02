package net.morocoshi.common.loaders.fbx.materials 
{
	import flash.display.BlendMode;
	import net.morocoshi.common.loaders.fbx.FBXElement;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXMaterial extends FBXElement
	{
		public var shading:String = "phong";
		public var ambientColor:uint = 0x000000;
		public var diffuseColor:uint = 0x000000;
		public var alpha:Number = 1;
		public var specularFactor:Number = 0;
		public var reflectionFactor:Number = 1;
		public var diffuseMap:FBXTexture;
		public var transparentMap:FBXTexture;
		public var reflectionMap:FBXTexture;
		public var normalMap:FBXTexture;
		public var doubleSided:Boolean = false;
		public var repeat:Boolean = true;
		public var blendMode:String = BlendMode.NORMAL;
		
		public function FBXMaterial(node:FBXNode = null) 
		{
			super(node);
		}
		
		override public function parse(node:FBXNode):void
		{
			super.parse(node);
			if (param.hasOwnProperty("ShadingModel")) shading = param.ShadingModel;
			if (param.hasOwnProperty("AmbientColor")) ambientColor = param.AmbientColor;
			if (param.hasOwnProperty("DiffuseColor")) diffuseColor = param.DiffuseColor;
			if (param.hasOwnProperty("Opacity")) alpha = param.Opacity;
			if (param.hasOwnProperty("SpecularFactor")) specularFactor = param.SpecularFactor;
			if (param.hasOwnProperty("ReflectionFactor")) reflectionFactor = param.ReflectionFactor;
			if (param.hasOwnProperty("DoubleSided")) doubleSided = Boolean(param.DoubleSided);
			if (param.hasOwnProperty("BlendMode")) blendMode = String(param.BlendMode) || BlendMode.NORMAL;
			if (param.hasOwnProperty("Repeat")) repeat = Boolean(param.Repeat);
		}
		
		public function clone():FBXMaterial
		{
			var fm:FBXMaterial = new FBXMaterial();
			fm.id = id;
			fm.name = name;
			fm.param = param;
			fm.shading = shading;
			fm.ambientColor = ambientColor;
			fm.diffuseColor = diffuseColor;
			fm.alpha = alpha;
			fm.reflectionFactor = reflectionFactor;
			fm.specularFactor = specularFactor;
			fm.diffuseMap = diffuseMap;
			fm.transparentMap = transparentMap;
			fm.normalMap = normalMap;
			fm.doubleSided = doubleSided;
			fm.repeat = repeat;
			return fm;
		}
		
		public function setDiffuseColor(color:uint):void
		{
			diffuseColor = color;
		}
		
		public function setTexture(texture:FBXTexture, type:String):void
		{
			//%%%テクスチャとマテリアルを関連付けるキーのmentalrayのものを調査したい
			switch(type)
			{
				case "3dsMax|Parameters|diff_color_map": diffuseMap = texture; break;
				case "3dsMax|parameters|mapM0": diffuseMap = texture; break;
				case "3dsMax|parameters|map1": diffuseMap = texture; break;
				case "3dsMax|parameters|map2": diffuseMap = texture; break;
				case "DiffuseColor": diffuseMap = texture; break;
				case "ReflectionColor": reflectionMap = texture; break;
				case "TransparentColor": transparentMap = texture; break;
				case "NormalMap": normalMap = texture; break;
			}
		}
		
		/**
		 * マテリアルがなかった時の為にメッシュカラーでマテリアル設定する
		 * @param	color
		 */
		public function setFillMaterial(color:uint):void 
		{
			specularFactor = 0;
			alpha = 1;
			diffuseColor = color;
		}
		
	}

}