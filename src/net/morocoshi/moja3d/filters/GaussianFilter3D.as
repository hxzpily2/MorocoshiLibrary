package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.shaders.filters.GaussianFilterShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ぼかしフィルタ
	 * 
	 * @author tencho
	 */
	public class GaussianFilter3D extends Filter3D 
	{
		private var gaussianHShader:ShaderList;
		private var gaussianVShader:ShaderList;
		private var gaussianH:GaussianFilterShader;
		private var gaussianV:GaussianFilterShader;
		private var lowLV:int;
		
		public function GaussianFilter3D(scale:Number, segments:int, dispersion:Number = 50, lowLV:int = 0) 
		{
			super();
			
			this.lowLV = lowLV;
			gaussianH = new GaussianFilterShader(true, scale, segments, dispersion);
			gaussianV = new GaussianFilterShader(false, scale, segments, dispersion);
			
			gaussianHShader = createShaderList([gaussianH]);
			gaussianVShader = createShaderList([gaussianV]);
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			manager.renderProcess(gaussianHShader, lowLV, [null]);
			manager.renderFinal(gaussianVShader, lowLV);
		}
		
		public function get blur():Number 
		{
			return gaussianH.blur;
		}
		
		public function set blur(value:Number):void 
		{
			gaussianH.blur = value;
			gaussianV.blur = value;
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