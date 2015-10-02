package net.morocoshi.components.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class ComponentEvent extends Event 
	{
		
		public static const UPDATE:String = "update";
		public static const OK:String = "ok";
		
		public function ComponentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new ComponentEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ComponentEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}