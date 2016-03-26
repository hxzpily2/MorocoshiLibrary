package net.morocoshi.moja3d.shaders.depth 
{
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 深度テクスチャ描画用の基本シェーダー
	 * 
	 * @author tencho
	 */
	public class DepthMatrixShader extends MaterialShader 
	{
		private var geometry:Geometry;
		
		public function DepthMatrixShader(geometry:Geometry) 
		{
			super();
			this.geometry = geometry;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "DepthMatrixShader:";
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
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.modelMatrix = true;
			
			vertexCode.addCode([
				"$pos.xyz = m34($pos, @modelMatrix)"//モデル行列で変換
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new DepthMatrixShader(geometry);
		}
		
	}

}