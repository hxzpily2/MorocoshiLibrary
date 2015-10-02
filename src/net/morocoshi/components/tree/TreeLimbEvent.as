package net.morocoshi.components.tree
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import net.morocoshi.components.tree.TreeLimb;
	
	/**
	 * ファイルツリー関係のイベント
	 */
	public class TreeLimbEvent extends Event
	{
		/**フォルダを開閉した時*/
		static public const SWITCH:String = "onSwitch";
		/**選択状況が変化した時*/
		static public const CHANGE_SELECT:String = "onChangeSelect";
		/**アイテムがクリックされた時*/
		static public const CLICK_ITEM:String = "onClickItem";
		/**アイテムがWクリックされた時*/
		static public const WCLICK_ITEM:String = "onWclickItem";
		/**ツリーのサイズが変化した時*/
		static public const RESIZE:String = "onResize";
		/**アイテムが選択された時*/
		static public const SELECT_ITEM:String = "onSelectItem";
		
		public var extra:*;
		/**呼び出し元のTreeLimbオブジェクト（クリック時等はcurrentTargetと違う場合もあります）*/
		public var targetLimb:TreeLimb;
		/**ツリーサイズ*/
		public var bounds:Rectangle;
		
		public function TreeLimbEvent(type:String, target:TreeLimb = null, extra:* = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.extra = extra;
			targetLimb = target;
			super(type, bubbles, cancelable);
		}
		
	}
	
}