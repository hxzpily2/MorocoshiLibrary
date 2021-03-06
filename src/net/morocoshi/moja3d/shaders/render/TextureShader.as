package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BitmapDataChannel;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.atlas.TextureAtlasController;
	import net.morocoshi.moja3d.atlas.TextureAtlasItem;
	import net.morocoshi.moja3d.renderer.RenderPhase;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
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
		private var _diffuseAtlas:TextureAtlasController;
		private var _opacityAtlas:TextureAtlasController;
		
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
			
			var atlasResource:TextureAtlasResource;
			var item:TextureAtlasItem;
			var w:Number;
			var h:Number;
			var frame:int;
			var maxFrame:int
			
			atlasResource = diffuseTexture.texture as TextureAtlasResource;
			if (atlasResource)
			{
				frame = _diffuseAtlas.getFrame();
				if (_diffuseAtlas.loop != 0)
				{
					maxFrame = atlasResource.numFrames * _diffuseAtlas.loop - 1;
					if (frame > maxFrame)
					{
						frame = maxFrame;
						_diffuseAtlas.stop();
					}
				}
				diffuseTexture.frame = frame;
				item = atlasResource.items[diffuseTexture.frame % atlasResource.numFrames];
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
			
			atlasResource = opacityTexture.texture as TextureAtlasResource;
			if (atlasResource)
			{
				opacityTexture.frame = _opacityAtlas.getFrame();
				if (_opacityAtlas.loop != 0)
				{
					maxFrame = atlasResource.numFrames * _opacityAtlas.loop - 1;
					if (frame > maxFrame)
					{
						frame = maxFrame;
						_opacityAtlas.stop();
					}
				}
				item = atlasResource.items[opacityTexture.frame % atlasResource.numFrames];
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
			updateTickEnabled();
			
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		private function updateTickEnabled():void 
		{
			var t1:TextureAtlasResource = diffuseTexture.texture as TextureAtlasResource;
			var t2:TextureAtlasResource = opacityTexture.texture as TextureAtlasResource;
			tickEnabled = (t1 && t1.numFrames > 1) || (t2 && t2.numFrames > 1);
			if (t1 && _diffuseAtlas == null)
			{
				_diffuseAtlas = new TextureAtlasController();
			}
			if (t2 && _opacityAtlas == null)
			{
				_opacityAtlas = new TextureAtlasController();
			}
		}
		
		public function get opacity():TextureResource 
		{
			return opacityTexture.texture;
		}
		
		public function set opacity(value:TextureResource):void 
		{
			opacityTexture.texture = value;
			if (shadowShader) shadowShader.opacity = value;
			updateTickEnabled();
			
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
		
		public function get diffuseAtlas():TextureAtlasController 
		{
			return _diffuseAtlas || (_diffuseAtlas = new TextureAtlasController());
		}
		
		public function get opacityAtlas():TextureAtlasController 
		{
			return _opacityAtlas || (_opacityAtlas = new TextureAtlasController());
		}
		
		override public function reference():MaterialShader 
		{
			var shader:TextureShader = new TextureShader(diffuse, opacity, _mipmap, _smoothing, _tiling);
			return shader;
		}
		
		override public function clone():MaterialShader 
		{
			var shader:TextureShader = new TextureShader(cloneTexture(diffuse), cloneTexture(opacity), _mipmap, _smoothing, _tiling);
			return shader;
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