package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Panel;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import net.morocoshi.common.graphics.Create;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class GridCellCheckBox extends Panel implements IGridCell
	{
		public var checkBox:CheckBox;
		private var _gridItem:DataGridItem;
		private var basePanel:Sprite;
		private var isReady:Boolean;
		
		public function GridCellCheckBox() 
		{
			super();
			basePanel = Create.box(0, 0, 10, 10, 0, 0);
			addChild(basePanel);
			checkBox = new CheckBox(this);
			checkBox.mouseEnabled = checkBox.mouseChildren = false;
			basePanel.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			buttonMode = true;
			isReady = true;
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			checkBox.selected = !checkBox.selected;
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
		}
		
		/* INTERFACE net.morocoshi.component.minimal.IGridCell */
		
		public function get cellValue():* 
		{
			return checkBox.selected;
		}
		
		public function set cellValue(value:*):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, this));
			checkBox.selected = value;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			if (!isReady) return;
			super.setSize(w, h);
			basePanel.width = w;
			basePanel.height = h;
			if (!checkBox) return;
			checkBox.x = (w - 8) / 2 | 0;
			checkBox.y = (h - 8) / 2 | 0;
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