package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BitmapDataChannel;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.depth.DepthOpacityShader;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * テクスチャ
	 * 
	 * @author tencho
	 */
	public class TextureShader extends MaterialShader 
	{
		private var _mipmap:String;
		private var _smoothing:String;
		private var _tiling:String;
		private var _diffuse:TextureResource;
		private var _opacity:TextureResource;
		
		private var diffuseTexture:AGALTexture;
		private var opacityTexture:AGALTexture;
		private var depthShader:DepthOpacityShader;
		
		public function TextureShader(diffuse:TextureResource, opacity:TextureResource, mipmap:String = Mipmap.MIPLINEAR, smoothing:String = Smoothing.LINEAR, tiling:String = Tiling.WRAP) 
		{
			super();
			
			requiredAttribute.push(VertexAttribute.UV);
			
			if (diffuse != null && diffuse === opacity)
			{
				throw new Error("diffuseとopacityに同じリソースを指定する事はできません。");
			}
			
			this.diffuse = diffuse;
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
			return "TextureShader:" + alphaMode + "_" + _smoothing + "_" + _mipmap + "_" + _tiling + "_" + getSamplingKey(diffuseTexture) + "_" + Boolean(_opacity) + "_" + getSamplingKey(opacityTexture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			
			var compressedAlpha:Boolean = diffuseTexture && diffuseTexture.texture && ImageTextureResource(diffuseTexture.texture).hasAlpha;
			alphaMode = (_opacity || compressedAlpha)? AlphaMode.MIX : AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			diffuseTexture = fragmentCode.addTexture("&diffuse", _diffuse, this);
			opacityTexture = _opacity? fragmentCode.addTexture("&opacity", _opacity, this) : null;
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var diffuseTag:String = getTextureTag(_smoothing, _mipmap, _tiling, diffuseTexture.getSamplingOption());
			fragmentCode.addCode(
				"$output.xyzw = tex(#uv, &diffuse " + diffuseTag + ")"
			);
			
			if (_opacity)
			{
				var opacityTag:String = getTextureTag(_smoothing, _mipmap, _tiling, opacityTexture.getSamplingOption());
				fragmentConstants.number = true;
				fragmentCode.addCode(
					"var $topacity",
					"$topacity.xyzw = tex(#uv, &opacity " + opacityTag + ")",
					"$output.w *= $topacity.x"//v0:opacity画像の赤成分をアルファに
				);
			}
		}
		
		public function get diffuse():TextureResource 
		{
			return _diffuse;
		}
		
		public function set diffuse(value:TextureResource):void 
		{
			//関連付けられていたパースイベントを解除しておく
			if (_diffuse) _diffuse.removeEventListener(Event3D.RESOURCE_PARSED, image_parsedHandler);
			
			//テクスチャリソースの差し替え
			_diffuse = value;
			if (diffuseTexture)　diffuseTexture.texture = _diffuse;
			
			//新しいパースイベントを関連付ける
			if (_diffuse)　_diffuse.addEventListener(Event3D.RESOURCE_PARSED, image_parsedHandler);
			
			updateAlphaMode();
		}
		
		private function image_parsedHandler(e:Event3D):void 
		{
			updateAlphaMode();
		}
		
		public function get opacity():TextureResource 
		{
			return _opacity;
		}
		
		public function set opacity(value:TextureResource):void 
		{
			opacityTexture.texture = _opacity = value;
			depthShader.opacityTexture.texture = _opacity;
			
			updateAlphaMode();
			updateTexture();
			updateShaderCode();
		}
		
		public function get mipmap():String 
		{
			return _mipmap;
		}
		
		public function set mipmap(value:String):void 
		{
			if (_mipmap == value) return;
			
			_mipmap = value;
			updateShaderCode();
		}
		
		public function get smoothing():String 
		{
			return _smoothing;
		}
		
		public function set smoothing(value:String):void 
		{
			if (_smoothing == value) return;
			
			_smoothing = value;
			updateShaderCode();
		}
		
		public function get tiling():String 
		{
			return _tiling;
		}
		
		public function set tiling(value:String):void 
		{
			if (_tiling == value) return;
			
			_tiling = value;
			updateShaderCode();
		}
		
		override public function clone():MaterialShader 
		{
			var shader:TextureShader = new TextureShader(_diffuse, _opacity, _mipmap, _smoothing, _tiling);
			return shader;
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.MASK)
			{
				return _opacity? new OpacityShader(_opacity, _mipmap, _smoothing, _tiling) : null;
			}
			if (phase == RenderPhase.DEPTH)
			{
				if (depthShader == null)
				{
					if (_opacity)
					{
						depthShader = new DepthOpacityShader(_opacity, BitmapDataChannel.RED, _smoothing, _mipmap, _tiling);
					}
					else if (_diffuse)
					{
						depthShader = new DepthOpacityShader(_diffuse, BitmapDataChannel.ALPHA, _smoothing, _mipmap, _tiling);
					}
				}
				return depthShader;
			}
			return null;
		}
		
	}

}