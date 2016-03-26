package net.morocoshi.moja3d.shaders.render 
{
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class SkyBoxShader extends MaterialShader 
	{
		private var texture:AGALTexture;
		
		/**
		 * 
		 * @param	resource
		 */
		public function SkyBoxShader(resource:TextureResource) 
		{
			super();
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
			
			this.resource = resource;
		}
		
		override public function getKey():String 
		{
			return "SkyBoxShader:" + getSamplingKey(texture);
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = texture.hasAlpha()? AlphaMode.MIX : AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			texture = fragmentCode.addTexture("&skycube", null, this);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.cameraPosition = true;
			
			var tag:String = texture.getOptionCube(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP);
			fragmentCode.addCode([
				"var $eye",
				//視点からテクセルへのベクトル
				"$eye.xyz = #wpos.xzy - @cameraPosition.xzy",
				"$eye.xyz = nrm($eye.xyz)",
				
				"$output.xyzw = tex($eye.xyz, &skycube " + tag + ")"
			]);
			
		}
		
		override public function reference():MaterialShader 
		{
			return new SkyBoxShader(resource);
		}
		
		override public function clone():MaterialShader 
		{
			return new SkyBoxShader(cloneTexture(resource));
		}
		
		public function get resource():TextureResource 
		{
			return texture.texture;
		}
		
		public function set resource(value:TextureResource):void 
		{
			texture.texture = value;
		}
		
	}

}