package net.morocoshi.moja3d.shaders.render 
{
	import flash.display.BitmapData;
	import net.morocoshi.moja3d.agal.AGALTexture;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Smoothing;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.shaders.AlphaMode;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ToonShader extends MaterialShader 
	{
		private var toonImage:BitmapData;
		private var toonResource:ImageTextureResource;
		private var toonTexture:AGALTexture;
		
		public function ToonShader() 
		{
			super();
			
			toonImage = new BitmapData(128, 128, false, 0x0);
			toonResource = new ImageTextureResource(toonImage);
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return super.getKey();
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaMode = AlphaMode.NONE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
			
			toonTexture = fragmentCode.addTexture("&toon", toonResource);
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var tag:String = getTextureTag(Smoothing.LINEAR, Mipmap.MIPLINEAR, Tiling.CLAMP, toonTexture.getSamplingOption());
			fragmentCode.addCode(
			);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:ToonShader = new ToonShader();
			return shader;
		}
		
	}

}