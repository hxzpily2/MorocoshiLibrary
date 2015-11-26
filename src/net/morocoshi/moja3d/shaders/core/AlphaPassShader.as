package net.morocoshi.moja3d.shaders.core 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 半透明ピクセルのみ描画する
	 * 
	 * @author tencho
	 */
	public class AlphaPassShader extends MaterialShader 
	{
		
		private var _threshold:Number;
		public var thresholdConst:AGALConstant;
		
		public function AlphaPassShader(threshold:Number) 
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
			return "AlphaPassShader:";
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
			thresholdConst = fragmentCode.addConstantsFromArray("@threshold", [_threshold, 0.00001, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentConstants.number = true;
			fragmentCode.addCode([
				"var $temp",
				//透過がほぼ0のテクセルを消す
				"$temp.x = $output.w - @threshold.y",
				"kil $temp.x",
				//透過がthreshold以上のテクセルを消す
				"$temp.x = @threshold.x - $output.w",
				"kil $temp.x"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new AlphaPassShader(_threshold);
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