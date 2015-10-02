package net.morocoshi.components.minimal.buttons 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * 
	 * @author 
	 */
	public class ButtonListEvent extends Event 
	{
		public var label:String = "";
		public var id:String = "";
		public var index:int = 0;
		public var extra:* = null;
		
		static public const CLICK:String = "click";
		
		public function ButtonListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new ButtonListEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{
			return formatToString("PushButtonListEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}