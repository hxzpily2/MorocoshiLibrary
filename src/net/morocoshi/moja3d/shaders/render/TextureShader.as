package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BitmapDataChannel;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.TextureAtlasItem;
	import net.morocoshi.moja3d.resources.TextureAtlasResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.shaders.depth.DepthOpacityShader;
	
	use namespace moja3d;
	
	/**
	 * テクスチャを表示する
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
		private var atlasDiffuseConstant:AGALConstant;
		private var atlasOpacityConstant:AGALConstant;
		
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
			
			var atlas:TextureAtlasResource;
			var item:TextureAtlasItem;
			
			atlas = diffuseTexture.texture as TextureAtlasResource;
			if (atlas)
			{
				atlasDiffuseConstant = vertexCode.addConstantsFromArray("@atlasDiffuse", [0, 0, 1, 1]);
				item = atlas.numFrames == 0? null : atlas.items[diffuseTexture.frame % atlas.numFrames];
				if (item)
				{
					atlasDiffuseConstant.x = item.x / ImageTextureResource(item.resource).width;
					atlasDiffuseConstant.y = item.y / ImageTextureResource(item.resource).height;
					atlasDiffuseConstant.z = item.width / ImageTextureResource(item.resource).width;
					atlasDiffuseConstant.w = item.height / ImageTextureResource(item.resource).height;
				}
			}
			
			atlas = opacityTexture.texture as TextureAtlasResource;
			if (atlas)
			{
				atlasOpacityConstant = vertexCode.addConstantsFromArray("@atlasOpacity", [0, 0, 1, 1]);
				
				item = atlas.numFrames == 0? null : atlas.items[diffuseTexture.frame % atlas.numFrames];
				if (item)
				{
					atlasOpacityConstant.x = item.x / ImageTextureResource(item.resource).width;
					atlasOpacityConstant.y = item.y / ImageTextureResource(item.resource).height;
					atlasOpacityConstant.z = item.width / ImageTextureResource(item.resource).width;
					atlasOpacityConstant.w = item.height / ImageTextureResource(item.resource).height;
				}
			}
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			if (diffuseTexture.texture is TextureAtlasResource)
			{
				vertexCode.addCode([
					"$uv.xy *= @atlasDiffuse.zw",
					"$uv.xy += @atlasDiffuse.xy"
				]);
			}
			var diffuseTag:String = diffuseTexture.getOption2D(_smoothing, _mipmap, _tiling);
			fragmentCode.addCode([
				"$output.xyzw = tex(#uv.xy, &diffuse " + diffuseTag + ")"
			]);
			
			if (opacity)
			{
				if (opacityTexture.texture is TextureAtlasResource)
				{
					vertexCode.addCode([
						"$uv.z *= @atlasOpacity.z",
						"$uv.w *= @atlasOpacity.w",
						"$uv.z += @atlasOpacity.x",
						"$uv.w += @atlasOpacity.y"
					]);
				}
				var opacityTag:String = opacityTexture.getOption2D(_smoothing, _mipmap, _tiling);
				fragmentConstants.number = true;
				fragmentCode.addCode([
					"var $topacity",
					"$topacity.xyz = tex(#uv.zw, &opacity " + opacityTag + ")",
					"$output.w *= $topacity.x"//v0:opacity画像の赤成分をアルファに
				]);
				opacityTexture.enabled = true;
			}
			else
			{
				opacityTexture.enabled = false;
			}
		}
		
		override public function tick(time:int):void 
		{
			super.tick(time);
			
			var atlas:TextureAtlasResource;
			var item:TextureAtlasItem;
			var w:Number;
			var h:Number;
			
			diffuseTexture.frame = time / 1000 * 6;
			opacityTexture.frame = time / 1000 * 6;
			
			atlas = diffuseTexture.texture as TextureAtlasResource;
			if (atlas)
			{
				item = atlas.items[diffuseTexture.frame % atlas.numFrames];
				w = ImageTextureResource(item.resource).width;
				h = ImageTextureResource(item.resource).height;
				if (atlasDiffuseConstant)
				{
					atlasDiffuseConstant.x = item.x / w;
					atlasDiffuseConstant.y = item.y / h;
					atlasDiffuseConstant.z = item.width / w;
					atlasDiffuseConstant.w = item.height / h;
				}
			}
			
			atlas = opacityTexture.texture as TextureAtlasResource;
			if (atlas)
			{
				item = atlas.items[opacityTexture.frame % atlas.numFrames];
				w = ImageTextureResource(item.resource).width;
				h = ImageTextureResource(item.resource).height;
				if (atlasOpacityConstant)
				{
					atlasOpacityConstant.x = item.x / w;
					atlasOpacityConstant.y = item.y / h;
					atlasOpacityConstant.z = item.width / w;
					atlasOpacityConstant.w = item.height / h;
				}
			}
		}
		
		public function get diffuse():TextureResource 
		{
			return diffuseTexture.texture;
		}
		
		public function set diffuse(value:TextureResource):void 
		{
			diffuseTexture.texture = value;
			tickEnabled = (value is TextureAtlasResource && TextureAtlasResource(value).numFrames > 1);
			updateConstants();
			updateShaderCode();
		}
		
		public function get opacity():TextureResource 
		{
			return opacityTexture.texture;
		}
		
		public function set opacity(value:TextureResource):void 
		{
			opacityTexture.texture = value;
			tickEnabled = (value is TextureAtlasResource && TextureAtlasResource(value).numFrames > 1);
			if (shadowShader) shadowShader.opacity = value;
			updateAlphaMode();
			updateConstants();
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