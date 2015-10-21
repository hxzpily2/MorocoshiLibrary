package net.morocoshi.moja3d.shaders.shadow {
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class ShadowMaskShader extends MaterialShader 
	{
		
		public function ShadowMaskShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "ShadowMaskShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.MIX;
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
			
			fragmentConstants.number = true;
			fragmentCode.addCode(
				"var $temp",
				"$temp.x = @1 - $common.x",
				"$output.a *= $temp.x"
			)
		}
		
		override public function clone():MaterialShader 
		{
			return new ShadowMaskShader();
		}
		
	}

}