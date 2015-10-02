package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author ...
	 */
	public class BasicFilterShader extends MaterialShader 
	{
		
		public function BasicFilterShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "BasicFilterShader:";
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
			
			vertexConstants.number = true;
			vertexCode.addCode(
				"op = va0",
				"#uv = va1"
			);
			
			fragmentConstants.number = true;
			var tag:String = getTextureTag(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP, "");
			fragmentCode.addCode(
				"global $output",
				"$output = tex(#uv.xy, fs0, " + tag + ")",
				"$output.w = @1"
			);
		}
		
	}

}