package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class SpriteFillShader extends MaterialShader 
	{
		private var _color:uint;
		private var _alpha:Number;
		private var colorConst:AGALConstant;
		
		public function SpriteFillShader(color:uint, alpha:Number = 1) 
		{
			super();
			_color = color;
			_alpha = alpha;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SpriteFillShader:";
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
			colorConst = fragmentCode.addConstantsFromColor("@rgba", _color, _alpha);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentCode.addCode(
				"$output.xyzw = @rgba.xyzw"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteFillShader = new SpriteFillShader(_color, _alpha);
			return shader;
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			colorConst.setRGB(_color);
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			colorConst.w = _alpha;
		}
		
	}

}