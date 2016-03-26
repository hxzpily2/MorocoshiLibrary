package net.morocoshi.moja3d.shaders.outline 
{
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 最後に追加するシェーダー
	 * 
	 * @author tencho
	 */
	public class OutlineEndShader extends MaterialShader 
	{
		public function OutlineEndShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "OutlineEndShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.UNKNOWN;
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
			
			fragmentCode.addCode([
				"oc = $output"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new OutlineEndShader();
		}
		
	}

}