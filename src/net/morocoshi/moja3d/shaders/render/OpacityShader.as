package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BitmapDataChannel;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.depth.DepthOpacityShader;
	
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
		private var texture:AGALTexture;
		
		public function OpacityShader(resource:TextureResource, mipmap:String = "miplinear", smoothing:String = "linear", tiling:String = "wrap")
		{
			super();
			
			requiredAttribute.push(VertexAttribute.UV);
			
			_mipmap = mipmap;
			_smoothing = smoothing;
			_tiling = tiling;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.resource = resource;
		}
		
		override public function getKey():String 
		{
			return "OpacityShader:" + _smoothing + "_" + _mipmap + "_" + _tiling + "_" + getSamplingKey(texture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.MIX;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			texture = fragmentCode.addTexture("&opacityMap", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = texture.getOption2D(_smoothing, _mipmap, _tiling);
			fragmentCode.addCode([
				"var $image",
				"$image = tex(#uv, &opacityMap " + tag + ")",
				"$output.w *= $image.x"
			]);
		}
		
		public function get resource():TextureResource 
		{
			return texture.texture;
		}
		
		public function set resource(value:TextureResource):void 
		{
			texture.texture = value;
		}
		
		override public function reference():MaterialShader 
		{
			return new OpacityShader(resource, _mipmap, _smoothing, _tiling);
		}
		
		override public function clone():MaterialShader 
		{
			return new OpacityShader(cloneTexture(resource), _mipmap, _smoothing, _tiling);
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.MASK)
			{
				return new OpacityShader(resource, _mipmap, _smoothing, _tiling);
			}
			if (phase == RenderPhase.DEPTH)
			{
				return new DepthOpacityShader(resource, BitmapDataChannel.RED, _smoothing, _mipmap, _tiling);
			}
			return null;
		}
		
	}

}