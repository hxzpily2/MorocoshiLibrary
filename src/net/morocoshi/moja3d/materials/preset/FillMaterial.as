package net.morocoshi.moja3d.materials.preset 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.shaders.render.FillShader;
	import net.morocoshi.moja3d.shaders.render.LambertShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FillMaterial extends Material 
	{
		
		public function FillMaterial(rgb:uint, alpha:Number, lambert:Boolean) 
		{
			super();
			shaderList.addShader(new FillShader(rgb, alpha));
			if (lambert)
			{
				shaderList.addShader(new LambertShader());
			}
		}
		
	}

}