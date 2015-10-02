package net.morocoshi.moja3d.materials.preset 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.render.AlphaShader;
	import net.morocoshi.moja3d.shaders.render.LambertShader;
	import net.morocoshi.moja3d.shaders.render.TextureShader;
	
	/**
	 * シンプルなテクスチャマテリアル
	 * 
	 * @author tencho
	 */
	public class TextureMaterial extends Material 
	{
		public var textureShader:TextureShader;
		public var lambertShader:LambertShader;
		
		public function TextureMaterial(diffuse:TextureResource, opacity:TextureResource, alpha:Number = 1, lambert:Boolean = true) 
		{
			super();
			
			textureShader = new TextureShader(diffuse, opacity);
			shaderList.addShader(textureShader);
			if (lambert)
			{
				lambertShader = new LambertShader();
				shaderList.addShader(lambertShader);
				
			}
			if (alpha < 1)
			{
				shaderList.addShader(new AlphaShader(alpha));
			}
		}
		
	}

}