package net.morocoshi.moja3d.events 
{
	import flash.events.Event;
	import net.morocoshi.moja3d.collision.CollisionResult;
	
	/**
	 * Moja3Dイベント
	 * 
	 * @author tencho
	 */
	public class MouseEvent3D extends Event 
	{
		static public const CLICK:String = "click";
		static public const MOUSE_DOWN:String = "mouseDown";
		static public const MOUSE_UP:String = "mouseUp";
		static public const MOUSE_MOVE:String = "mouseMove";
		static public const ROLL_OVER:String = "rollOver";
		static public const ROLL_OUT:String = "rollOut";
		
		public var collision:CollisionResult;
		
		public function MouseEvent3D(type:String, collision:CollisionResult, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
			this.collision = collision;
		}
		
		public override function clone():Event 
		{ 
			return new MouseEvent3D(type, collision, bubbles, cancelable);
		}
		
		public override function toString():String 
		{ 
			return formatToString("MouseEvent3D", "type", "collision", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}