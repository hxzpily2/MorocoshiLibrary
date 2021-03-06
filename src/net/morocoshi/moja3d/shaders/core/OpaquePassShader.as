package net.morocoshi.moja3d.shaders.core 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 不透明ピクセルのみ描画する
	 * 
	 * @author tencho
	 */
	public class OpaquePassShader extends MaterialShader 
	{
		private var _threshold:Number;
		public var thresholdConst:AGALConstant;
		
		public function OpaquePassShader(threshold:Number) 
		{
			super();
			
			_threshold = threshold;
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "OpaquePassShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.SET_OPAQUE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			thresholdConst = fragmentCode.addConstantsFromArray("@threshold", [_threshold, 1, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentCode.addCode([
				"var $temp",
				"$temp.x = $output.w - @threshold.x",
				"kil $temp.x",
				"$output.w = @threshold.y"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new OpaquePassShader(_threshold);
		}
		
		public function get threshold():Number 
		{
			return _threshold;
		}
		
		public function set threshold(value:Number):void 
		{
			thresholdConst.x = _threshold = value;
		}
		
	}

}