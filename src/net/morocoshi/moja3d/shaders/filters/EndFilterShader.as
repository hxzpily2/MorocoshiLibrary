package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class EndFilterShader extends MaterialShader 
	{
		
		public function EndFilterShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "EndFilterShader:";
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
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentCode.addCode(["oc = $output"]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:EndFilterShader = new EndFilterShader();
			return shader;
		}
		
	}

}