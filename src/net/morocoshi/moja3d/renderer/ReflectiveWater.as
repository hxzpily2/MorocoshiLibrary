package net.morocoshi.moja3d.renderer 
{
	import flash.display3D.Context3D;
	import flash.geom.Rectangle;
	import net.morocoshi.moja3d.resources.RenderTextureResource;
	import net.morocoshi.moja3d.shaders.render.KillShader;
	import net.morocoshi.moja3d.shaders.render.ReflectionShader;
	
	/**
	 * 鏡面反射用テクスチャを管理
	 * 
	 * @author tencho
	 */
	public class ReflectiveWater 
	{
		public var killShader:KillShader;
		public var hasReflectElement:Boolean;
		/**生成済みのVector.＜RenderTextureResource＞の集合*/
		public var textureResources:Vector.<RenderTextureResource>;
		/**水面の高さがキーになったVector.＜RenderTextureResource＞の集合*/
		public var agalTextures:Object;
		
		private var reflectionIndex:int = -1;
		private var size:Rectangle;
		private var context3D:Context3D;
		
		public function ReflectiveWater() 
		{
			hasReflectElement = false;
			killShader = new KillShader();
			textureResources = new Vector.<RenderTextureResource>;
			size = new Rectangle(0, 0, 2, 2);
		}
		
		public function setContext3D(context3D:Context3D):void
		{
			this.context3D = context3D;
		}
		
		public function setSize(w:int, h:int):void
		{
			size.width = w;
			size.height = h;
			var n:int = textureResources.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:RenderTextureResource = textureResources[i];
				item.createTexture(context3D, w, h);
			}
		}
		
		public function clear():void 
		{
			reflectionIndex = -1;
			agalTextures = { };
			hasReflectElement = false;
		}
		
		public function addReflectElement(z:Number, reflectiveShader:ReflectionShader):RenderTextureResource 
		{
			hasReflectElement = true;
			if (!agalTextures[z])
			{
				reflectionIndex++;
				agalTextures[z] = getResource(reflectionIndex);
			}
			return agalTextures[z];
		}
		
		/**
		 * インデックス指定で反射用TextureResourceを取得する。まだ生成されていないインデックスがあれば生成される。一度生成したTextureResourceはキャッシュされ続けるのでメモリに注意。
		 * @param	index
		 * @param	context3D
		 * @return
		 */
		private function getResource(index:int):RenderTextureResource 
		{
			if (textureResources.length <= index)
			{
				var resource:RenderTextureResource = textureResources[index] = new RenderTextureResource();
				resource.autoDispose = false;
				resource.createTexture(context3D, size.width, size.height);
			}
			return textureResources[index];
		}
		
	}

}