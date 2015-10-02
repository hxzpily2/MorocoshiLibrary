package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.shaders.filters.BasicFilterShader;
	import net.morocoshi.moja3d.shaders.filters.EndFilterShader;
	import net.morocoshi.moja3d.shaders.filters.OutlineFilterShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	/**
	 * ...
	 * @author tencho
	 */
	public class OutlineFilter3D extends Filter3D 
	{
		private var shaderList:ShaderList;
		private var shader:OutlineFilterShader;
		
		public function OutlineFilter3D() 
		{
			super();
			
			hasMaskElement = true;
			shader = new OutlineFilterShader();
			shaderList = new ShaderList();
			shaderList.addShader(new BasicFilterShader());
			shaderList.addShader(shader);
			shaderList.addShader(new EndFilterShader());
		}
		
		public function addElement(mask:String, color:uint, alpha:Number):void
		{
			shader.addElement(mask, color, alpha);
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			manager.renderFinal(shaderList, 0, [manager.renderTexture, manager.maskTexture]);
		}
		
	}

}