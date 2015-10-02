package net.morocoshi.moja3d.events
{
	import flash.events.Event;
	import net.morocoshi.moja3d.overlay.components.Component;
	
	public class Component2DEvent extends Event
	{
		static public const SELECT_RADIO_BUTTON:String = "selectRadioButton";
		static public const CHANGE:String = "change";
		
		public var component:Component;
		
		public function Component2DEvent(type:String, component:Component, bubbles:Boolean = false, data:Object = null)
		{
			this.component = component;
			super(type, bubbles, data);
		}
	}
}