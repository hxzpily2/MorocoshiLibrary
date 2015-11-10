package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.shaders.filters.BasicFilterShader;
	import net.morocoshi.moja3d.shaders.filters.EndFilterShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Filter3D 
	{
		public var enabled:Boolean;
		public var hasMaskElement:Boolean;
		public function Filter3D() 
		{
			enabled = true;
			hasMaskElement = false;
		}
		
		public function render(manager:PostEffectManager):void
		{
		}
		
		protected function createShaderList(shaders:Array):ShaderList
		{
			var result:ShaderList = new ShaderList();
			
			result.addShader(new BasicFilterShader());
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.addShader(shaders[i]);
			}
			result.addShader(new EndFilterShader());
			
			return result;
		}
	}

}