package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.depth.DepthEndShader;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SpriteEndShader extends MaterialShader 
	{
		private var depthShader:DepthEndShader;
		moja3d var clippingConst:AGALConstant;
		
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
			vertexCode.addConstantsFromArray("@offsetSprite", [2, -2, -1, 1]);
			clippingConst = vertexCode.addConstantsFromArray("@clippingSprite", [0, 0, 0, 0]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			vertexConstants.viewSize = true;
			vertexCode.addCode([
				"$pos.xyz = m34($pos, @modelMatrix)",//モデル行列で変換
				"#spos = $pos",
				"$pos.xy += @clippingSprite.xy",
				"$pos.xy /= @viewSize.xy",
				"$pos.xy *= @offsetSprite.xy",
				"$pos.xy += @offsetSprite.zw",
				"#uv = $uv",
				"op = $pos"
			]);
			fragmentCode.addCode([
				"oc = $output"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteEndShader = new SpriteEndShader();
			return shader;
		}
		
	}

}