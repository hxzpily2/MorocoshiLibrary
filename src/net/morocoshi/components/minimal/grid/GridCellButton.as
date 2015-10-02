package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * DataGrid用ボタンセル
	 * 
	 * @author tencho
	 */
	public class GridCellButton extends PushButton implements IGridCell
	{
		private var _gridItem:DataGridItem;
		private var _align:String;
		/**
		 * コンストラクタ
		 */
		public function GridCellButton() 
		{
			super();
			_align = TextFormatAlign.CENTER;
		}
		
		override public function draw():void 
		{
			super.draw();
			var l:Label = getChildAt(2) as Label;
			if (_align == TextFormatAlign.LEFT) l.x = 4;
			if (_align == TextFormatAlign.RIGHT) l.x = _width - l.width - 4;
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
			return label;
		}
		
		public function set cellValue(value:*):void 
		{
			label = value;
		}
		
		public function get align():String 
		{
			return _align;
		}
		
		public function set align(value:String):void 
		{
			_align = value;
		}
		
	}

}