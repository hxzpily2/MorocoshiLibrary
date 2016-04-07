package net.morocoshi.moja3d.shaders.line 
{
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.depth.DepthEndShader;
	
	/**
	 * 最後に追加するシェーダー
	 * 
	 * @author tencho
	 */
	public class LineEndShader extends MaterialShader 
	{
		private var depthShader:DepthEndShader;
		private var geometry:Geometry;
		
		public function LineEndShader(geometry:Geometry) 
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
			return "LineEndShader:";
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
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var va:String = "va" + geometry.getAttributeIndex(VertexAttribute.LINE_VECTOR);
			
			vertexConstants.projMatrix = true;
			vertexConstants.clipMatrix = true;
			vertexConstants.cameraPosition = true;
			
			vertexCode.addCode([
				"#vpos = $pos",
				"$pos = m44($pos, @projMatrix)",//プロジェクション行列?で変換
				
				"$thick.xy *= $pos.zz",
				"$thick.xy /= @cameraPosition.ww",
				"$thick.xy *= " + va + ".ww",
				"$pos.xy += $thick.xy",
				
				
				"#spos = $pos",//スクリーン座標
				"$pos = m44($pos, @clipMatrix)",//クリッピング行列?で変換
				"op = $pos.xyzw"
			]);
			
			//ワールド法線
			if (geometry.hasAttribute(VertexAttribute.NORMAL))
			{
				vertexCode.addCode([
					"$normal.xyz = nrm($normal.xyz)",
					"#normal = $normal.xyz"
				]);
			}
			
			fragmentCode.addCode([
				"oc = $output"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new LineEndShader(geometry);
		}
		
	}

}