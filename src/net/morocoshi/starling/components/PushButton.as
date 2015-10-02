package net.morocoshi.starling.components
{
	import starling.display.Image;
	import starling.textures.Texture;
	import net.morocoshi.starling.events.MouseTouchEvent;
	import net.morocoshi.starling.mouse.MouseTouch;
	
	public class PushButton extends Component
	{
		private var image:Image;
		private var upTexture:Texture;
		private var downTexture:Texture;
		private var overTexture:Texture;
		private var _touch:MouseTouch;
		
		public function PushButton(up:Texture, down:Texture, over:Texture, clickHandler:Function = null)
		{
			super();
			
			image  = new Image(up);
			upTexture = up;
			downTexture = down;
			overTexture = over;
			addChild(image);
			
			_touch = new MouseTouch(this);
			_touch.addEventListener(MouseTouchEvent.CHANGE, touch_changeHandler);
			if (clickHandler != null)
			{
				_touch.addEventListener(MouseTouchEvent.CLICK, clickHandler);
			}
		}
		
		private function touch_changeHandler(e:MouseTouchEvent):void
		{
			var texture:Texture = upTexture;
			
			if(_touch.isMouseDown && downTexture)
			{
				texture = downTexture;
			}
			else if(_touch.isRollOver && overTexture)
			{
				texture = overTexture;
			}
			
			image.texture = texture;
		}
		
		public function get touch():MouseTouch 
		{
			return _touch;
		}
	}
}