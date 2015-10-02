package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.Panel;
	import net.morocoshi.components.minimal.BitmapClip;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class GridCellBitmap extends Panel implements IGridCell
	{
		private var _bitmapClip:BitmapClip;
		private var _panel:Panel;
		private var _gridItem:DataGridItem;
		private var _scaleMode:String;
		
		/**
		 * 
		 * @param	scaleMode	ScaleMode.AUTO
		 */
		public function GridCellBitmap(scaleMode:String = "auto") 
		{
			super();
			_scaleMode = scaleMode;
			_panel = new Panel(this);
			_bitmapClip = new BitmapClip(this, 0, 0, null, true, scaleMode);
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
			return _bitmapClip.bitmapData;
		}
		
		public function set cellValue(value:*):void 
		{
			_bitmapClip.bitmapData = value;
		}
		
		public function get scaleMode():String 
		{
			return _scaleMode;
		}
		
		public function set scaleMode(value:String):void 
		{
			_bitmapClip.scaleMode = _scaleMode = value;
		}
		
		public function get bitmapClip():BitmapClip 
		{
			return _bitmapClip;
		}
		
		public function get panel():Panel 
		{
			return _panel;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			if (_bitmapClip)
			{
				_panel.setSize(w, h);
				_bitmapClip.setSize(w, h);
			}
		}
		
	}

}