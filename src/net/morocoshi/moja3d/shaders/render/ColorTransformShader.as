package net.morocoshi.moja3d.shaders.render 
{
	import flash.geom.ColorTransform;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class ColorTransformShader extends MaterialShader 
	{
		private var multiply:AGALConstant;
		private var offset:AGALConstant;
		
		private var _redOffset:Number;
		private var _greenOffset:Number;
		private var _blueOffset:Number;
		private var _alphaOffset:Number;
		private var _redMultiplier:Number;
		private var _greenMultiplier:Number;
		private var _blueMultiplier:Number;
		private var _alphaMultiplier:Number;
		
		public function ColorTransformShader() 
		{
			super();
			
			_redOffset = 0;
			_greenOffset = 0;
			_blueOffset = 0;
			_alphaOffset = 0;
			_redMultiplier = 1;
			_greenMultiplier = 1;
			_blueMultiplier = 1;
			_alphaMultiplier = 1;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "ColorTransformShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			alphaMode = (_alphaOffset != 0)? AlphaMode.MIX : (_alphaMultiplier < 1)? AlphaMode.ALL : AlphaMode.NONE;
			super.updateAlphaMode();
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			multiply = fragmentCode.addConstantsFromArray("@colorMultiply", [_redMultiplier, _greenMultiplier, _blueMultiplier, _alphaMultiplier]);
			offset = fragmentCode.addConstantsFromArray("@colorOffset", [_redOffset / 0xff, _greenOffset / 0xff, _blueOffset / 0xff, _alphaOffset / 0xff]);
			fragmentCode.addCode(
				"$output.xyzw *= @colorMultiply.xyzw",
				"$output.xyzw += @colorOffset.xyzw"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:ColorTransformShader = new ColorTransformShader();
			return shader;
		}
		
		/**
		 * 着色する
		 * @param	rgb
		 * @param	density
		 * @param	alpha
		 */
		public function setFillColor(rgb:uint, density:Number = 1, alpha:Number = 1):void
		{
			applyFrom(Palette.getFillColor(rgb, density, alpha));
		}
		
		/**
		 * ColorTransformで設定する
		 * @param	colorTransform
		 */
		public function applyFrom(colorTransform:ColorTransform):void 
		{
			redMultiplier = colorTransform.redMultiplier;
			greenMultiplier = colorTransform.greenMultiplier;
			blueMultiplier = colorTransform.blueMultiplier;
			alphaMultiplier = colorTransform.alphaMultiplier;
			redOffset = colorTransform.redOffset;
			greenOffset = colorTransform.greenOffset;
			blueOffset = colorTransform.blueOffset;
			alphaOffset = colorTransform.alphaOffset;
			updateAlphaMode();
		}
		
		public function get redOffset():Number 
		{
			return _redOffset;
		}
		
		public function set redOffset(value:Number):void 
		{
			offset.x = (_redOffset = value) / 0xff;
		}
		
		public function get greenOffset():Number 
		{
			return _greenOffset;
		}
		
		public function set greenOffset(value:Number):void 
		{
			offset.y = (_greenOffset = value) / 0xff;
		}
		
		public function get blueOffset():Number 
		{
			return _blueOffset;
		}
		
		public function set blueOffset(value:Number):void 
		{
			offset.z = (_blueOffset = value) / 0xff;
		}
		
		public function get alphaOffset():Number 
		{
			return _alphaOffset;
		}
		
		public function set alphaOffset(value:Number):void 
		{
			offset.w = (_alphaOffset = value) / 0xff;
			updateAlphaMode();
		}
		
		public function get redMultiplier():Number 
		{
			return _redMultiplier;
		}
		
		public function set redMultiplier(value:Number):void 
		{
			multiply.x = _redMultiplier = value;
		}
		
		public function get greenMultiplier():Number 
		{
			return _greenMultiplier;
		}
		
		public function set greenMultiplier(value:Number):void 
		{
			multiply.y = _greenMultiplier = value;
		}
		
		public function get blueMultiplier():Number 
		{
			return _blueMultiplier;
		}
		
		public function set blueMultiplier(value:Number):void 
		{
			multiply.z = _blueMultiplier = value;
		}
		
		public function get alphaMultiplier():Number 
		{
			return _alphaMultiplier;
		}
		
		public function set alphaMultiplier(value:Number):void 
		{
			multiply.w = _alphaMultiplier = value;
			updateAlphaMode();
		}
		
	}

}