package net.morocoshi.moja3d.shaders.core 
{
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.depth.DepthMatrixShader;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * モデル行列変換
	 * 
	 * @author tencho
	 */
	public class ModelTransformShader extends MaterialShader 
	{
		private var shadowShader:DepthMatrixShader;
		private var geometry:Geometry;
		
		public function ModelTransformShader(geometry:Geometry) 
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
			var key:String = "ModelTransformShader:";
			key += "_" + int(geometry.hasAttribute(VertexAttribute.NORMAL));
			return key;
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
			
			vertexConstants.modelMatrix = true;
			vertexCode.addCode([
				"$pos.xyz = m34($pos, @modelMatrix)",//モデル行列で変換
				"$wpos = $pos"
			]);
			
			//Normal モデル行列で法線を変換
			if (geometry.hasAttribute(VertexAttribute.NORMAL))
			{
				vertexCode.addCode([
					"$normal.xyz = m33($normal.xyz, @modelMatrix)"
				]);
			}
		}
		
		override public function clone():MaterialShader 
		{
			return new ModelTransformShader(geometry);
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.SHADOW)
			{
				return shadowShader || (shadowShader = new DepthMatrixShader(geometry));
			}
			if (phase == RenderPhase.OUTLINE)
			{
				return new ModelTransformShader(geometry);
			}
			return null;
		}
		
	}
}