package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.Component;
	import com.bit101.components.HUISlider;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import net.morocoshi.components.events.DataGridEvent;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class GridCellSlider extends Component implements IGridCell 
	{
		public var slider:HUISlider;
		private var _gridItem:DataGridItem;
		
		public function GridCellSlider(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0) 
		{
			super(parent, xpos, ypos);
			slider = new HUISlider(this, 0, 0, "", changeHandler);
		}
		
		private function changeHandler(e:Event):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			slider.width = w + 20;
			slider.y = (h - 18) / 2;
			slider.visible = (w > 40);
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
			return slider.value;
		}
		
		public function set cellValue(value:*):void 
		{
			slider.value = value;
		}
		
	}

}