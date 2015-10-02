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
	public class UVOffsetShader extends MaterialShader 
	{
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _scaleX:Number;
		private var _scaleY:Number;
		private var offsetConst:AGALConstant;
		
		public function UVOffsetShader(offsetX:Number, offsetY:Number, scaleX:Number, scaleY:Number)
		{
			super();
			
			_offsetX = offsetX;
			_offsetY = offsetY;
			_scaleX = scaleX;
			_scaleY = scaleY;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "UVOffsetShader:";
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
			
			offsetConst = vertexCode.addConstantsFromArray("@offset", [_offsetX, _offsetY, _scaleX, _scaleY]);
			
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexCode.addCode(
				"$uv.xy += @offset.xy",
				"$uv.xy *= @offset.zw",
				"#uv = $uv"//UV
			);
		}
		
		public function get offsetX():Number 
		{
			return _offsetX;
		}
		
		public function set offsetX(value:Number):void 
		{
			_offsetX = value;
			offsetConst.x = _offsetX;
		}
		
		public function get offsetY():Number 
		{
			return _offsetY;
		}
		
		public function set offsetY(value:Number):void 
		{
			_offsetY = value;
			offsetConst.y = _offsetY;
		}
		
		public function get scaleX():Number 
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void 
		{
			_scaleX = value;
			offsetConst.z = _scaleX;
		}
		
		public function get scaleY():Number 
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void 
		{
			_scaleY = value;
			offsetConst.w = _offsetY;
		}
		
		override public function clone():MaterialShader 
		{
			var shader:UVOffsetShader = new UVOffsetShader(_offsetX, _offsetY, _scaleX, _scaleY);
			return shader;
		}
		
	}

}