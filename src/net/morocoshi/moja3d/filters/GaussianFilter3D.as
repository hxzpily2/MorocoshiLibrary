package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.shaders.filters.BasicFilterShader;
	import net.morocoshi.moja3d.shaders.filters.EndFilterShader;
	import net.morocoshi.moja3d.shaders.filters.GaussianFilterShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class GaussianFilter3D extends Filter3D 
	{
		private var gaussianHShader:ShaderList;
		private var gaussianVShader:ShaderList;
		private var gaussianH:GaussianFilterShader;
		private var gaussianV:GaussianFilterShader;
		
		public function GaussianFilter3D(scale:Number, segments:int, dispersion:Number = 50) 
		{
			super();
			
			gaussianH = new GaussianFilterShader(true, scale, segments, dispersion);
			gaussianV = new GaussianFilterShader(false, scale, segments, dispersion);
			
			gaussianHShader = new ShaderList();
			gaussianHShader.addShader(new BasicFilterShader());
			gaussianHShader.addShader(gaussianH);
			gaussianHShader.addShader(new EndFilterShader());
			
			gaussianVShader = new ShaderList();
			gaussianVShader.addShader(new BasicFilterShader());
			gaussianVShader.addShader(gaussianV);
			gaussianVShader.addShader(new EndFilterShader());
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			manager.renderProcess(gaussianHShader);
			manager.renderFinal(gaussianVShader);
		}
		
		public function get scale():Number 
		{
			return gaussianH.scale;
		}
		
		public function set scale(value:Number):void 
		{
			gaussianH.scale = value;
			gaussianV.scale = value;
		}
		
		public function get dispersion():Number 
		{
			return gaussianH.dispersion;
		}
		
		public function set dispersion(value:Number):void 
		{
			gaussianH.dispersion = value;
			gaussianV.dispersion = value;
		}
		
		public function get segments():int 
		{
			return gaussianH.segments;
		}
		
		public function set segments(value:int):void 
		{
			gaussianH.segments = value;
			gaussianV.segments = value;
		}
		
	}

}