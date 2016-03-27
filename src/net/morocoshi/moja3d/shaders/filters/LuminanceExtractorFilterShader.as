package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.renderer.MaskColor;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
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
		private var _mask:int;
		
		public function LuminanceExtractorFilterShader(min:Number, max:Number, mask:int = -1) 
		{
			super();
			
			_min = min;
			_max = max;
			_mask = mask;
			
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
			alphaTransform = AlphaTransform.UNCHANGE;
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
			
			fragmentCode.addCode([
				"var $color",
				"$color.x = $output.x",
				"$color.x += $output.y",
				"$color.x += $output.z",
				"$color.x /= @extValues.x",
				"$color.x -= @extValues.y",
				"$color.x /= @extValues.z",
				"$color.x = sat($color.x)"
			]);
			if (_mask != -1)
			{
				var xyz:String;
				switch(_mask)
				{
					case MaskColor.RED	: xyz = "x"; break;
					case MaskColor.GREEN: xyz = "y"; break;
					case MaskColor.BLUE	: xyz = "z"; break;
					default: throw new Error("maskの値が有効ではありません。MaskColor.RED/BLUE/GREENのどれかを指定してください。");
				}
				var tag:String = AGALTexture.getTextureOption2D(Smoothing.LINEAR, Mipmap.NOMIP, Tiling.CLAMP);
				fragmentCode.addCode([
					"var $maskImage",
					"$maskImage = tex(#uv.xy, fs1, " + tag + ")",
					"$color.x *= $maskImage." + xyz
				]);
			}
			
			fragmentCode.addCode([
				"$output.xyz *= $color.xxx"
			]);
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