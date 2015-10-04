package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class UVOffsetShader extends MaterialShader 
	{
		private var _offsetU:Number;
		private var _offsetV:Number;
		private var _scaleU:Number;
		private var _scaleV:Number;
		private var offsetConst:AGALConstant;
		
		//　　V
		//　　↑
		//　　|　　UV方向
		//　　|
		//　　+―――――――> U
		
		/**
		 * 
		 * @param	offsetX
		 * @param	offsetY
		 * @param	scaleX
		 * @param	scaleY
		 */
		public function UVOffsetShader(offsetU:Number, offsetV:Number, scaleU:Number, scaleV:Number)
		{
			super();
			
			requiredAttribute.push(VertexAttribute.UV);
			
			_offsetU = offsetU;
			_offsetV = offsetV;
			_scaleU = scaleU;
			_scaleV = scaleV;
			
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
			
			offsetConst = vertexCode.addConstantsFromArray("@offsetUV", [_offsetU, -_offsetV, _scaleU, _scaleV]);
			
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexCode.addCode(
				"$uv.xy += @offsetUV.xy",
				"$uv.xy *= @offsetUV.zw",
				"#uv = $uv"//UV
			);
		}
		
		public function get offsetU():Number 
		{
			return _offsetU;
		}
		
		public function set offsetU(value:Number):void 
		{
			_offsetU = value;
			offsetConst.x = _offsetU;
		}
		
		public function get offsetV():Number 
		{
			return _offsetV;
		}
		
		public function set offsetV(value:Number):void 
		{
			_offsetV = value;
			offsetConst.y = -_offsetV;
		}
		
		public function get scaleU():Number 
		{
			return _scaleU;
		}
		
		public function set scaleU(value:Number):void 
		{
			_scaleU = value;
			offsetConst.z = _scaleU;
		}
		
		public function get scaleV():Number 
		{
			return _scaleV;
		}
		
		public function set scaleV(value:Number):void 
		{
			_scaleV = value;
			offsetConst.w = _offsetV;
		}
		
		override public function clone():MaterialShader 
		{
			var shader:UVOffsetShader = new UVOffsetShader(_offsetU, _offsetV, _scaleU, _scaleV);
			return shader;
		}
		
	}

}