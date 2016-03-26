package net.morocoshi.moja3d.shaders.shadow
{
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * デプスシャドウの影の場所を透明度に反映させるシェーダー
	 * 
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
			fragmentCode.addCode([
				"var $temp",
				"$temp.x = @1 - $common.x",
				"$output.w *= $temp.x"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new ShadowMaskShader();
		}
		
	}

}