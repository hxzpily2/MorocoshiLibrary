package net.morocoshi.common.menu 
{
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	
	/**
	 * FlashMenu関連イベント
	 * 
	 * @author tencho
	 */
	public class FlashMenuEvent extends Event
	{
		public static const FLASH_MENU_SELECT:String = "flash_menu_select";
		
		public var extra:*;
		public var id:String;
		public var item:ContextMenuItem;
		
		public function FlashMenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new FlashMenuEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FlashMenuEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}