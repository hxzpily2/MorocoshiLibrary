package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	/**
	 * ...
	 * @author ...
	 */
	public class UVWorldScaleShader extends MaterialShader 
	{
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var scaleConst:AGALConstant;
		
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
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			scaleConst = vertexCode.addConstantsFromArray("@worldScale", [_x, _y, _width, _height]);
			
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexCode.addCode(
				"$uv.xy = $pos.xy",
				"$uv.xy += @worldScale.xy",
				"$uv.xy /= @worldScale.zw",
				"#uv = $uv"//UV
			);
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
			scaleConst.x = _x;
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
			scaleConst.y = _y;
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			_width = value;
			scaleConst.z = _width;
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			_height = value;
			scaleConst.w = _height;
		}
		
		override public function clone():MaterialShader 
		{
			var shader:UVWorldScaleShader = new UVWorldScaleShader(_x, _y, _width, _height);
			return shader;
		}
		
	}

}