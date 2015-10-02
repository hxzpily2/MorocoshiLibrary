package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.Component;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DataGridItem extends EventDispatcher
	{
		public var extra:*;
		public var data:Object;
		public var items:Object;
		internal var _sprite:Sprite;
		internal var _visible:Boolean;
		internal var _dataGrid:DataGrid;
		internal var onAddedComponent:Function;
		
		public function DataGridItem(data:Object = null) 
		{
			this.data = data || { };
			items = { };
			_sprite = new Sprite();
			_visible = true;
		}
		
		public function getComponent(id:String):Component
		{
			return items[id];
		}
		
		public function setComponent(id:String, comp:Component):void
		{
			if (!(comp is IGridCell && comp is Component)) throw new Error("IGridCellを実装したComponentクラスではありません");
			if (items[id])
			{
				_sprite.removeChild(items[id]);
			}
			IGridCell(comp).gridItem = this;
			items[id] = comp;
			setValue(id, data[id]);
			_sprite.addChild(comp);
			comp.addEventListener(DataGridEvent.CHANGE, cell_changeHandler);
			onAddedComponent(comp);
		}
		
		public function setData(data:Object):void
		{
			for (var k:String in data)
			{
				setValue(k, data[k]);
			}
		}
		
		private function cell_changeHandler(e:Event):void 
		{
			var comp:Component = e.currentTarget as Component;
			var id:String = "";
			for (var k:String in items) 
			{
				if (items[k] == comp)
				{
					id = k;
					break;
				}
			}
			if (id) data[id] = IGridCell(comp).cellValue;
			notifyChange(comp);
		}
		
		public function notifyChange(comp:Component):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, this, comp));
		}
		
		public function setValue(id:String, value:*):void
		{
			var comp:Component = getComponent(id);
			if(comp) IGridCell(comp).cellValue = value;
		}
		
		public function getValue(id:String):*
		{
			var comp:Component = getComponent(id);
			return comp? IGridCell(comp).cellValue : null;
		}
		
		public function getKey(cell:Component):String 
		{
			for (var key:String in items) 
			{
				if (items[key] === cell) return key;
			}
			return null;
		}
		
		public function get sprite():Sprite 
		{
			return _sprite;
		}
		
		public function get visible():Boolean 
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void 
		{
			_visible = _sprite.visible = value;
			if (_dataGrid) _dataGrid.update();
		}
		
		public function get dataGrid():DataGrid 
		{
			return _dataGrid;
		}
		
		public function set dataGrid(value:DataGrid):void 
		{
			_dataGrid = value;
		}
		
	}

}