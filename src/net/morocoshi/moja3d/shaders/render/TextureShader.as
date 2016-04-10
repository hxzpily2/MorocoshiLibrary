package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BitmapDataChannel;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.depth.DepthOpacityShader;
	
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
		private var diffuseTexture:AGALTexture;
		private var opacityTexture:AGALTexture;
		private var shadowShader:DepthOpacityShader;
		
		public function TextureShader(diffuse:TextureResource, opacity:TextureResource = null, mipmap:String = "miplinear", smoothing:String = "linear", tiling:String = "wrap") 
		{
			super();
			
			if (diffuse != null && diffuse === opacity)
			{
				throw new Error("diffuseとopacityに同じリソースを指定する事はできません。");
			}
			
			requiredAttribute.push(VertexAttribute.UV);
			
			_mipmap = mipmap;
			_smoothing = smoothing;
			_tiling = tiling;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.diffuse = diffuse;
			this.opacity = opacity;
		}
		
		override public function getKey():String 
		{
			return "TextureShader:" + alphaTransform + "_" + _smoothing + "_" + _mipmap + "_" + _tiling + "_" + getSamplingKey(diffuseTexture) + "_" + Boolean(opacityTexture.texture) + "_" + getSamplingKey(opacityTexture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			
			alphaTransform = (opacity || diffuseTexture.hasAlpha())? AlphaTransform.SET_MIXTURE : AlphaTransform.SET_OPAQUE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			diffuseTexture = fragmentCode.addTexture("&diffuse", null, this);
			opacityTexture = fragmentCode.addTexture("&opacity", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var diffuseTag:String = diffuseTexture.getOption2D(_smoothing, _mipmap, _tiling);
			fragmentCode.addCode([
				"$output.xyzw = tex(#uv, &diffuse " + diffuseTag + ")"
			]);
			
			if (opacity)
			{
				var opacityTag:String = opacityTexture.getOption2D(_smoothing, _mipmap, _tiling);
				fragmentConstants.number = true;
				fragmentCode.addCode([
					"var $topacity",
					"$topacity.xyzw = tex(#uv, &opacity " + opacityTag + ")",
					"$output.w *= $topacity.x"//v0:opacity画像の赤成分をアルファに
				]);
				opacityTexture.enabled = true;
			}
			else
			{
				opacityTexture.enabled = false;
			}
		}
		
		public function get diffuse():TextureResource 
		{
			return diffuseTexture.texture;
		}
		
		public function set diffuse(value:TextureResource):void 
		{
			diffuseTexture.texture = value;
		}
		
		public function get opacity():TextureResource 
		{
			return opacityTexture.texture;
		}
		
		public function set opacity(value:TextureResource):void 
		{
			opacityTexture.texture = value;
			if (shadowShader) shadowShader.opacity = value;
			updateAlphaMode();
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
		
		override public function reference():MaterialShader 
		{
			return new TextureShader(diffuse, opacity, _mipmap, _smoothing, _tiling);
		}
		
		override public function clone():MaterialShader 
		{
			return new TextureShader(cloneTexture(diffuse), cloneTexture(opacity), _mipmap, _smoothing, _tiling);
		}
		
		override public function getExtraShader(phase:String):MaterialShader 
		{
			if (phase == RenderPhase.MASK)
			{
				return opacity? new OpacityShader(opacity, _mipmap, _smoothing, _tiling) : null;
			}
			if (phase == RenderPhase.SHADOW)
			{
				if (shadowShader == null)
				{
					if (opacity)
					{
						shadowShader = new DepthOpacityShader(opacity, BitmapDataChannel.RED, _smoothing, _mipmap, _tiling);
					}
					else if (diffuse)
					{
						shadowShader = new DepthOpacityShader(diffuse, BitmapDataChannel.ALPHA, _smoothing, _mipmap, _tiling);
					}
				}
				return shadowShader;
			}
			return null;
		}
		
	}

}