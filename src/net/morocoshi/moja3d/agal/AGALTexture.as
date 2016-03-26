package net.morocoshi.moja3d.agal 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	use namespace moja3d;
	
	/**
	 * テクスチャリソースの管理
	 * 
	 * @author tencho
	 */
	public class AGALTexture 
	{
		public var id:String;
		public var enabled:Boolean;
		private var _texture:TextureResource;
		
		private var prevSamplingOption:String;
		private var linkedShader:MaterialShader;
		
		public function AGALTexture(id:String, texture:TextureResource) 
		{
			this.id = id;
			prevSamplingOption = "";
			this.texture = texture;
			enabled = true;
		}
		
		public function get texture():TextureResource
		{
			return _texture;
		}
		
		public function set texture(value:TextureResource):void
		{
			if (_texture)
			{
				_texture.removeEventListener(Event3D.RESOURCE_PARSED, resource_parsedHandler);
			}
			_texture = value;
			if (_texture is ImageTextureResource)
			{
				if (ImageTextureResource(_texture).isParsed)
				{
					changeResourceType(_texture as ImageTextureResource);
				}
				else
				{
					_texture.addEventListener(Event3D.RESOURCE_PARSED, resource_parsedHandler);
				}
			}
		}
		
		private function resource_parsedHandler(e:Event3D):void 
		{
			changeResourceType(e.currentTarget as ImageTextureResource);
		}
		
		private function changeResourceType(resource:ImageTextureResource):void 
		{
			var current:String = resource.getSamplingOption();
			if (prevSamplingOption != current)
			{
				prevSamplingOption = current;
				if (linkedShader)
				{
					linkedShader.updateTextureShaderCode();
				}
			}
		}
		
		public function clone():AGALTexture 
		{
			var cloned:AGALTexture = new AGALTexture(id, texture);
			cloned.enabled = enabled;
			return cloned;
		}
		
		public function getSamplingOption():String 
		{
			return texture ? texture.getSamplingOption() : "";
		}
		
		public function linkShader(shader:MaterialShader):void 
		{
			linkedShader = shader;
		}
		
		public function hasAlpha():Boolean 
		{
			if (_texture == null) return false;
			if (_texture is ImageTextureResource)
			{
				return ImageTextureResource(_texture).hasAlpha;
			}
			return false;
		}
		
		/**
		 * テクスチャサンプリングコード＜cube～＞の生成
		 * @param	smoothing
		 * @param	mipmap
		 * @param	tiling
		 * @return
		 */
		public function getOptionCube(smoothing:String, mipmap:String, tiling:String):String 
		{
			var option:String = getSamplingOption();
			if (option) option = ", " + option;
			return "<cube, " + smoothing + ", " + mipmap + ", " + tiling + option + ">";
		}
		
		/**
		 * テクスチャサンプリングコード＜2d～＞の生成
		 * @param	smoothing
		 * @param	mipmap
		 * @param	tiling
		 * @return
		 */
		public function getOption2D(smoothing:String, mipmap:String, tiling:String):String 
		{
			var option:String = getSamplingOption();
			if (option) option = ", " + option;
			return "<2d, " + mipmap + ", " + smoothing + ", " + tiling + option + ">";
		}
		
		/**
		 * テクスチャサンプリングコード＜2d～＞の生成
		 * @param	smoothing
		 * @param	mipmap
		 * @param	tiling
		 * @return
		 */
		static public function getTextureOption2D(smoothing:String, mipmap:String, tiling:String):String 
		{
			return "<2d, " + mipmap + ", " + smoothing + ", " + tiling + ">";
		}
		
	}

}