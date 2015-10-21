package net.morocoshi.moja3d.shaders.core 
{
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.depth.DepthEndShader;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 最後に追加するシェーダー
	 * 
	 * @author tencho
	 */
	public class EndShader extends MaterialShader 
	{
		private var depthShader:DepthEndShader;
		private var geometry:Geometry;
		
		public function EndShader(geometry:Geometry) 
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
			return "EndShader:";
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
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.projMatrix = true;
			
			vertexCode.addCode(
				"#vpos = $pos",
				"$pos = m44($pos, @projMatrix)",//プロジェクション行列?で変換
				"#spos = $pos",//スクリーン座標
				"op = $pos.xyzw"//スクリーン座標
			);
			
			//ワールド法線
			if (geometry.hasAttribute(VertexAttribute.NORMAL))
			{
				vertexCode.addCode(
					"$normal.xyz = nrm($normal.xyz)",
					"#normal = $normal.xyz"
				);
			}
			
			fragmentCode.addCode(
				"oc = $output"
			);
		}
		
		override public function clone():MaterialShader 
		{
			return new EndShader(geometry);
		}
		
	}

}