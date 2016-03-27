package net.morocoshi.moja3d.shaders.depth 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class DepthAlphaShader extends MaterialShader 
	{
		private var _alpha:Number;
		private var alphaConst:AGALConstant;
		
		public function DepthAlphaShader(alpha:Number) 
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
			return "DepthAlphaShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = (_alpha < 1)? AlphaTransform.MUL_TRANSPARENT : (_alpha == 1)? AlphaTransform.UNCHANGE : AlphaTransform.SET_UNKNOWN;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			alphaConst = fragmentCode.addConstantsFromArray("@depthAlpha", [_alpha, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			fragmentConstants.number = true;
			fragmentCode.addCode(["$alpha.x *= @depthAlpha.x"]);
		}
		
		override public function clone():MaterialShader 
		{
			return new DepthAlphaShader(_alpha);
		}
		
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			alphaConst.x = _alpha;
		}
		
	}

}