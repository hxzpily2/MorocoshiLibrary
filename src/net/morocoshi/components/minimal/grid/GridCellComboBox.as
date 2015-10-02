package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Panel;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class GridCellComboBox extends Panel implements IGridCell 
	{
		private var _comboBox:ComboBox;
		private var _gridItem:DataGridItem;
		private var isInit:Boolean = false;
		/**プルダウンサイズの高さ限界値。これをNaN以外にするとこのサイズより高くなりません（縦横比によってはプラスボタンが邪魔になるため用意）*/
		public var limitHeight:Number = NaN;
		
		public function GridCellComboBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
			_comboBox = new ComboBox(this);
			_comboBox.addEventListener(Event.SELECT, selectHandler);
			isInit = true;
		}
		
		private function selectHandler(e:Event):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		public function addItem(label:String, data:*):void
		{
			_comboBox.addItem( { label:label, data:data } );
			_comboBox.numVisibleItems = Math.max(1, Math.min(_comboBox.items.length, 10));
		}
		
		/* INTERFACE net.morocoshi.components.minimal.grid.IGridCell */
		
		public function get cellValue():* 
		{
			return _comboBox.selectedItem.data;
		}
		
		public function set cellValue(value:*):void 
		{
			for (var i:int = 0; i < _comboBox.items.length; i++)
			{
				if (_comboBox.items[i].data == value)
				{
					_comboBox.selectedIndex = i;
					break;
				}
			}
		}
		
		public function get comboBox():ComboBox 
		{
			return _comboBox;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			if (!isInit) return;
			if (!isNaN(limitHeight) && h > limitHeight) h = limitHeight;
			_comboBox.setSize(w, h);
		}
		
		/* INTERFACE net.morocoshi.components.minimal.grid.IGridCell */
		
		public function get gridItem():DataGridItem 
		{
			return _gridItem;
		}
		
		public function set gridItem(value:DataGridItem):void 
		{
			_gridItem = value;
		}
		
	}

}