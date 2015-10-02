package net.morocoshi.air.menu
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	import flash.events.Event;
	import net.morocoshi.air.events.AirMenuEvent;
	
	[Event(name = "airmenu_select", type = "net.morocoshi.air.menu.AirMenuEvent")]
	
	/**
	 * NativeMenuを拡張したクラス。無駄な引数や機能が色々残ってる。
	 * 
	 * @author tencho
	 */
	public class AirMenu extends NativeMenu
	{
		/**[古]選択時に呼ばれる。引数はAirMenuEvent。サブメニューをネストしまくると呼ばれないバグがある*/
		public var onSelectItem:Function;
		
		private var parentMenu:NativeMenu;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function AirMenu()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  追加・削除
		//
		//--------------------------------------------------------------------------
		
		/**
		 * メニューに区切りを追加
		 * @return
		 */
		public function addSeparator():NativeMenuItem
		{
			return addItem(new NativeMenuItem("", true));
		}
		
		/**
		 * 
		 * @param	submenu
		 * @param	label
		 * @return
		 */
		override public function addSubmenu(submenu:NativeMenu, label:String):NativeMenuItem
		{
			var item:NativeMenuItem = super.addSubmenu(submenu, label);
			if (submenu is AirMenu)
			{
				AirMenu(submenu).addEventListener(AirMenuEvent.SELECT, notifySelect);
			}
			return item;
		}
		
		/**
		 * メニューにアイテムを追加
		 * @param	label	ラベル名
		 * @param	id		[古]onSelectItemから取得できるID
		 * @param	extra	[古]onSelectItemから取得できる任意の値
		 * @param	select	このアイテムが選択された時に呼ばれる関数
		 * @param	args	selectで指定した関数に渡される引数の値
		 * @return
		 */
		public function addMenuItem(label:String, id:String = "", extra:* = null, select:Function = null, args:Array = null):NativeMenuItem
		{
			var item:NativeMenuItem = new NativeMenuItem(label);
			item.data = { extra:extra, id:id };
			item.addEventListener(Event.SELECT, function(e:Event):void
			{
				if (select != null) select.apply(null, args);
			});
			item.addEventListener(Event.SELECT, menu_selectHandler);
			return addItem(item);
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function notifySelect(e:AirMenuEvent):void
		{
			var evt:AirMenuEvent = new AirMenuEvent(AirMenuEvent.SELECT);
			evt.id = e.id;
			evt.item = e.item;
			evt.extra = e.extra;
			if (onSelectItem != null) onSelectItem(evt);
			dispatchEvent(evt);
		}
		
		private function menu_selectHandler(e:Event):void
		{
			var item:NativeMenuItem = e.currentTarget as NativeMenuItem;
			var evt:AirMenuEvent = new AirMenuEvent(AirMenuEvent.SELECT);
			evt.item = item;
			try { evt.id = item.data.id; } catch (e:Error) { }
			try	{ evt.extra = item.data.extra; } catch (e:Error) { }
			notifySelect(evt);
		}
		
		/**
		 * OS別にメニューを設定する
		 * @param	stage
		 * @param	menu
		 */
		static public function setMenu(stage:Stage, menu:NativeMenu):void 
		{
			//OSX
			if (NativeApplication.supportsMenu)
			{
				NativeApplication.nativeApplication.menu = menu;
			}
			//Windows,Linux
			if (NativeWindow.supportsMenu)
			{
				stage.nativeWindow.menu = menu;
			}
		}
		
	}

}