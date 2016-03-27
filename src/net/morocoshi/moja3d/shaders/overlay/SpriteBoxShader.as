package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class SpriteBoxShader extends MaterialShader 
	{
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var sizeConst:AGALConstant;
		
		public function SpriteBoxShader(x:Number, y:Number, width:Number, height:Number) 
		{
			super();
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SpriteBoxShader:";
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
			sizeConst = vertexCode.addConstantsFromArray("@spriteSize", [_x, _y, _width, _height]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			vertexCode.addCode([
				"$pos.xy *= @spriteSize.zw",
				"$pos.xy += @spriteSize.xy"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteBoxShader = new SpriteBoxShader(_x, _y, _width, _height);
			return shader;
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
			sizeConst.x = _x;
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
			sizeConst.y = _y;
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			_width = value;
			sizeConst.z = _width;
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			_height = value;
			sizeConst.w = _height;
		}
		
	}

}