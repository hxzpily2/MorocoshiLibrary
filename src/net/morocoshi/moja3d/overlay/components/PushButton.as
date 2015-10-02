package net.morocoshi.moja3d.overlay.components
{
	import flash.events.TouchEvent;
	import net.morocoshi.moja3d.overlay.objects.Image2D;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	
	public class PushButton extends Component
	{
		private var image:Image2D;
		private var upTexture:ImageTextureResource;
		private var downTexture:ImageTextureResource;
		private var overTexture:ImageTextureResource;
		
		public function PushButton(up:ImageTextureResource, down:ImageTextureResource, over:ImageTextureResource, clickHandler:Function = null)
		{
			super();
			
			upTexture = up;
			downTexture = down;
			overTexture = over;
			image  = new Image2D(upTexture);
			addChild(image);
			
			addEventListener(TouchEvent.TOUCH_BEGIN, mouseDownHandler);
			
			if (clickHandler != null)
			{
				addEventListener(TouchEvent.TOUCH_TAP, clickHandler);
			}
		}
		
		private function mouseDownHandler(e:TouchEvent):void 
		{
			screen.addEventListener(TouchEvent.TOUCH_END, mouseUpHandler);
			if (downTexture)
			{
				image.texture = downTexture;
			}
		}
		
		private function mouseUpHandler(e:TouchEvent):void 
		{
			screen.removeEventListener(TouchEvent.TOUCH_END, mouseUpHandler);
			if (upTexture)
			{
				image.texture = upTexture;
			}
		}
		
		override public function get width():Number 
		{
			return image.width;
		}
		
		override public function set width(value:Number):void 
		{
			image.width = value;
		}
		
		override public function get height():Number 
		{
			return image.height;
		}
		
		override public function set height(value:Number):void 
		{
			image.height = value;
		}
		
	}
}