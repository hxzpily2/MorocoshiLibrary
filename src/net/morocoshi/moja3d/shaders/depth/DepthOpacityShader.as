package net.morocoshi.moja3d.shaders.depth 
{
	import flash.display.BitmapDataChannel;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DepthOpacityShader extends MaterialShader 
	{
		public var opacityTexture:AGALTexture;
		private var _opacity:TextureResource;
		//private var thresholdConst:AGALConstant;
		private var _smoothing:String;
		private var _mipmap:String;
		private var _tiling:String;
		private var _colorChannel:int;
		
		public function DepthOpacityShader(opacity:TextureResource, colorChannel:int, smoothing:String = "linear", mipmap:String = "miplinear", tiling:String = "repeat") 
		{
			super();
			
			_opacity = opacity;
			_colorChannel = colorChannel;
			_smoothing = smoothing;
			_mipmap = mipmap;
			_tiling = tiling;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "DepthOpacityShader:" + _colorChannel + "_" + _smoothing + "_" + _mipmap + "_" + _tiling;
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = _opacity? AlphaMode.MIX : AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			opacityTexture = fragmentCode.addTexture("&opacityDepth", _opacity, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = getTextureTag(_smoothing, _mipmap, _tiling, opacityTexture.getSamplingOption());
			var rgba:String = { 1:"x", 2:"y", 4:"z", 8:"w" } [String(_colorChannel)];
			fragmentCode.addCode(
				"var $temp",
				"$temp.xyzw = tex(#uv.xy, &opacityDepth " + tag + ")",
				//_colorChannelで指定したチャンネルを透過情報として拾う
				"$alpha.x *= $temp." + rgba
			);
		}
		
		override public function clone():MaterialShader 
		{
			return new DepthOpacityShader(_opacity, _colorChannel, _smoothing, _mipmap, _tiling);
		}
		/*
		public function get alpha():Number 
		{
			return _alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			thresholdConst.x = _alpha = value;
		}
		*/
	}

}