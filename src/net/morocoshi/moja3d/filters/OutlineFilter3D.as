package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.shaders.filters.OutlineFilterShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * マスクが設定されたオブジェクトにアウトラインをつける
	 * 
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
			shaderList = createShaderList([shader]);
		}
		
		public function addElement(mask:uint, color:uint, alpha:Number):void
		{
			shader.addElement(mask, color, alpha);
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			manager.renderFinal(shaderList, 0, [null, manager.maskTexture]);
		}
		
	}

}