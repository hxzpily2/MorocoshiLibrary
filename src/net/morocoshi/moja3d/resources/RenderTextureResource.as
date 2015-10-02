package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class RenderTextureResource extends TextureResource 
	{
		
		public function RenderTextureResource() 
		{
			super();
			isReady = true;
		}
		
		//レンダリング用テクスチャの場合
		override public function createTexture(context3D:Context3D, width:int, height:int):void 
		{
			//サイズ修正
			var notPow2:Boolean = !TextureUtil.checkPow2(width, height);
			if (notPow2)
			{
				width = TextureUtil.toPow2(width);
				height = TextureUtil.toPow2(height);
				notPow2 = false;
			}
			
			//前回と同じならスキップ
			if (prevSize.x == width && prevSize.y == height)
			{
				return;
			}
			
			prevSize.x = width;
			prevSize.y = height;
			
			if (texture)
			{
				texture.dispose();
			}
			
			texture = context3D.createTexture(width, height, Context3DTextureFormat.BGRA, true);
			
			//2の累乗に直す場合
			//texture = context3D.createTexture(toPow(width), toPow(height), format, renderToTexture);
			//RectangleTextureを使った場合
			//texture = context3D.createRectangleTexture(width, height, format, renderToTexture);
		}
		
		override public function upload(context3D:Context3D, async:Boolean, complete:Function = null):void 
		{
		}
		
		override public function clone():Resource 
		{
			return new RenderTextureResource();
		}
		
	}

}