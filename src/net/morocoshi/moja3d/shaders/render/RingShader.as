package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * リングを描き込む
	 * 
	 * @author tencho
	 */
	public class RingShader extends MaterialShader 
	{
		private var positionConst:AGALConstant;
		private var colorConst:AGALConstant;
		
		private var _x:Number;
		private var _y:Number;
		private var _radius:Number;
		private var _thickness:Number;
		private var _rgb:uint;
		private var _alpha:Number;
		
		public function RingShader(radius:Number, thickness:Number, rgb:uint, alpha:Number) 
		{
			super();
			
			_x = 0;
			_y = 0;
			_radius = radius;
			_thickness = thickness;
			_rgb = rgb;
			_alpha = alpha;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
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
			
			positionConst = fragmentCode.addConstantsFromArray("@ringPosition", [_x, _y, 0, 0]);
			colorConst = fragmentCode.addConstantsFromColor("@ringColor", _rgb, _alpha);
			calcConst();
		}
		
		private function calcConst():void 
		{
			var near:Number = _radius - _thickness;
			var far:Number = _radius;
			if (near < 0) near = 0;
			positionConst.z = far * far;
			positionConst.w = near * near;
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentCode.addCode([
				"var $temp",
				"$temp.x = @ringPosition.x - #wpos.x",
				"$temp.y = @ringPosition.y - #wpos.y",
				"$temp.x *= $temp.x",
				"$temp.y *= $temp.y",
				"$temp.w = $temp.x + $temp.y",//$temp.w=中心からの半径の2乗
				
				"$temp.x = slt(@ringPosition.w, $temp.w)",
				"$temp.y = slt($temp.w, @ringPosition.z)",
				"$temp.w = $temp.x * $temp.y",
				"$temp.w *= @ringColor.w",
				
				"$temp.xyz = @ringColor.xyz",
				"$temp.xyz *= $temp.www",
				"$output.xyz += $temp.xyz"
			]);
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
			positionConst.x = value;
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
			positionConst.y = value;
		}
		
		public function get rgb():uint 
		{
			return _rgb;
		}
		
		public function set rgb(value:uint):void 
		{
			_rgb = value;
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
		}
		
		public function get thickness():Number 
		{
			return _thickness;
		}
		
		public function set thickness(value:Number):void 
		{
			_thickness = value;
			calcConst();
		}
		
		public function get radius():Number 
		{
			return _radius;
		}
		
		public function set radius(value:Number):void 
		{
			_radius = value;
			calcConst();
		}
		
		override public function clone():MaterialShader 
		{
			return new RingShader(_radius, _thickness, _rgb, _alpha);
		}
		
	}

}