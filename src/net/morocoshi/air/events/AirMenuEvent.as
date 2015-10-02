package net.morocoshi.air.events
{
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	
	/**
	 * AirMenuクラスで使うイベント
	 * 
	 * @author tencho
	 */
	public class AirMenuEvent extends Event
	{
		static public const SELECT:String = "airmenu_select";
		
		public var item:NativeMenuItem;
		public var id:String = null;
		public var extra:* = null;
		
		public function AirMenuEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);	
		}
		
		public override function clone():Event
		{ 
			return new AirMenuEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String
		{
			return formatToString("AirMenuEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}