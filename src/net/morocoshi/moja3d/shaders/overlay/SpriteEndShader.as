package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.depth.DepthEndShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SpriteEndShader extends MaterialShader 
	{
		private var depthShader:DepthEndShader;
		
		public function SpriteEndShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SpriteEndShader:";
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
			
			vertexConstants.viewSize = true;
			vertexCode.addConstantsFromArray("@offset", [2, -2, -1, 1]);
			vertexCode.addCode(
				"$pos.xyz = m34($pos, @modelMatrix)",//モデル行列で変換
				"#spos = $pos",
				"$pos.xy /= @viewSize.xy",
				"$pos.xy *= @offset.xy",
				"$pos.xy += @offset.zw",
				"#uv = $uv",
				"op = $pos"
			);
			fragmentCode.addCode(
				"oc = $output"
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteEndShader = new SpriteEndShader();
			return shader;
		}
		
	}

}