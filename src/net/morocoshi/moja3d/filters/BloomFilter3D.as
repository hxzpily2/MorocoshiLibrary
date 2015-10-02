package net.morocoshi.moja3d.filters 
{
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.filters.AddFilterShader;
	import net.morocoshi.moja3d.shaders.filters.BasicFilterShader;
	import net.morocoshi.moja3d.shaders.filters.EndFilterShader;
	import net.morocoshi.moja3d.shaders.filters.GaussianFilterShader;
	import net.morocoshi.moja3d.shaders.filters.LuminanceExtractorFilterShader;
	import net.morocoshi.moja3d.shaders.ShaderList;
	/**
	 * ...
	 * @author tencho
	 */
	public class BloomFilter3D extends Filter3D 
	{
		private var shaderList0:ShaderList;
		private var shaderList1:ShaderList;
		private var shaderList2:ShaderList;
		private var shaderList3:ShaderList;
		private var _blur:int;
		private var _dispersion:Number;
		private var _scale:Number;
		
		private var luminanceShader:LuminanceExtractorFilterShader;
		private var gaussianHShader:GaussianFilterShader;
		private var gaussianVShader:GaussianFilterShader;
		
		/**
		 * 
		 * @param	min	[0-1]輝度の最小値
		 * @param	max	[0-1]輝度の最大値
		 * @param	alpha	[0-1]ブルームエフェクトを重ねる度合
		 * @param	scale
		 * @param	segments	ぼかしの分割数
		 * @param	dispersion	ガウシアン係数
		 */
		public function BloomFilter3D(min:Number, max:Number, alpha:Number, scale:Number, segments:int, dispersion:Number = 50) 
		{
			super();
			
			luminanceShader = new LuminanceExtractorFilterShader(min, max);
			gaussianHShader = new GaussianFilterShader(true, scale, segments, dispersion);
			gaussianVShader = new GaussianFilterShader(false, scale, segments, dispersion);
			
			shaderList0 = new ShaderList();
			shaderList0.addShader(new BasicFilterShader());
			shaderList0.addShader(luminanceShader);
			shaderList0.addShader(new EndFilterShader());
			
			shaderList1 = new ShaderList();
			shaderList1.addShader(new BasicFilterShader());
			shaderList1.addShader(gaussianHShader);
			shaderList1.addShader(new EndFilterShader());
			
			shaderList2 = new ShaderList();
			shaderList2.addShader(new BasicFilterShader());
			shaderList2.addShader(gaussianVShader);
			shaderList2.addShader(new EndFilterShader());
			
			shaderList3 = new ShaderList();
			shaderList3.addShader(new BasicFilterShader());
			shaderList3.addShader(new AddFilterShader(alpha));
			shaderList3.addShader(new EndFilterShader());
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			manager.renderProcess(shaderList0, 2);
			manager.renderProcess(shaderList1, 2);
			var blurTexture:TextureResource = manager.renderProcess(shaderList2, 2);
			manager.renderFinal(shaderList3, 0, [manager.renderTexture, blurTexture]);
		}
		
		public function get min():Number 
		{
			return luminanceShader.min;
		}
		
		public function set min(value:Number):void 
		{
			luminanceShader.min = value;
		}
		
		public function get max():Number
		{
			return luminanceShader.max;
		}
		
		public function set max(value:Number):void 
		{
			luminanceShader.max = value;
		}
		
		public function get scale():Number 
		{
			return gaussianHShader.scale;
		}
		
		public function set scale(value:Number):void 
		{
			gaussianHShader.scale = value;
			gaussianVShader.scale = value;
		}
		
		public function get dispersion():Number 
		{
			return gaussianHShader.dispersion;
		}
		
		public function set dispersion(value:Number):void 
		{
			gaussianHShader.dispersion = value;
			gaussianVShader.dispersion = value;
		}
		
		public function get segments():int 
		{
			return gaussianHShader.segments;
		}
		
		public function set segments(value:int):void 
		{
			gaussianHShader.segments = value;
			gaussianVShader.segments = value;
		}
		
	}

}