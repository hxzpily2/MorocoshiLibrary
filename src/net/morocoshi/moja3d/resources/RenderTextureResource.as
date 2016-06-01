package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3DTextureFormat;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class RenderTextureResource extends TextureResource 
	{
		private var _lowLV:int;
		public var limitW:int;
		public var limitH:int;
		
		public function RenderTextureResource(limitW:int = 1024, limitH:int = 1024, lowLV:int = 0, name:String = "") 
		{
			super();
			_lowLV = lowLV;
			this.name = name;
			this.limitW = limitW;
			this.limitH = limitH;
			isReady = true;
		}
		
		public function fillColor(context3D:ContextProxy, rgb:uint, alpha:Number = 1):void
		{
			context3D.context.setRenderToTexture(texture, true, 0);
			context3D.context.clear((rgb >> 16 & 0xff) / 0xff, (rgb >> 8 & 0xff) / 0xff, (rgb & 0xff) / 0xff, alpha);
			isUploaded = true;
		}
		
		/**
		 * 制限サイズ、2の累乗などの条件を全て無視してテクスチャを生成する
		 * @param	context3D
		 * @param	width	なるべく2の累乗(FP11.8以降ならRectangleTextureが使える)
		 * @param	height	なるべく2の累乗(FP11.8以降ならRectangleTextureが使える)
		 */
		public function createTextureForce(context3D:ContextProxy, width:int, height:int):void 
		{
			if (uploadEnabled == false) return;
			if (prevSize.x == width && prevSize.y == height) return;
			
			prevSize.x = width;
			prevSize.y = height;
			
			if (texture) texture.dispose();
			
			if (TextureUtil.checkPow2(width, height))
			{
				texture = context3D.context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
			}
			else
			{
				texture = context3D.context["createRectangleTexture"](width, height, Context3DTextureFormat.BGRA, true);
			}
		}
		
		//レンダリング用テクスチャの場合
		override public function createTexture(context3D:ContextProxy, width:int, height:int):void 
		{
			if (uploadEnabled == false) return;
			
			if (width > limitW) width = limitW;
			if (height > limitH) height = limitH;
			
			//サイズ修正(2の累乗に直す)
			var notPow2:Boolean = !TextureUtil.checkPow2(width, height);
			if (notPow2)
			{
				width = TextureUtil.toPow2(width);
				height = TextureUtil.toPow2(height);
				notPow2 = false;
			}
			
			width = width >> _lowLV;
			height = height >> _lowLV;
			
			//前回と同じならスキップ
			if (width == 0 || height == 0 || prevSize.x == width && prevSize.y == height) return;
			
			prevSize.x = width;
			prevSize.y = height;
			
			if (texture) texture.dispose();
			
			texture = context3D.context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
			context3D.addUploadItem(this);
			
			//RectangleTextureを使った場合
			//texture = context3D.createRectangleTexture(width, height, format, renderToTexture);
		}
		
		override public function dispose():void 
		{
			prevSize.setTo( -1, -1);
		}
		
		override public function upload(context3D:ContextProxy):Boolean 
		{
			return true;
		}
		
		override public function clone():Resource 
		{
			return new RenderTextureResource(limitW, limitH, _lowLV);
		}
		
	}

}