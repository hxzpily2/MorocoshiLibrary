package net.morocoshi.components.minimal.grid 
{
	import flash.events.Event;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	import net.morocoshi.components.minimal.input.InputTextBox;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class GridCellInputText extends InputTextBox implements IGridCell
	{
		private var _gridItem:DataGridItem;
		public function GridCellInputText() 
		{
			super();
			addEventListener(Event.COMPLETE, changeHandler);
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
		
		private function changeHandler(e:Event):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		/* INTERFACE net.morocoshi.component.minimal.IGridCell */
		
		public function get cellValue():* 
		{
			return text;
		}
		
		public function set cellValue(value:*):void 
		{
			text = value;
		}
		
	}

}