package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 光を投影する
	 * TODO: つくりかけ
	 * 
	 * @author tencho
	 */
	public class LightShader extends MaterialShader 
	{
		
		public function LightShader() 
		{
			super();
			
			hasLightElement = true;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "LightShader:";
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
		}
		
		override public function clone():MaterialShader 
		{
			return new LightShader();
		}
		
	}

}