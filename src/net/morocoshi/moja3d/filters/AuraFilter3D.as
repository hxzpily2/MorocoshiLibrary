package net.morocoshi.moja3d.filters 
{
	import flash.utils.getTimer;
	import net.morocoshi.moja3d.renderer.PostEffectManager;
	import net.morocoshi.moja3d.resources.RenderTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.filters.AuraFilterShader;
	import net.morocoshi.moja3d.shaders.filters.DrawMaskShader;
	import net.morocoshi.moja3d.shaders.filters.GaussianFilterShader;
	import net.morocoshi.moja3d.shaders.filters.MaskItem;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AuraFilter3D extends Filter3D 
	{
		private var _lowLV:int;
		private var _scrollU:Number;
		private var _scrollV:Number;
		
		private var gaussianHShader:GaussianFilterShader;
		private var gaussianVShader:GaussianFilterShader;
		private var drawMaskShader:DrawMaskShader;
		private var auraShader:AuraFilterShader;
		
		private var shaderList0:ShaderList;
		private var shaderList1:ShaderList;
		private var shaderList2:ShaderList;
		private var shaderList3:ShaderList;
		
		/**
		 * 
		 * @param	density			[0.0-]エフェクトの濃度
		 * @param	intensity		[0.0-]エフェクトの強度
		 * @param	blur			ぼかしサイズ
		 * @param	segments		ぼかしの分割数
		 * @param	dispersion		ガウシアン係数
		 * @param	lowLV			[0-4]ガウス処理のレンダリング品質の劣化度。0が最高品質。品質が低いほど高速になる。
		 * @param	noiseTexture	ノイズテクスチャ
		 * @param	noiseX			[0.0-1.0]ノイズのX軸方向の強度
		 * @param	noiseY			[0.0-1.0]ノイズのY軸方向の強度
		 * @param	noiseScale		ノイズのUVスケール
		 * @param	scrollU			ノイズのUスクロール速度
		 * @param	scrollV			ノイズのVスクロール速度
		 */
		public function AuraFilter3D(density:Number, intensity:Number, blur:Number, segments:int, dispersion:Number, lowLV:int, noiseTexture:TextureResource, noiseX:Number, noiseY:Number, noiseScale:Number, scrollU:Number, scrollV:Number) 
		{
			super();
			
			hasMaskElement = true;
			_lowLV = lowLV;
			_scrollU = scrollU;
			_scrollV = scrollV;
			
			drawMaskShader = new DrawMaskShader(0);
			gaussianHShader = new GaussianFilterShader(true, blur, segments, dispersion);
			gaussianVShader = new GaussianFilterShader(false, blur, segments, dispersion);
			auraShader = new AuraFilterShader(density, intensity, noiseTexture, noiseX, noiseY, noiseScale);
			
			shaderList0 = createShaderList([drawMaskShader]);
			shaderList1 = createShaderList([gaussianHShader]);
			shaderList2 = createShaderList([gaussianVShader]);
			shaderList3 = createShaderList([auraShader]);
		}
		
		public function addAuraColor(mask:uint, color:uint, density:Number):MaskItem
		{
			return drawMaskShader.addMask(mask, color, density);
		}
		
		public function removeAuraColor(mask:uint):void
		{
			drawMaskShader.removeMask(mask);
		}
		
		override public function render(manager:PostEffectManager):void 
		{
			var time:Number = getTimer() / 1000;
			auraShader.scrollU = time * _scrollU;
			auraShader.scrollV = time * _scrollV;
			var inputTexture:RenderTextureResource = manager.currentTexture;
			manager.renderProcess(shaderList0, _lowLV, [manager.maskTexture]);
			manager.renderProcess(shaderList1, _lowLV);
			manager.renderProcess(shaderList2, _lowLV);
			manager.renderFinal(shaderList3, 0, [inputTexture, null, manager.maskTexture]);
		}
		
		public function get blur():Number 
		{
			return gaussianHShader.scale;
		}
		
		public function set blur(value:Number):void 
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