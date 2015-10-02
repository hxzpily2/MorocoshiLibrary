package net.morocoshi.moja3d.overlay.components
{
	import flash.events.Event;
	import flash.events.TouchEvent;
	import net.morocoshi.moja3d.overlay.objects.Image2D;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	
	public class RadioButton extends Component
	{
		public var group:String;
		
		private var image:Image2D;
		private var upTexture:ImageTextureResource;
		private var downTexture:ImageTextureResource;
		private var overTexture:ImageTextureResource;
		private var selectTexture:ImageTextureResource;
		private var _selected:Boolean;
		private var isMouseDown:Boolean;
		
		public function RadioButton(group:String, data:*, up:ImageTextureResource, down:ImageTextureResource, select:ImageTextureResource, over:ImageTextureResource)
		{
			super();
			
			this.data = data;
			this.group = group;
			_selected = false;
			image = new Image2D(up);
			upTexture = up;
			downTexture = down;
			overTexture = over;
			selectTexture = select;
			addChild(image);
			
			addEventListener(TouchEvent.TOUCH_BEGIN, mouseDownHandler);
			addEventListener(TouchEvent.TOUCH_TAP, touch_clickHandler);
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
		
		private function mouseDownHandler(e:TouchEvent):void 
		{
			screen.addEventListener(TouchEvent.TOUCH_END, mouseUpHandler);
			isMouseDown = true;
			notifyChange();
			updateTexture();
		}
		
		private function mouseUpHandler(e:TouchEvent):void 
		{
			screen.removeEventListener(TouchEvent.TOUCH_END, mouseUpHandler);
			isMouseDown = false;
			notifyChange();
			updateTexture();
		}
		
		private function touch_clickHandler(e:TouchEvent):void
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
			updateTexture();
			notifyChange();
			
			if(_selected)
			{
				var form:Form = getForm();
				if (form)
				{
					form.selectRadioButton(group, this);
				}
			}
		}
		
		private function notifyChange():void 
		{
			dispatchEvent(new Event(Event.CHANGE));
		}

		private function updateTexture():void
		{
			var texture:ImageTextureResource = upTexture;
			
			if(_selected && selectTexture)
			{
				texture = selectTexture;
			}
			else if(isMouseDown && downTexture)
			{
				texture = downTexture;
			}
			
			image.texture = texture;
		}
	}
}