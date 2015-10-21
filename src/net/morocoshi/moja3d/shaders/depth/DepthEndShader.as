package net.morocoshi.moja3d.shaders.depth 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DepthEndShader extends MaterialShader 
	{
		private var _shadowThreshold:Number;
		private var shadowConst:AGALConstant;
		
		public function DepthEndShader(shadowThreshold:Number) 
		{
			super();
			
			_shadowThreshold = shadowThreshold;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "DepthEndShader:";
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
			shadowConst = fragmentCode.addConstantsFromArray("@depthThreshold", [_shadowThreshold, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.viewMatrix = true;
			vertexConstants.projMatrix = true;
			
			vertexCode.addCode(
				"$pos.xyz = m34($pos, @viewMatrix)",//ビュー行列で変換
				"$pos = m44($pos, @projMatrix)",//プロジェクション行列?で変換
				"#spos = $pos",//スクリーン座標
				"op = $pos"
			)
			
			fragmentConstants.number = true;
			fragmentCode.addCode(
				"$alpha.x -= @depthThreshold.x",
				"kil $alpha.x",
				"oc = $output"
			);
		}
		
		override public function clone():MaterialShader 
		{
			return new DepthEndShader(_shadowThreshold);
		}
		
		public function get shadowThreshold():Number 
		{
			return _shadowThreshold;
		}
		
		public function set shadowThreshold(value:Number):void 
		{
			_shadowThreshold = value;
			shadowConst.x = _shadowThreshold;
		}
		
	}

}