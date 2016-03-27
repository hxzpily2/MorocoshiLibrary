package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 透過
	 * 
	 * @author tencho
	 */
	public class AlphaShader extends MaterialShader 
	{
		private var _alpha:Number;
		private var alphaConst:AGALConstant;
		
		public function AlphaShader(alpha:Number) 
		{
			super();
			_alpha = alpha;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "AlphaShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			if (_alpha < 1)
			{
				alphaTransform = AlphaTransform.MUL_TRANSPARENT;
			}
			else if (_alpha > 1)
			{
				alphaTransform = AlphaTransform.SET_UNKNOWN;
			}
			else
			{
				alphaTransform = AlphaTransform.UNCHANGE;
			}
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			alphaConst = fragmentCode.addConstantsFromArray("@alpha", [_alpha, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentCode.addCode(["$output.w *= @alpha.x"]);
		}
		
		override public function clone():MaterialShader 
		{
			return new AlphaShader(_alpha);
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			alphaConst.x = _alpha;
			updateAlphaMode();
		}
		
	}

}