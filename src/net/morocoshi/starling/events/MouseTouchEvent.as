package net.morocoshi.starling.events
{
	import starling.events.Event;
	
	public class MouseTouchEvent extends Event
	{
		static public const CLICK:String = "click";
		static public const ROLL_OVER:String = "rollOver";
		static public const ROLL_OUT:String = "rollOut";
		static public const CHANGE:String = "change";
		static public const MOUSE_DOWN:String = "mouseDown";
		static public const MOUSE_UP:String = "mouseUp";
		static public const START_DRAG:String = "startDrag";
		static public const STOP_DRAG:String = "stopDrag";
		static public const DRAGGING:String = "dragging";
		
		public var dragX:Number = 0;
		public var dragY:Number = 0;
		
		public function MouseTouchEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			//TODO: implement function
			super(type, bubbles, data);
		}
		
	}
}