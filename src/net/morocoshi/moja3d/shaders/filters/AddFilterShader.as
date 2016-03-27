package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.agal.AGALCode;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class AddFilterShader extends MaterialShader 
	{
		private var _alpha:Number;
		private var alphaConst:AGALConstant;
		
		public function AddFilterShader(alpha:Number) 
		{
			super();
			
			_alpha = alpha;
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "AddFilterShader:";
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
			alphaConst = fragmentCode.addConstantsFromArray("@alpha", [_alpha, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = AGALTexture.getTextureOption2D(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP);
			
			fragmentCode.addCode([
				"var $image1",
				"var $image2",
				"$image1 = tex(#uv.xy, fs0, " + tag + ")",
				"$image2 = tex(#uv.xy, fs1, " + tag + ")",
				"$image2.xyz *= @alpha.xxx",
				"$output.xyz = $image1.xyz + $image2.xyz"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:AddFilterShader = new AddFilterShader(_alpha);
			return shader;
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			alphaConst.x = _alpha = value;
		}
		
	}

}