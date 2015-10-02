package net.morocoshi.common.menu 
{
	import flash.events.ContextMenuEvent;
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	/**
	 * Flashの右クリック（コンテキスト）メニューを簡単に設定する為のクラス
	 * 
	 * @author tencho
	 */
	public class FlashMenu extends EventDispatcher
	{
		private var _contextMenu:ContextMenu = new ContextMenu();
		private var menuItems:Dictionary = new Dictionary();
		private var nextSeparator:Boolean = false;
		
		/**追加したアイテムがどれか選択された時に呼び出される。引数が1あればFlashMenuEventオブジェクトが渡される*/
		public var onSelect:Function;
		
		/**
		 * コンストラクタ
		 */
		public function FlashMenu() 
		{
		}
		
		/**
		 * メニューにアイテムを追加する
		 * 
		 * @param	label	ラベル名
		 * @param	id	ID
		 * @param	select	このアイテムを選択した時に呼び出される。引数が1あればFlashMenuEventオブジェクトが渡される
		 * @return
		 */
		public function addItem(label:String, id:String = "", select:Function = null):ContextMenuItem
		{
			var item:ContextMenuItem = new ContextMenuItem(label, nextSeparator);
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menu_selectHandler);
			_contextMenu.customItems.push(item);
			menuItems[item] = { id:id, select:select };
			nextSeparator = false;
			return item
		}
		
		/**
		 * 区切り線を追加する。追加アイテム一覧の一番上と一番下には表示されない。2回連続で追加しても無効になる。
		 */
		public function addSeparator():void
		{
			nextSeparator = true;
		}
		
		private function menu_selectHandler(e:ContextMenuEvent):void 
		{
			var item:ContextMenuItem = e.currentTarget as ContextMenuItem;
			var data:Object = menuItems[item];
			
			var evt:FlashMenuEvent = new FlashMenuEvent(FlashMenuEvent.FLASH_MENU_SELECT);
			evt.id = data.id;
			evt.item = item;
			
			if (data.select != null)
			{
				if (data.select.length == 1) data.select(evt);
				else data.select();
			}
			if (onSelect != null)
			{
				if (onSelect.length == 1) onSelect(evt);
				else onSelect();
			}
			dispatchEvent(evt);
		}
		
		/**本来のコンテキストメニューオブジェクト*/
		public function get contextMenu():ContextMenu 
		{
			return _contextMenu;
		}
		
	}

}