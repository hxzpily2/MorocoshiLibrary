package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * UVをずらす
	 * 
	 * @author tencho
	 */
	public class UVOffsetShader extends MaterialShader 
	{
		private var _offsetU:Number;
		private var _offsetV:Number;
		private var _scaleU:Number;
		private var _scaleV:Number;
		private var constant:AGALConstant;
		
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
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			
			constant = vertexCode.addConstantsFromArray("@offsetUV", [_offsetU, -_offsetV, _scaleU, _scaleV]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexCode.addCode([
				"$uv.xyzw *= @offsetUV.zwzw",
				"$uv.xyzw += @offsetUV.xyxy"
			]);
		}
		
		public function get offsetU():Number { return _offsetU; }
		public function set offsetU(value:Number):void { constant.x = _offsetU = value; }	
		public function get offsetV():Number { return _offsetV; }
		public function set offsetV(value:Number):void { constant.y = -(_offsetV = value); }	
		public function get scaleU():Number { return _scaleU; }
		public function set scaleU(value:Number):void { constant.z = _scaleU = value; }
		public function get scaleV():Number { return _scaleV; }
		public function set scaleV(value:Number):void { constant.w = _scaleV = value; }
		
		override public function clone():MaterialShader 
		{
			return new UVOffsetShader(_offsetU, _offsetV, _scaleU, _scaleV);
		}
		
	}

}