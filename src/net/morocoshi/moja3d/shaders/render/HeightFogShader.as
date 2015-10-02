package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	/**
	 * 高度フォグ
	 * 
	 * @author tencho
	 */
	public class HeightFogShader extends MaterialShader 
	{
		private var _bottom:Number;
		private var _top:Number;
		private var _topDensity:Number;
		private var _bottomDensity:Number;
		private var _color:uint;
		
		private var distanceConst:AGALConstant;
		private var colorConst:AGALConstant;
		
		public function HeightFogShader(top:Number, bottom:Number, topDensity:Number, bottomDensity:Number, color:uint) 
		{
			super();
			
			_top = top;
			_bottom = bottom;
			_topDensity = topDensity;
			_bottomDensity = bottomDensity;
			_color = color;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "HeightFogShader:";
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
			
			distanceConst = fragmentCode.addConstantsFromArray("@hFogDist", [0, 0, 0, 1]);
			colorConst = fragmentCode.addConstantsFromColor("@hFogColor", _color, 0);
			calcConst();
		}
		
		private function calcConst():void 
		{
			distanceConst.x = _top;
			distanceConst.y = _bottom;
			distanceConst.z = _top - _bottom;
			distanceConst.w = _topDensity - _bottomDensity;
			colorConst.w = _bottomDensity;
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			
			fragmentCode.addCode(
				"var $fogRatio",
				"var $blendColor",
				
				"$fogRatio.x = #wpos.z - @hFogDist.y",
				"$fogRatio.x /= @hFogDist.z",
				"$fogRatio.x = sat($fogRatio.x)",
				"$fogRatio.x *= @hFogDist.w",
				"$fogRatio.x += @hFogColor.w",
				"$fogRatio.x = sat($fogRatio.x)",
				
				//"$fogRatio.x *= $fogRatio.x",
				
				"$blendColor.xyz = @hFogColor.xyz * $fogRatio.x",
				"$blendColor.w = @1 - $fogRatio.x",//@hFogDist.w - 
				"$output.xyz *= $blendColor.www",
				"$output.xyz += $blendColor.xyz"
			);
		}
		
		public function get bottom():Number 
		{
			return _bottom;
		}
		
		public function set bottom(value:Number):void 
		{
			_bottom = value;
			calcConst();
		}
		
		public function get top():Number 
		{
			return _top;
		}
		
		public function set top(value:Number):void 
		{
			_top = value;
			calcConst();
		}
		
		public function get topDensity():Number 
		{
			return _topDensity;
		}
		
		public function set topDensity(value:Number):void 
		{
			_topDensity = value;
			calcConst();
		}
		
		public function get bottomDensity():Number 
		{
			return _bottomDensity;
		}
		
		public function set bottomDensity(value:Number):void 
		{
			_bottomDensity = value;
			calcConst();
		}
		
		override public function clone():MaterialShader 
		{
			var shader:HeightFogShader = new HeightFogShader(_top, _bottom, _topDensity, _bottomDensity, _color);
			return shader;
		}
		
	}

}