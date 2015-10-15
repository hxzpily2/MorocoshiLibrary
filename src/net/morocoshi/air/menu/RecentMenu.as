package net.morocoshi.air.menu
{
	import flash.display.NativeMenuItem;
	import net.morocoshi.air.menu.AirMenu;
	import net.morocoshi.common.math.list.VectorUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class RecentMenu
	{
		public var onSelect:Function;
		public var onChange:Function;
		private var nativeMenu:NativeMenuItem;
		private var _menu:AirMenu;
		private var recentList:Array;
		private var _fileLimit:int;
		
		/**
		 * ファイルパスの配列を渡して初期化する。渡した配列はメニュー操作により内部の値が変更されます。
		 * @param	list
		 */
		public function RecentMenu(list:Array, limit:int = 10)
		{
			recentList = list;
			_fileLimit = limit;
			_menu = new AirMenu();
		}
		
		/**
		 * この履歴メニューを指定メニュー内のサブメニューとして追加する
		 * @param	target
		 * @param	label
		 */
		public function addSubMenuTo(target:AirMenu, label:String):NativeMenuItem
		{
			return nativeMenu = target.addSubmenu(_menu, label);
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
			onChange();// Root.user.save();
		}
		
		public function update():void
		{
			_menu.removeAllItems();
			var n:int = recentList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var path:String = recentList[i];
				_menu.addMenuItem(path, "", null, onSelect, [path]);
			}
			_menu.addSeparator();
			_menu.addMenuItem("最近開いたファイルを一覧からクリア", "", null, clear);
			nativeMenu.enabled = n > 0;
		}
		
		private function clear():void 
		{
			recentList.length = 0;
			update();
			onChange();// Root.user.save();
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