package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 距離フォグ
	 * 
	 * @author tencho
	 */
	public class DistanceFogShader extends MaterialShader 
	{
		private var _color:uint;
		private var _distanceNear:Number;
		private var _distanceFar:Number;
		private var _densityNear:Number;
		private var _densityFar:Number;
		private var _blendMode:String;
		
		private var distanceConst:AGALConstant;
		private var colorConst:AGALConstant;
			
		public function DistanceFogShader(color:uint, distanceNear:Number, distanceFar:Number, densityNear:Number, densityFar:Number, blendMode:String = null) 
		{
			super();
			
			_color = color;
			_distanceNear = distanceNear;
			_distanceFar = distanceFar;
			_densityNear = densityNear;
			_densityFar = densityFar;
			_blendMode = blendMode || BlendMode.NORMAL;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "DistanceFogShader:";
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
			
			distanceConst = fragmentCode.addConstantsFromArray("@dFogData", [0, 0, 0, 0]);
			colorConst = fragmentCode.addConstantsFromArray("@dFogColor", [0, 0, 0, 0]);
			calcFogConst();
		}
		
		private function calcFogConst():void 
		{
			distanceConst.x = _distanceNear;
			distanceConst.y = _distanceFar - _distanceNear;
			distanceConst.z = _densityFar - _densityNear;
			distanceConst.w = _densityFar;
			colorConst.setRGBA(_color, _densityNear);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.number = true;
			
			fragmentCode.addCode(
				"var $temp",
				
				"$temp.x = #spos.w - @dFogData.x",
				"$temp.x /= @dFogData.y",
				"$temp.x = sat($temp.x)",//r=0～1
				
				"$temp.x *= @dFogData.z",
				"$temp.x += @dFogColor.w",//r=近濃～遠濃
				
				"$temp.w = @1 - $temp.x",
				"$temp.xyz = @dFogColor.xyz * $temp.x",
				
				"$output.xyz *= $temp.www",
				"$output.xyz += $temp.xyz"
			);
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			if (_color == value) return;
			
			_color = value;
			calcFogConst();
		}
		
		public function get distanceNear():Number 
		{
			return _distanceNear;
		}
		
		public function set distanceNear(value:Number):void 
		{
			if (_distanceNear == value) return;
			
			_distanceNear = value;
			calcFogConst();
		}
		
		public function get distanceFar():Number 
		{
			return _distanceFar;
		}
		
		public function set distanceFar(value:Number):void 
		{
			if (_distanceFar == value) return;
			
			_distanceFar = value;
			calcFogConst();
		}
		
		public function get densityNear():Number 
		{
			return _densityNear;
		}
		
		public function set densityNear(value:Number):void 
		{
			if (_densityNear == value) return;
			
			_densityNear = value;
			calcFogConst();
		}
		
		public function get densityFar():Number 
		{
			return _densityFar;
		}
		
		public function set densityFar(value:Number):void 
		{
			if (_densityFar == value) return;
			
			_densityFar = value;
			calcFogConst();
		}
		
		public function get blendMode():String 
		{
			return _blendMode;
		}
		
		public function set blendMode(value:String):void 
		{
			if (_blendMode == value) return;
			
			_blendMode = value;
			updateShaderCode();
		}
		
		override public function clone():MaterialShader 
		{
			var shader:DistanceFogShader = new DistanceFogShader(_color, _distanceNear, _distanceFar, _densityNear, _densityFar);
			shader.blendMode = _blendMode;
			return shader;
		}
		
	}

}