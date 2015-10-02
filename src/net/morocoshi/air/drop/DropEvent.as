package net.morocoshi.air.drop 
{
	import flash.events.Event;
	import net.morocoshi.air.files.ClipData;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DropEvent extends Event 
	{
		/**ドロップが成功した時*/
		static public const DRAG_DROP:String = "dragDrop";
		/**ドラッグ中に対象の上でマウスオーバーした時*/
		static public const DRAG_ROLL:String = "dragRoll";
		
		public var clipData:ClipData;
		public var isDragOver:Boolean;
		
		public function DropEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new DropEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DropEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}