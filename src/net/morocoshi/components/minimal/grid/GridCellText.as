package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class GridCellText extends Panel implements IGridCell
	{
		private var _label:Label;
		private var _gridItem:DataGridItem;
		
		public function GridCellText() 
		{
			super();
			_label = new Label(this);
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
		
		/* INTERFACE net.morocoshi.component.minimal.IGridCell */
		
		public function get cellValue():* 
		{
			return _label.text;
		}
		
		public function set cellValue(value:*):void 
		{
			_label.text = value;
		}
		
		public function get label():Label 
		{
			return _label;
		}
		
	}

}