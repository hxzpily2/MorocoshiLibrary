package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.depth.DepthBasicShader;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SpriteBasicShader extends MaterialShader 
	{
		private var depthShader:DepthBasicShader;
		
		public function SpriteBasicShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SpriteBasicShader:";
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
				"global $pos",
				"global $uv",
				
				//position
				"$pos = va0",
				
				//uv
				"$uv = va1"
			]);
			
			fragmentConstants.number = true;
			fragmentCode.addCode([
				//最終出力
				"global $output"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteBasicShader = new SpriteBasicShader();
			return shader;
		}
		
	}

}