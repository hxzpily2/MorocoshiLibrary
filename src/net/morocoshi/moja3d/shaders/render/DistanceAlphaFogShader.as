package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 距離フォグ
	 * 
	 * @author tencho
	 */
	public class DistanceAlphaFogShader extends MaterialShader 
	{
		private var _distanceNear:Number;
		private var _distanceFar:Number;
		private var _alphaNear:Number;
		private var _alphaFar:Number;
		
		private var distanceConst:AGALConstant;
			
		public function DistanceAlphaFogShader(distanceNear:Number, distanceFar:Number, alphaNear:Number, alphaFar:Number) 
		{
			super();
			
			_distanceNear = distanceNear;
			_distanceFar = distanceFar;
			_alphaNear = alphaNear;
			_alphaFar = alphaFar;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "DistanceAlphaFogShader:";
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
			
			distanceConst = fragmentCode.addConstantsFromArray("@dFogData", [0, 0, 0, 0]);
			calcFogConst();
		}
		
		private function calcFogConst():void 
		{
			distanceConst.x = _distanceNear;
			distanceConst.y = _distanceFar - _distanceNear;
			distanceConst.z = _alphaNear;
			distanceConst.w = _alphaFar - _alphaNear;
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
				
				"$temp.x *= @dFogData.w",
				"$temp.x += @dFogData.z",//r=近濃～遠濃
				
				"$output.w *= $temp.x"
			);
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
		
		public function get alphaNear():Number 
		{
			return _alphaNear;
		}
		
		public function set alphaNear(value:Number):void 
		{
			if (_alphaNear == value) return;
			
			_alphaNear = value;
			calcFogConst();
		}
		
		public function get alphaFar():Number 
		{
			return _alphaFar;
		}
		
		public function set alphaFar(value:Number):void 
		{
			if (_alphaFar == value) return;
			
			_alphaFar = value;
			calcFogConst();
		}
		
		override public function clone():MaterialShader 
		{
			return new DistanceAlphaFogShader(_distanceNear, _distanceFar, _alphaNear, _alphaFar);
		}
		
	}

}