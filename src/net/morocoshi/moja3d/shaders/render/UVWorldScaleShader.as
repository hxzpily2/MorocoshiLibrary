package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * UVをワールド空間規準で貼る
	 * 
	 * @author tencho
	 */
	public class UVWorldScaleShader extends MaterialShader 
	{
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var constant:AGALConstant;
		
		public function UVWorldScaleShader(x:Number, y:Number, width:Number, height:Number)
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
			return "UVWorldScaleShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.UNKNOWN;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			constant = vertexCode.addConstantsFromArray("@worldScale", [_x, _y, _width, _height]);
			
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexCode.addCode([
				"$uv.xy = $pos.xy",
				"$uv.xy += @worldScale.xy",
				"$uv.xy /= @worldScale.zw",
				"#uv = $uv"//UV
			]);
		}
		
		public function get x():Number { return _x; }	
		public function set x(value:Number):void { constant.x = _x = value; }
		public function get y():Number { return _y; }
		public function set y(value:Number):void { constant.y = _y = value; }
		public function get width():Number { return _width; }
		public function set width(value:Number):void { constant.z = _width = value; }
		public function get height():Number { return _height; }
		public function set height(value:Number):void { constant.w = _height = value; }
		
		override public function clone():MaterialShader 
		{
			return new UVWorldScaleShader(_x, _y, _width, _height);
		}
		
	}

}