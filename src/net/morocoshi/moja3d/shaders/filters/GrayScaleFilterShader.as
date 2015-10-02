package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class GrayScaleFilterShader extends MaterialShader 
	{
		
		public function GrayScaleFilterShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "GrayScaleFilterShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			fragmentCode.addConstantsFromArray("@grayscale", [3, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentCode.addCode(
				"var $temp",
				"$temp.x = $output.x + $output.y",
				"$temp.x += $output.z",
				"$temp.x /= @grayscale.x",
				"$output.xyz = $temp.xxx"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:GrayScaleFilterShader = new GrayScaleFilterShader();
			return shader;
		}
		
	}

}