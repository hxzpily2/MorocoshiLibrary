package net.morocoshi.moja3d.shaders.overlay 
{
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * 2Dレイヤー用画像表示シェーダー
	 * 
	 * @author tencho
	 */
	public class SpriteImageShader extends MaterialShader 
	{
		private var texture:AGALTexture;
		private var _ignoreTransparency:Boolean;
		
		/**
		 * 
		 * @param	texture
		 * @param	ignoreTransparency
		 */
		public function SpriteImageShader(resource:TextureResource, ignoreTransparency:Boolean) 
		{
			super();
			
			_ignoreTransparency = ignoreTransparency;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.resource = resource;
		}
		
		override public function getKey():String 
		{
			return "SpriteImageShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.SET_OPAQUE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			texture = fragmentCode.addTexture("&diffuse", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			var tag:String = texture.getOption2D(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP);
			
			if (_ignoreTransparency)
			{
				fragmentConstants.number = true;
				fragmentCode.addCode([
					"$output.xyz = tex(#uv, &diffuse " + tag + ")",
					"$output.w = @1"
				]);
			}
			else
			{
				fragmentConstants.number = true;
				fragmentCode.addCode([
					"$output.xyzw = tex(#uv, &diffuse " + tag + ")"
				]);
			}
			
		}
		
		override public function reference():MaterialShader 
		{
			var shader:SpriteImageShader = new SpriteImageShader(resource, _ignoreTransparency);
			return shader;
		}
		
		override public function clone():MaterialShader 
		{
			var shader:SpriteImageShader = new SpriteImageShader(cloneTexture(resource), _ignoreTransparency);
			return shader;
		}
		
		public function get resource():TextureResource 
		{
			return texture.texture;
		}
		
		public function set resource(value:TextureResource):void 
		{
			texture.texture = value;
		}
		
		public function get ignoreTransparency():Boolean 
		{
			return _ignoreTransparency;
		}
		
		public function set ignoreTransparency(value:Boolean):void 
		{
			if (_ignoreTransparency == value) return;
			
			_ignoreTransparency = value;
			updateShaderCode();
		}
		
	}

}