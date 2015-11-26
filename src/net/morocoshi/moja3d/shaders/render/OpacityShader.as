package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BitmapDataChannel;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.depth.DepthOpacityShader;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 不透明度テクスチャ
	 * 
	 * @author tencho
	 */
	public class OpacityShader extends MaterialShader 
	{
		private var _mipmap:String;
		private var _smoothing:String;
		private var _tiling:String;
		private var _opacity:TextureResource;
		
		private var opacityTexture:AGALTexture;
		
		public function OpacityShader(opacity:TextureResource, mipmap:String = "miplinear", smoothing:String = "linear", tiling:String = "wrap")
		{
			super();
			
			requiredAttribute.push(VertexAttribute.UV);
			
			_opacity = opacity;
			_mipmap = mipmap;
			_smoothing = smoothing;
			_tiling = tiling;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "OpacityShader:" + _smoothing + "_" + _mipmap + "_" + _tiling + "_" + getSamplingKey(opacityTexture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.MIX;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			opacityTexture = fragmentCode.addTexture("&opacityMap", _opacity, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = getTextureTag(_smoothing, _mipmap, _tiling, opacityTexture.getSamplingOption());
			fragmentCode.addCode([
				"var $image",
				"$image = tex(#uv, &opacityMap " + tag + ")",
				"$output.w *= $image.x"
			]);
		}
		
		override public function reference():MaterialShader 
		{
			return new OpacityShader(_opacity, _mipmap, _smoothing, _tiling);
		}
		
		override public function clone():MaterialShader 
		{
			return new OpacityShader(cloneTexture(_opacity), _mipmap, _smoothing, _tiling);
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.MASK)
			{
				return new OpacityShader(_opacity, _mipmap, _smoothing, _tiling);
			}
			if (phase == RenderPhase.DEPTH)
			{
				return new DepthOpacityShader(_opacity, BitmapDataChannel.RED, _smoothing, _mipmap, _tiling);
			}
			return null;
		}
		
	}

}