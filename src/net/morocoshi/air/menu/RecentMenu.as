package net.morocoshi.air.menu
{
	import com.bit101.components.WheelMenu;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import net.morocoshi.air.menu.AirMenu;
	import net.morocoshi.common.debug.DebugTimer;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.timers.FrameTimer;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class RecentMenu
	{
		public var onSelect:Function;
		public var onChange:Function;
		private var _menu:AirMenu;
		private var recentList:Array;
		private var _fileLimit:int;
		private var subMenu:NativeMenuItem;
		
		/**
		 * ファイルパスの配列を渡して初期化する。渡した配列はメニュー操作により内部の値が変更されます。
		 * @param	list
		 */
		public function RecentMenu(list:Array, limit:int = 10)
		{
			recentList = list;
			_fileLimit = limit;
			if (recentList.length > _fileLimit) recentList.length = _fileLimit;
			_menu = new AirMenu();
		}
		
		/**
		 * この履歴メニューを指定メニュー内のサブメニューとして追加する
		 * @param	target
		 * @param	label
		 */
		public function addSubMenuTo(target:AirMenu, label:String):NativeMenuItem
		{
			subMenu = target.addSubmenu(_menu, label);
			return subMenu;
		}
		
		public function addFile(path:String):void 
		{
			removeFile(path);
			recentList.unshift(path);
			if (recentList.length > _fileLimit) recentList.length = _fileLimit;
			update();
			onChange();
		}
		
		public function removeFile(path:String):void 
		{
			var list:Array = recentList.filter(function(...args):Boolean { return args[0] == path } );
			VectorUtil.deleteItemList(recentList, list);
			update();
			onChange();
		}
		
		public function update():void
		{
			FrameTimer.setTimer(1, updateTimer, null, "updateRecentMenu", true);
		}
		
		private function updateTimer():void 
		{
			//高速化のためにいったん表示リストから外す
			var menuIndex:int;
			var parentMenu:NativeMenu = _menu.parent;
			if (subMenu && parentMenu)
			{
				menuIndex = parentMenu.getItemIndex(subMenu);
				parentMenu.removeItem(subMenu);
			}
			
			_menu.removeAllItems();
			var n:int = recentList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var path:String = recentList[i];
				_menu.addMenuItem(path, "", null, onSelect, [path]);
			}
			_menu.addSeparator();
			_menu.addMenuItem("最近開いたファイルをクリア", "", null, clear);
			
			if (subMenu)
			{
				subMenu.enabled = n > 0;
				if (parentMenu)
				{
					parentMenu.addItemAt(subMenu, menuIndex);
				}
			}
		}
		
		private function clear():void 
		{
			recentList.length = 0;
			update();
			onChange();
		}
		
		public function get menu():AirMenu 
		{
			return _menu;
		}
		
		public function get fileLimit():int 
		{
			return _fileLimit;
		}
		
		public function set fileLimit(value:int):void 
		{
			_fileLimit = value;
			if (recentList.length > _fileLimit) recentList.length = _fileLimit;
			update();
			onChange();
		}
	
	}

}