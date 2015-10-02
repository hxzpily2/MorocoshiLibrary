package net.morocoshi.starling.components
{
	import starling.events.Event;
	
	public class ComponentEvent extends Event
	{
		static public const SELECT_RADIO_BUTTON:String = "selectRadioButton";
		static public const CHANGE:String = "change";
		public var component:Component;
		
		public function ComponentEvent(type:String, component:Component, bubbles:Boolean=false, data:Object=null)
		{
			this.component = component;
			super(type, bubbles, data);
		}
	}
}