package net.morocoshi.moja3d.agal 
{
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.moja3d;
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
		public var texture:TextureResource;
		public var enabled:Boolean;
		
		private var prevSamplingOption:String;
		private var linkedShader:MaterialShader;
		
		public function AGALTexture(id:String, texture:TextureResource) 
		{
			this.id = id;
			prevSamplingOption = "";
			setTexture(texture);
			enabled = true;
		}
		
		public function setTexture(texture:TextureResource):void
		{
			if (this.texture)
			{
				this.texture.removeEventListener(Event3D.RESOURCE_PARSED, resource_parsedHandler);
			}
			this.texture = texture;
			if (texture is ImageTextureResource)
			{
				if (ImageTextureResource(texture).isParsed)
				{
					changeResourceType(texture as ImageTextureResource);
				}
				else
				{
					texture.addEventListener(Event3D.RESOURCE_PARSED, resource_parsedHandler);
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
		
	}

}