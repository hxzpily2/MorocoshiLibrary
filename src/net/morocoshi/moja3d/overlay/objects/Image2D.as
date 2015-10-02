package net.morocoshi.moja3d.overlay.objects 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.overlay.SpriteImageShader;
	
	use namespace moja3d;
	
	/**
	 * テクスチャリソースを表示する矩形
	 * 
	 * @author tencho
	 */
	public class Image2D extends Plane2D 
	{
		private var _texture:TextureResource;
		private var imageShader:SpriteImageShader;
		private var _ignoreTransparency:Boolean;
		
		public function Image2D(texture:TextureResource, originX:Number = 0, originY:Number = 0)
		{
			var w:Number = texture is ImageTextureResource? ImageTextureResource(texture).width : 0;
			var h:Number = texture is ImageTextureResource? ImageTextureResource(texture).height : 0;
			super(w, h, originX, originY);
			
			_ignoreTransparency = false;
			_texture = texture;
			imageShader = new SpriteImageShader(_texture, _ignoreTransparency);
			_material.shaderList.addShader(imageShader);
		}
		
		public function get ignoreTransparency():Boolean 
		{
			return _ignoreTransparency;
		}
		
		public function set ignoreTransparency(value:Boolean):void 
		{
			imageShader.ignoreTransparency = _ignoreTransparency = value;
		}
		
		public function get texture():TextureResource 
		{
			return _texture;
		}
		
		public function set texture(value:TextureResource):void 
		{
			imageShader.texture = _texture = value;
		}
		
	}

}