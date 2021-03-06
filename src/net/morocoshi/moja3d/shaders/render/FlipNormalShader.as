package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 法線を反転
	 * 
	 * @author tencho
	 */
	public class FlipNormalShader extends MaterialShader 
	{
		
		public function FlipNormalShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "FlipNormalShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			vertexCode.addCode(["$normal.xyz = neg($normal.xyz)"]);
		}
		
		override public function clone():MaterialShader 
		{
			return new FlipNormalShader();
		}
		
	}

}