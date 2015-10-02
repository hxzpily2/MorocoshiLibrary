package net.morocoshi.starling.components
{
	import net.morocoshi.starling.events.MouseTouchEvent;
	import net.morocoshi.starling.mouse.MouseTouch;
	import starling.events.Event;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class RadioButton extends Component
	{
		public var group:String;
		
		private var image:Image;
		private var upTexture:Texture;
		private var downTexture:Texture;
		private var overTexture:Texture;
		private var selectTexture:Texture;
		private var touch:MouseTouch;
		private var _selected:Boolean;
		
		public function RadioButton(group:String, data:*, up:Texture, down:Texture, select:Texture, over:Texture)
		{
			super();
			
			this.data = data;
			this.group = group;
			_selected = false;
			image  = new Image(up);
			upTexture = up;
			downTexture = down;
			overTexture = over;
			selectTexture = select;
			addChild(image);
			
			touch = new MouseTouch(this);
			touch.addEventListener(MouseTouchEvent.CLICK, touch_clickHandler);
			touch.addEventListener(MouseTouchEvent.CHANGE, touch_changeHandler);
		}
		
		private function touch_clickHandler():void
		{
			selected = true;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			if(_selected == value) return;
			
			_selected = value;
			touch_changeHandler(null);
			
			if(_selected)
			{
				var current:DisplayObjectContainer = parent;
				while(current)
				{
					if(current is Form)
					{
						Form(current).selectRadioButton(group, this);
						break;
					}
					current = current.parent;
				}
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}

		private function touch_changeHandler(e:MouseTouchEvent):void
		{
			var texture:Texture = upTexture;
			
			if(_selected && selectTexture)
			{
				texture = selectTexture;
			}
			else if(touch.isMouseDown && downTexture)
			{
				texture = downTexture;
			}
			else if(touch.isRollOver && overTexture)
			{
				texture = overTexture;
			}
			
			image.texture = texture;
		}
	}
}