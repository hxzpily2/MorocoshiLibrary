package net.morocoshi.common.collision.solid.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class Collision3DEvent extends Event 
	{
		/**ワールド空間に追加された*/
		static public const ADD_TO_WORLD:String = "addToWorld";
		/**ワールド空間から切り離された*/
		static public const REMOVE_FROM_WORLD:String = "removeFromWorld";
		
		public function Collision3DEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new Collision3DEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("Collision3DEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}