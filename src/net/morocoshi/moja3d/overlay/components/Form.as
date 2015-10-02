package net.morocoshi.moja3d.overlay.components
{
	import net.morocoshi.moja3d.events.Component2DEvent;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.overlay.objects.Object2D;
	
	use namespace moja3d;
	
	public class Form extends Object2D
	{
		public function Form()
		{
			super();
		}
		
		public function getSelectedRadioButton(group:String):RadioButton
		{
			var children:Vector.<Object2D> = getChildren(RadioButton);
			var n:int = children.length;
			for (var i:int = 0; i < n; i++) 
			{
				var radio:RadioButton = children[i] as RadioButton;
				if (radio.group == group && radio.selected)
				{
					return radio;
				}
			}
			
			return null;
		}
		
		public function selectRadioButtonByData(group:String, data:*):void
		{
			var children:Vector.<Object2D> = getChildren(RadioButton);
			var n:int = children.length;
			for (var i:int = 0; i < n; i++) 
			{
				var radio:RadioButton = children[i] as RadioButton;
				if (radio.group == group && radio.data == data)
				{
					radio.selected = true;
					return;
				}
			}
		}
		
		public function selectRadioButton(group:String, selected:RadioButton):void
		{
			dispatchEvent(new Component2DEvent(Component2DEvent.SELECT_RADIO_BUTTON, selected));
			
			var children:Vector.<Object2D> = getChildren(RadioButton);
			var n:int = children.length;
			for (var i:int = 0; i < n; i++) 
			{
				var radio:RadioButton = children[i] as RadioButton;
				if (radio.group == group && radio != selected)
				{
					radio.selected = false;
				}
			}
		}
		
		private function getChildren(filter:Class):Vector.<Object2D>
		{
			var result:Vector.<Object2D> = new <Object2D>[];
			var stock:Vector.<Object2D> = new <Object2D>[this];
			while (stock.length)
			{
				var object:Object2D = stock.pop();
				if (object)
				{
					var n:int = object.numChildren;
					for (var item:Object2D = object._children; item; item = item._next)
					{
						stock.push(item);
					}
				}
				if (object is filter)
				{
					result.push(object);
				}
			}
			return result;
		}
	}
}