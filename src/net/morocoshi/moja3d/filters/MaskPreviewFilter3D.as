package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MaskPreviewFilter3D extends Filter3D 
	{
		private var shaderList:ShaderList;
		
		/**
		 * 
		 */
		public function MaskPreviewFilter3D() 
		{
			super();
			hasMaskElement = true;
			
			shaderList = createShaderList([]);
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			manager.renderFinal(shaderList, 0, [manager.maskTexture]);
		}
		
	}

}