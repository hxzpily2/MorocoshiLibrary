package net.morocoshi.moja3d.shaders.core 
{
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ビュー行列変換
	 * 
	 * @author tencho
	 */
	public class ViewTransformShader extends MaterialShader 
	{
		
		public function ViewTransformShader() 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "ViewTransformShader:";
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
			
			vertexConstants.viewMatrix = true;
			vertexCode.addCode([
				//position
				"#wpos = $wpos",
				"$pos.xyz = m34($pos, @viewMatrix)"//ビュー行列で変換
			]);
		}
		
		override public function clone():MaterialShader 
		{
			return new ViewTransformShader();
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.OUTLINE)
			{
				return new ViewTransformShader();
			}
			return null;
		}
		
	}

}