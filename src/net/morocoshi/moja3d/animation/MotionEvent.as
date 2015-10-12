package net.morocoshi.moja3d.animation 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class MotionEvent extends Event 
	{
		static public const MOTION_LOOP:String = "motionLoop";
		static public const MOTION_COMPLETE:String = "motionComplete"; 
		public function MotionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new MotionEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MotionEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}