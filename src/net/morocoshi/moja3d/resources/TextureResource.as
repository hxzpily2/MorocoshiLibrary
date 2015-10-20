package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Point;
	
	/**
	 * テクスチャリソース基本
	 * 
	 * @author tencho
	 */
	public class TextureResource extends Resource
	{
		/***/
		protected var prevSize:Point;
		/***/
		public var texture:TextureBase;
		
		public function TextureResource() 
		{
			super();
			prevSize = new Point( -1, -1);
			autoDispose = true;
		}
		
		public function getSamplingOption():String
		{
			return "";
		}
		
		/**
		 * Context3Dにアップロード
		 * @param	context3D
		 * @param	async
		 * @param	complete
		 */
		override public function upload(context3D:Context3D, async:Boolean = false, complete:Function = null):void 
		{
			throw new Error("継承してください！");
		}
		
		/**
		 * 指定サイズのテクスチャを生成
		 * @param	context3D
		 * @param	width
		 * @param	height
		 */
		public function createTexture(context3D:Context3D, width:int, height:int):void 
		{
			throw new Error("継承してください！");
		}
		
		override public function dispose():void 
		{
			super.dispose();
			prevSize.setTo( -1, -1);
			if (texture)
			{
				texture.dispose();
			}
			texture = null;
		}
		
		override public function clone():Resource 
		{
			var result:TextureResource = new TextureResource();
			return result;
		}
		
	}

}