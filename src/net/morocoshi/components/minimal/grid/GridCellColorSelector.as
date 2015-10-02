package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.ColorChooser;
	import com.bit101.components.Component;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import net.morocoshi.components.events.DataGridEvent;
	import net.morocoshi.components.minimal.color.ColorSelector;
	
	/**
	 * DataGrid用カラーセレクタ
	 * 
	 * @author tencho
	 */
	public class GridCellColorSelector extends Component implements IGridCell 
	{
		public var selector:ColorSelector;
		private var isInit:Boolean = false;
		private var _gridItem:DataGridItem;
		
		public function GridCellColorSelector(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0) 
		{
			super(parent, xpos, ypos);
			selector = new ColorSelector(this, 0, 0, 0xFFFFFF, selectHandler);
			selector.x = 2;
			isInit = true;
		}
		
		private function selectHandler(e:Event):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			if (!isInit) return;
			selector.y = (h - 16) / 2;
			selector.width = w - 2;
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
		
		/* INTERFACE net.morocoshi.components.minimal.grid.IGridCell */
		
		public function get cellValue():* 
		{
			return selector.value;
		}
		
		public function set cellValue(value:*):void 
		{
			selector.value = value;
		}
		
	}

}