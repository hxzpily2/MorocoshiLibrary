package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	
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
	}

}