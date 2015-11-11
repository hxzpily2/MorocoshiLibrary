package net.morocoshi.moja3d.shaders.core 
{
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.depth.DepthBasicShader;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 最初に追加する基本シェーダー
	 * 
	 * @author tencho
	 */
	public class MatrixShader extends MaterialShader 
	{
		private var depthShader:DepthBasicShader;
		private var geometry:Geometry;
		
		public function MatrixShader(geometry:Geometry) 
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
			var key:String = "MatrixShader:";
			key += "_" + int(geometry.hasAttribute(VertexAttribute.NORMAL));
			return key;
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
			
			vertexConstants.modelMatrix = true;
			vertexCode.addCode(
				"$pos.xyz = m34($pos, @modelMatrix)",//モデル行列で変換
				"$wpos = $pos"
			);
			
			//Normal モデル行列で法線を変換
			if (geometry.hasAttribute(VertexAttribute.NORMAL))
			{
				vertexCode.addCode(
					"$normal.xyz = m33($normal.xyz, @modelMatrix)"
				);
			}
		}
		
		override public function clone():MaterialShader 
		{
			return new MatrixShader(geometry);
		}
		/*
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.DEPTH)
			{
				if (depthShader == null)
				{
					depthShader = new DepthBasicShader(geometry);
				}
				return depthShader;
			}
			return null;
		}
		*/

}