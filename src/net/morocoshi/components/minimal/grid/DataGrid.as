package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.Component;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.bit101.components.VScrollBar;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import net.morocoshi.common.math.list.VectorUtil;
	
	/**
	 * DataGridコンポーネント
	 * 
	 * @author tencho
	 */
	public class DataGrid extends Panel
	{
		public var box:PushButton;
		private var _items:Vector.<DataGridItem>;
		private var _columns:Vector.<ColumnData>;
		private var _columnHeight:Number = 30;
		private var _itemHeight:Number = 25;
		private var _sortID:String;
		private var _scrollBar:VScrollBar;
		
		private var itemContainer:Sprite;
		private var isInit:Boolean = false;
		private var scrollWidth:Number = 10;
		private var _columnVisible:Boolean = true;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function DataGrid(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) 
		{
			super(parent, xpos, ypos);
			
			itemContainer = new Sprite();
			box = new PushButton();
			_items = new Vector.<DataGridItem>;
			_columns = new Vector.<ColumnData>;
			//box.mouseEnabled = mouseChildren = false;
			content.addChild(itemContainer);
			content.addChild(box);
			
			_scrollBar = new VScrollBar(this, 0, 0, scrollHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			isInit = true;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		public function get items():Vector.<DataGridItem> 
		{
			return _items;
		}
		
		public function get scrollBar():VScrollBar 
		{
			return _scrollBar;
		}
		
		public function get columns():Vector.<ColumnData> 
		{
			return _columns;
		}
		
		public function get columnVisible():Boolean 
		{
			return _columnVisible;
		}
		
		public function set columnVisible(value:Boolean):void 
		{
			_columnVisible = value;
		}
		
		public function get itemHeight():Number 
		{
			return _itemHeight;
		}
		
		public function set itemHeight(value:Number):void 
		{
			_itemHeight = value;
			updateLayout();
		}
		
		//--------------------------------------------------------------------------
		//
		//  カラムや行の追加・削除
		//
		//--------------------------------------------------------------------------
		
		/**
		 * カラムを最後に追加する
		 * @param	id
		 * @param	label
		 * @param	width
		 * @param	classObject
		 * @return
		 */
		public function addColumn(id:String, label:String, width:Number = -1, classObject:Class = null):ColumnData
		{
			return addColumnAt(_columns.length, id, label, width, classObject);
		}
		
		/**
		 * カラムを指定Indexの場所に挿入する
		 * @param	index
		 * @param	id
		 * @param	label
		 * @param	width
		 * @param	classObject
		 * @return
		 */
		public function addColumnAt(index:int, id:String, label:String, width:Number = -1, classObject:Class = null):ColumnData
		{
			var c:ColumnData = new ColumnData(id, label, width, classObject);
			_columns.splice(index, 0, c);
			c.onClick = column_clickHandler;
			addChild(c.button);
			updateLayout();
			return c;
		}
		
		/**
		 * 行を追加する
		 * @param	item
		 * @return
		 */
		public function addItem(item:DataGridItem):DataGridItem
		{
			item._dataGrid = this;
			_items.push(item);
			item.onAddedComponent = item_addedHandler;
			
			for each (var c:ColumnData in _columns) 
			{
				var cls:Class = c.classObject? c.classObject : GridCellInputText;
				item.setComponent(c.id, new cls());
			}
			item.addEventListener(DataGridEvent.CHANGE, item_changeHandler);
			itemContainer.addChild(item._sprite);
			updateLayout();
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, item))
			return item;
		}
		
		/**
		 * 全ての行を削除する
		 */
		public function removeAllItems():void
		{
			while (items.length)
			{
				removeItem(items[0]);
			}
		}
		
		/**
		 * 指定の行をDataGridItem指定で削除する
		 * @param	item
		 */
		public function removeItem(item:DataGridItem):void 
		{
			item._dataGrid = null;
			if (item._sprite.parent == itemContainer) itemContainer.removeChild(item._sprite);
			VectorUtil.deleteItem(_items, item);
			item.removeEventListener(DataGridEvent.CHANGE, item_changeHandler);
			item.onAddedComponent = null;
			
			updateLayout();
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, null, null));
		}
		
		/**
		 * 新しい行をObjectの初期値で追加する
		 * @param	data
		 * @return
		 */
		public function addItemByObject(data:Object):DataGridItem
		{
			var item:DataGridItem = new DataGridItem(data);
			return addItem(item);
		}
		
		//--------------------------------------------------------------------------
		//
		//  情報取得
		//
		//--------------------------------------------------------------------------
		
		public function getColumn(id:String):ColumnData
		{
			for each(var c:ColumnData in _columns)
			{
				if (id == c.id)
				{
					return c;
				}
			}
			return null;
		}
		
		/**
		 * 指定カラムIDの値が一致する行をリストアップ
		 * @param	id
		 * @param	value
		 * @return
		 */
		public function match(id:String, value:*):Vector.<DataGridItem>
		{
			var list:Vector.<DataGridItem> = new Vector.<DataGridItem>
			for each(var item:DataGridItem in _items)
			{
				if (item.getValue(id) == value) list.push(item);
			}
			return list;
		}
		
		//--------------------------------------------------------------------------
		//
		// 　各種設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 全てのカラムのソートの有効無効を一括設定する
		 * @param	enabled
		 */
		public function setSortEnabled(enabled:Boolean):void
		{
			for each(var c:ColumnData in _columns)
			{
				c.sortEnabled = enabled;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		// 　描画処理
		//
		//--------------------------------------------------------------------------
		
		public function update():void
		{
			updateLayout();
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			updateLayout();
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			updateLayout();
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			updateLayout();
		}
		
		private function updateScroll():void 
		{
			var colHeight:Number = _columnVisible? _columnHeight : 0;
			itemContainer.y = int(colHeight - _scrollBar.value);
		}
		
		private var updateEnabled:Boolean = true;
		private var afterUpdate:Boolean = false;
		/**
		 * 毎フレーム
		 * @param	e
		 */
		private function enterFrameHandler(e:Event):void 
		{
			if (!updateEnabled)
			{
				updateEnabled = true;
				if (afterUpdate)
				{
					updateLayout();
				}
			}
		}
		
		/**
		 * 全てのセルの配置を整列させる
		 */
		private function updateLayout():void
		{
			if (!isInit) return;
			if (!updateEnabled)
			{
				afterUpdate = true;
				return;
			}
			afterUpdate = false;
			updateEnabled = false;
			var cnt:int = 0;
			var contentWidth:Number = _width - scrollWidth;
			var tw:Number = contentWidth;
			
			var colHeight:Number = _columnVisible? _columnHeight : 0;
			
			box.setSize(scrollWidth, _columnHeight);
			box.x = _width - scrollWidth;
			box.y = 0;
			
			var i:int, c:ColumnData;
			for (i = 0; i < _columns.length; i++) 
			{
				c = _columns[i];
				c.button.visible = c.enabled && _columnVisible;
				if (!c.enabled) continue;
				if (c.width >= 0)
				{
					tw -= c.width;
					if (tw < 0)
					{
						c.button.width = c.width + tw;
						tw = 0;
					}
					else
					{
						c.button.width = c.width | 0;
					}
				}
				else
				{
					cnt++;
				}
			}
			if (cnt)
			{
				var w:Number = tw / cnt;
				for (i = 0; i < _columns.length; i++) 
				{
					c = _columns[i];
					if (c.width >= 0) continue;
					c.button.width = w;
				}
			}
			
			var px:Number = 0;
			for (i = 0; i < _columns.length; i++) 
			{
				c = _columns[i];
				if (!c.enabled) continue;
				c.button.x = px;
				c.button.height = _columnHeight;
				px += c.button.width | 0;
			}
			var ch:Number = height - colHeight;
			
			var py:int = 0;
			for each (var item:DataGridItem in _items)
			{
				px = 0;
				if (!item._visible) continue;
				item._sprite.y = py;
				py += _itemHeight;
				for (i = 0; i < _columns.length; i++) 
				{
					c = _columns[i];
					var ic:Component = item.getComponent(c.id);
					if (ic)
					{
						if (!c.enabled)
						{
							ic.visible = false;
						}
						else
						{
							ic.visible = true;
							ic.x = px;
							var boxWidth:Number = (i == _columns.length - 1)? contentWidth - px : c.button.width | 0;
							ic.setSize(boxWidth, _itemHeight);
						}
					}
					if (c.enabled) px += c.button.width | 0;
				}
			}
			if (width < scrollWidth)
			{
				_scrollBar.visible = box.visible = false;
			}
			else
			{
				_scrollBar.visible = box.visible = true;
				_scrollBar.x = width - scrollWidth;
				_scrollBar.y = colHeight;
				_scrollBar.height = Math.max(5, ch);
				_scrollBar.maximum = Math.max(0, py - ch);
				_scrollBar.enabled = py > ch;
				_scrollBar.setThumbPercent(Math.max(0.1, ch / py));
			}
			updateScroll();
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function wheelHandler(e:MouseEvent):void 
		{
			if (!isInit || !_scrollBar.enabled) return;
			
			var d:int = e.delta > 0? 1 : -1;
			_scrollBar.value -= d * 100;
			scrollHandler();
		}
		
		private function scrollHandler(e:Event = null):void 
		{
			if (!isInit) return;
			updateScroll();
		}
		
		private function column_clickHandler(c:ColumnData):void 
		{
			if (c.sortEnabled)
			{
				c.sortMode = !c.sortMode; 
				sort(c.id, c.sortMode);
			}
		}
		
		/**
		 * 
		 * @param	id
		 * @param	descend
		 */
		public function sort(id:String, descend:Boolean):void 
		{
			_sortID = id;
			if (descend) _items.sort(sortFunc1);
			else _items.sort(sortFunc2);
			updateLayout();
		}
		
		private function sortFunc1(a:DataGridItem, b:DataGridItem):int 
		{
			var v1:* = IGridCell(a.getComponent(_sortID)).cellValue;
			var v2:* = IGridCell(b.getComponent(_sortID)).cellValue;
			return int(v1 < v2) - int(v1 > v2);
		}
		
		private function sortFunc2(a:DataGridItem, b:DataGridItem):int 
		{
			var v1:* = IGridCell(a.getComponent(_sortID)).cellValue;
			var v2:* = IGridCell(b.getComponent(_sortID)).cellValue;
			return int(v1 > v2) - int(v1 < v2);
		}
		
		private function item_changeHandler(e:DataGridEvent):void 
		{
			dispatchEvent(new DataGridEvent(DataGridEvent.CHANGE, e.item, e.cell))
		}
		
		private function item_addedHandler(comp:Component):void 
		{
			updateLayout();
		}
		
	}

}