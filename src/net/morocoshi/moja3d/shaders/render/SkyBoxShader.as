package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.CubeTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class SkyBoxShader extends MaterialShader 
	{
		private var _resource:TextureResource;
		private var texture:AGALTexture;
		
		/**
		 * 
		 * @param	resouce
		 * @param	reflection
		 * @param	blendMode
		 */
		public function SkyBoxShader(resource:TextureResource) 
		{
			super();
			
			_resource = resource;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "SkyBoxShader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			texture = fragmentCode.addTexture("&cube", _resource);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			fragmentConstants.cameraPosition = true;
			
			var tag:String = getCubeTextureTag(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP, _resource.getSamplingOption());
			fragmentCode.addCode(
				"var $eye",
				//視点からテクセルへのベクトル
				"$eye.xyz = #wpos.xzy - @cameraPosition.xzy",
				"$eye.xyz = nrm($eye.xyz)",
				
				"$output.xyzw = tex($eye.xyz, &cube " + tag + ")"
			);
			
		}
		
		override public function clone():MaterialShader 
		{
			var diffuse:TextureResource = _resource? _resource.clone() as TextureResource : null;
			var shader:SkyBoxShader = new SkyBoxShader(diffuse);
			return shader;
		}
		
		public function get resource():TextureResource 
		{
			return _resource;
		}
		
		public function set resource(value:TextureResource):void 
		{
			_resource = value;
			if (texture)
			{
				texture.texture = _resource;
			}
		}
		
	}

}