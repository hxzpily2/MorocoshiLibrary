package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ワールド座標での矩形でクリッピングする
	 * 
	 * @author tencho
	 */
	public class SpriteGlobalClippingShader extends MaterialShader 
	{
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var sizeConst:AGALConstant;
		
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 */
		public function SpriteGlobalClippingShader(x:Number, y:Number, width:Number, height:Number) 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			setSize(x, y, width, height);
		}
		
		public function setSize(x:Number, y:Number, width:Number, height:Number):void
		{
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			calcConstants();
		}
		
		override public function getKey():String 
		{
			return "SpriteGlobalClippingShader:";
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
			sizeConst = fragmentCode.addConstantsFromArray("@clipSize", [0, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentCode.addCode([
				"var $temp",
				"$temp.x = #spos.x - @clipSize.x",
				"$temp.y = #spos.y - @clipSize.y",
				"$temp.z = @clipSize.z - #spos.x",
				"$temp.w = @clipSize.w - #spos.y",
				"kil $temp.z",
				"kil $temp.x",
				"kil $temp.y",
				"kil $temp.w"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteGlobalClippingShader = new SpriteGlobalClippingShader(_x, _y, _width, _height);
			return shader;
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
			calcConstants();
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
			calcConstants();
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			sizeConst.z = _width = value;
			calcConstants();
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			_height = value;
			calcConstants();
		}
		
		private function calcConstants():void 
		{
			sizeConst.x = _x;
			sizeConst.y = _y;
			sizeConst.z = _x + _width;
			sizeConst.w = _y + _height;
		}
		
	}

}