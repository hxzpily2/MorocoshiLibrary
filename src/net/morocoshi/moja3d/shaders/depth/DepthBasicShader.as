package net.morocoshi.moja3d.shaders.depth 
{
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 深度テクスチャ描画用の基本シェーダー
	 * 
	 * @author tencho
	 */
	public class DepthBasicShader extends MaterialShader 
	{
		private var geometry:Geometry;
		public function DepthBasicShader(geometry:Geometry) 
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
			var key:String = "DepthBasicShader:";
			key += "_" + int(geometry.hasAttribute(VertexAttribute.POSITION));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.UV));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.NORMAL));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.VERTEX_COLOR));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.TANGENT4));
			key += "_" + int(geometry.hasAttribute(VertexAttribute.BONEINDEX));
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
			
			fragmentCode.addConstantsFromArray("@N256", [256, 256 * 256, 256 * 256 * 256, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.number = true;
			vertexConstants.modelMatrix = true;
			vertexConstants.projMatrix = true;
			vertexConstants.viewMatrix = true;
			
			vertexCode.addCode(
				"global $pos",
				"$pos = va" + geometry.getAttributeIndex(VertexAttribute.POSITION),
				"$pos.xyz = m34($pos, @modelMatrix)",//モデル行列で変換
				"var $temp"
			);
			
			//UV
			if (geometry.hasAttribute(VertexAttribute.UV))
			{
				vertexCode.addCode(
					"$temp = va" + geometry.getAttributeIndex(VertexAttribute.UV),
					"#uv = $temp"
				);
			}
			
			//Normal モデル行列で法線を変換
			if (geometry.hasAttribute(VertexAttribute.NORMAL))
			{
				vertexCode.addCode(
					"$temp = va" + geometry.getAttributeIndex(VertexAttribute.NORMAL),
					"#normal = $temp"
				);
			}
			
			//VertexColor
			if (geometry.hasAttribute(VertexAttribute.VERTEX_COLOR))
			{
				vertexCode.addCode(
					"var $vcolor",
					"$vcolor = va" + geometry.getAttributeIndex(VertexAttribute.VERTEX_COLOR),
					"#vcolor = $vcolor"
				);
			}
			
			//Tangent4
			if (geometry.hasAttribute(VertexAttribute.TANGENT4))
			{
				vertexCode.addCode(
					"$temp = va" + geometry.getAttributeIndex(VertexAttribute.TANGENT4),
					"#tangent4 = $temp"
				);
			}
			
			fragmentConstants.number = true;
			
			fragmentCode.addCode(
				"global $alpha",
				"global $output",
				"var $temp",
				"var $color",
				
				"$temp.x = #spos.z / #spos.w",//元のデプス値0～1
				
				"$temp.y = $temp.x * @N256.x",//元デプス値を0～256に
				"$temp.z = frc($temp.y)",//少数取り出し
				"$temp.y -= $temp.z",//0～256の整数化
				
				"$output.x = $temp.y / @N256.x",//R
				
				"$temp.y = $temp.z * @N256.x",//Rの少数値を0～256に
				"$temp.z = frc($temp.y)",//少数取り出し
				"$temp.y -= $temp.z",//0～256の整数化
				
				"$output.y = $temp.y / @N256.x",//G
				
				"$temp.y = $temp.z * @N256.x",//Gの少数値を0～256に
				"$temp.z = frc($temp.y)",//少数取り出し
				"$temp.y -= $temp.z",//0～256の整数化
				
				"$output.z = $temp.y / @N256.x",//B
				
				"$output.w = @1",
				"$alpha.x = @1"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:DepthBasicShader = new DepthBasicShader(geometry);
			return shader;
		}
		
	}

}