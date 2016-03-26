package net.morocoshi.moja3d.shaders.outline 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * 深度テクスチャ描画用の基本シェーダー
	 * 
	 * @author tencho
	 */
	public class OutlineBasicShader extends MaterialShader 
	{
		private var geometry:Geometry;
		
		public function OutlineBasicShader(geometry:Geometry) 
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
			return "OutlineBasicShader:" + geometry.attributesKey;
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
			
			//fragmentCode.addConstantsFromArray("@N256", [256, 256 * 256, 256 * 256 * 256, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.modelMatrix = true;
			fragmentConstants.number = true;
			vertexCode.addCode([
				"global $pos",
				"global $wpos",
				"$pos = va" + geometry.getAttributeIndex(VertexAttribute.POSITION)
			]);
			fragmentCode.addCode([
				
				"global $output",
				"global $common",
				"$common.xyzw = @1"
			]);
			
			//UV
			if (geometry.hasAttribute(VertexAttribute.UV))
			{
				vertexCode.addCode([
					"global $uv",
					"$uv = va" + geometry.getAttributeIndex(VertexAttribute.UV),
					"#uv = $uv"
				]);
			}
			
			//Normal モデル行列で法線を変換
			if (geometry.hasAttribute(VertexAttribute.NORMAL))
			{
				vertexCode.addCode([
					"global $normal",
					"$normal.xyz = va" + geometry.getAttributeIndex(VertexAttribute.NORMAL) + ".xyz"
				]);
				/*
				//正規化された法線
				fragmentCode.addCode([
					"global $normal",
					"$normal.xyz = nrm(#normal.xyz)",
					"$normal.w = @1"
				]);*/
			}
			
			//VertexColor
			if (geometry.hasAttribute(VertexAttribute.VERTEXCOLOR))
			{
				vertexCode.addCode([
					"var $vcolor",
					"$vcolor = va" + geometry.getAttributeIndex(VertexAttribute.VERTEXCOLOR),
					"#vcolor = $vcolor"//頂点カラー
				]);
			}
			
			//Tangent4
			if (geometry.hasAttribute(VertexAttribute.TANGENT4))
			{
				vertexCode.addCode([
					"var $tangent4",
					"$tangent4 = va" + geometry.getAttributeIndex(VertexAttribute.TANGENT4),
					"#tangent4 = $tangent4"
				]);
			}
		}
		
		override public function clone():MaterialShader 
		{
			return new OutlineBasicShader(geometry);
		}
		
	}

}