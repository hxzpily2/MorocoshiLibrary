package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class BasicFilterShader extends MaterialShader 
	{
		moja3d var clippingConst:AGALConstant;
		
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
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			vertexCode.addConstantsFromArray("@offsetFilter", [2, -2, -1, 1]);
			clippingConst = vertexCode.addConstantsFromArray("@clippingFilter", [0, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.number = true;
			vertexConstants.viewSize = true;
			vertexCode.addCode([
				"var $pos",
				"$pos = va0",
				"$pos.xy *= @clippingFilter.zw",
				"$pos.xy += @clippingFilter.xy",
				
				"$pos.xy /= @viewSize.xy",
				"$pos.xy *= @offsetFilter.xy",
				"$pos.xy += @offsetFilter.zw",
				
				"op = $pos",
				"#uv = va1"
			]);
			
			fragmentConstants.number = true;
			var tag:String = AGALTexture.getTextureOption2D(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP);
			fragmentCode.addCode([
				"global $output",
				"$output = tex(#uv.xy, fs0, " + tag + ")",
				"$output.w = @1"
			]);
		}
		
	}

}