package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.renderer.ReflectiveWater;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ReflectionPreviewFilter3D extends Filter3D 
	{
		private var shaderList:ShaderList;
		
		/**
		 * 
		 */
		public function ReflectionPreviewFilter3D() 
		{
			super();
			
			shaderList = createShaderList([]);
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			var ref:ReflectiveWater = manager.scene.collector.reflectiveWater;
			if (ref.textureResources.length)
			{
				manager.renderFinal(shaderList, 0, [ref.textureResources[0]]);
			}
			else
			{
				manager.renderFinal(shaderList, 0, [manager.currentTexture]);
			}
		}
		
	}

}