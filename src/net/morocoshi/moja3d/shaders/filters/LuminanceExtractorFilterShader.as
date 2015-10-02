package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 輝度抽出
	 * 
	 * @author tencho
	 */
	public class LuminanceExtractorFilterShader extends MaterialShader 
	{
		private var _min:Number;
		private var _max:Number;
		
		public function LuminanceExtractorFilterShader(min:Number, max:Number) 
		{
			_min = min;
			_max = max;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "LuminanceExtractorFilterShader:";
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
			fragmentCode.addConstantsFromArray("@extValues", [3, _min, (_max - _min), 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentCode.addCode(
				"var $color",
				"$color.x = $output.x",
				"$color.x += $output.y",
				"$color.x += $output.z",
				"$color.x /= @extValues.x",
				"$color.x -= @extValues.y",
				"$color.x /= @extValues.z",
				"$color.x = sat($color.x)",
				"$output.xyz *= $color.x"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:LuminanceExtractorFilterShader = new LuminanceExtractorFilterShader(min, max);
			return shader;
		}
		
		public function get min():Number 
		{
			return _min;
		}
		
		public function set min(value:Number):void 
		{
			_min = value;
			updateConstants();
		}
		
		public function get max():Number 
		{
			return _max;
		}
		
		public function set max(value:Number):void 
		{
			_max = value;
			updateConstants();
		}
		
	}

}