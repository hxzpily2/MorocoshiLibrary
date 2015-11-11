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
	public class BasicShader extends MaterialShader 
	{
		private var depthShader:DepthBasicShader;
		private var geometry:Geometry;
		
		public function BasicShader(geometry:Geometry) 
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
			var key:String = "BasicShader:";
			key += "_" + int(geometry.hasAttribute(VertexAttribute.POSITION));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.UV));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.NORMAL));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.VERTEXCOLOR));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.TANGENT4));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.BONEINDEX1));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.BONEINDEX2));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.BONEWEIGHT1));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.BONEWEIGHT2));
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
			fragmentConstants.number = true;
			vertexCode.addCode(
				"global $pos",
				"global $wpos",
				//position
				"$pos = va" + geometry.getAttributeIndex(VertexAttribute.POSITION),
				"$pos.xyz = m34($pos, @modelMatrix)",//モデル行列で変換
				"$wpos = $pos"
			);
			fragmentCode.addCode(
				
				"global $output",
				"global $common",
				"$common.xyzw = @1"
			);
			
			//UV
			if (geometry.hasAttribute(VertexAttribute.UV))
			{
				vertexCode.addCode(
					"global $uv",
					"$uv = va" + geometry.getAttributeIndex(VertexAttribute.UV),
					"#uv = $uv"
				);
			}
			
			//Normal モデル行列で法線を変換
			if (geometry.hasAttribute(VertexAttribute.NORMAL))
			{
				vertexCode.addCode(
					"global $normal",
					"$normal.xyz = va" + geometry.getAttributeIndex(VertexAttribute.NORMAL) + ".xyz",
					"$normal.xyz = m33($normal.xyz, @modelMatrix)"
				);
				//正規化された法線
				fragmentCode.addCode(
					"global $normal",
					"$normal.xyz = nrm(#normal.xyz)",
					"$normal.w = @1"
				);
			}
			
			//VertexColor
			if (geometry.hasAttribute(VertexAttribute.VERTEXCOLOR))
			{
				vertexCode.addCode(
					"var $vcolor",
					"$vcolor = va" + geometry.getAttributeIndex(VertexAttribute.VERTEXCOLOR),
					"#vcolor = $vcolor"//頂点カラー
				);
			}
			
			//Tangent4
			if (geometry.hasAttribute(VertexAttribute.TANGENT4))
			{
				vertexCode.addCode(
					"var $tangent4",
					"$tangent4 = va" + geometry.getAttributeIndex(VertexAttribute.TANGENT4),
					"#tangent4 = $tangent4"
				);
			}
		}
		
		override public function clone():MaterialShader 
		{
			return new BasicShader(geometry);
		}
		
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
		
	}

}