package net.morocoshi.moja3d.materials.preset 
{
	import flash.display3D.Context3DTriangleFace;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.render.FillShader;
	import net.morocoshi.moja3d.shaders.render.FresnelShader;
	import net.morocoshi.moja3d.shaders.render.LambertShader;
	import net.morocoshi.moja3d.shaders.render.ReflectionShader;
	import net.morocoshi.moja3d.shaders.render.SpecularShader;
	import net.morocoshi.moja3d.shaders.render.WaterNormalShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class WaterMaterial extends Material 
	{
		public function WaterMaterial(normalMap:TextureResource) 
		{
			super();
			
			culling = Context3DTriangleFace.NONE;
			var rgb:uint = 0x000C22;
			shaderList.addShader(new FillShader(rgb, 0.5));
			if (normalMap)
			{
				shaderList.addShader(new WaterNormalShader(normalMap, 0.3));
			}
			shaderList.addShader(new FresnelShader(1 / 1.4, 0.2));
			shaderList.addShader(new ReflectionShader(1, true, 50, 3, 0));
			shaderList.addShader(new LambertShader());
			shaderList.addShader(new SpecularShader(150, 2, false));
		}
	}

}