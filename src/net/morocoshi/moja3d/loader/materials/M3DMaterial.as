package net.morocoshi.moja3d.loader.materials 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.shaders.render.AlphaShader;
	import net.morocoshi.moja3d.shaders.render.FillShader;
	import net.morocoshi.moja3d.shaders.render.OpacityShader;
	import net.morocoshi.moja3d.shaders.render.TextureShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DMaterial 
	{
		public var name:String = "";
		public var id:int = 0;
		public var diffusePath:String = "";
		public var opacityPath:String = "";
		public var normalPath:String = "";
		public var reflectionPath:String = "";
		
		public var reflectionFactor:Number = 0;
		public var diffuseColor:uint = 0x000000;
		public var alpha:Number = 1;
		public var doubleSided:Boolean = false;
		public var blendMode:String = BlendMode.NORMAL;
		public var tiling:String = Tiling.WRAP;
		public var smoothing:Boolean = true;
		public var mipmap:String = Mipmap.MIPLINEAR;
		
		public function M3DMaterial() 
		{
		}
		
		/**
		 * ___各種画像パスのディレクトリは削ってキーにする？
		 * @return
		 */
		public function getKey():String
		{
			return [
				diffusePath, normalPath, opacityPath, reflectionPath, reflectionFactor,
				diffuseColor, alpha, doubleSided, blendMode, tiling, smoothing, mipmap
			].join("|");
		}
		
		public function addDiffuseShaderTo(shaderList:ShaderList):void 
		{
			var opacity:ExternalTextureResource = opacityPath? new ExternalTextureResource(opacityPath) : null;
			var smooth:String = smoothing? Smoothing.LINEAR : Smoothing.NEAREST;
			if (diffusePath)
			{
				var diffuse:ExternalTextureResource = new ExternalTextureResource(diffusePath);
				shaderList.addShader(new TextureShader(diffuse, opacity, mipmap, smooth, tiling));
				if (alpha < 1)
				{
					shaderList.addShader(new AlphaShader(alpha));
				}
				return;
			}
			
			shaderList.addShader(new FillShader(diffuseColor, alpha));
			if (opacity)
			{
				shaderList.addShader(new OpacityShader(opacity, mipmap, smooth, tiling));
			}
		}
	}

}