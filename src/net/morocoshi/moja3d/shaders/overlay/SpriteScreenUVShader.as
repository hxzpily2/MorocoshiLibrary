package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * UVがスクリーン位置になるようにする
	 * 
	 * @author tencho
	 */
	public class SpriteScreenUVShader extends MaterialShader 
	{
		
		public function SpriteScreenUVShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SpriteScreenUVShader:";
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
			vertexCode.addCode([
				"$uv.xy = $pos.xy / @viewSize.xy"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteScreenUVShader = new SpriteScreenUVShader();
			return shader;
		}
		
	}

}