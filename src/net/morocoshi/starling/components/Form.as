package net.morocoshi.starling.components
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	
	public class Form extends Sprite
	{
		public function Form()
		{
			super();
		}
		
		public function getSelectedRadioButton(group:String):RadioButton
		{
			for each(var item:DisplayObject in getChildren(RadioButton))
			{
				var radio:RadioButton = item as RadioButton;
				if(radio.group == group && radio.selected)
				{
					return radio;
				}
			}
			
			return null;
		}
		
		public function selectRadioButtonByData(group:String, data:*):void
		{
			for each(var item:DisplayObject in getChildren(RadioButton))
			{
				var radio:RadioButton = item as RadioButton;
				if(radio.group == group && radio.data == data)
				{
					radio.selected = true;
					return;
				}
			}
		}
		
		public function selectRadioButton(group:String, selected:RadioButton):void
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.SELECT_RADIO_BUTTON, selected));
			
			for each(var item:DisplayObject in getChildren(RadioButton))
			{
				var radio:RadioButton = item as RadioButton;
				if(radio.group == group && radio != selected)
				{
					radio.selected = false;
				}
			}
		}
		
		private function getChildren(cls:Class):Vector.<DisplayObject>
		{
			var result:Vector.<DisplayObject> = new <DisplayObject>[];
			var stock:Vector.<DisplayObject> = new <DisplayObject>[this];
			while(stock.length)
			{
				var object:DisplayObject = stock.pop();
				var container:DisplayObjectContainer = object as DisplayObjectContainer;
				if(container)
				{
					var n:int = container.numChildren;
					for (var i:int = 0; i < n; i++)
					{
						stock.push(container.getChildAt(i));
					}
				}
				if(object is cls)
				{
					result.push(object);
				}
			}
			return result;
		}
	}
}