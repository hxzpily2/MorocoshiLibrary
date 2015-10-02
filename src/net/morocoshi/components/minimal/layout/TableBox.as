package net.morocoshi.components.minimal.layout
{
	import com.bit101.components.Component;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import net.morocoshi.list.VectorUtil;
	
	/**
	 * テーブルレイアウト
	 * 
	 * @author tencho
	 */
	public class TableBox extends Component
	{
		static public const ALIGN_TOP:String = "top";
		static public const ALIGN_MIDDLE:String = "middle";
		static public const ALIGN_BOTTOM:String = "bottom";
		static public const ALIGN_LEFT:String = "left";
		static public const ALIGN_RIGHT:String = "right";
		static public const ALIGN_CENTER:String = "center";
		private var _columnSpacing:Number = 0;
		private var _rowSpacing:Number = 0;
		private var cellList:Vector.<TableCell>;
		private var cellGrid:Object;
		private var cellLink:Dictionary;
		private var _numColumn:int = 0;
		private var _numRow:int = 0;
		
		//--------------------------------------------------------------------------
		//
		//  コンポーネント
		//
		//--------------------------------------------------------------------------
		
		public function TableBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
			cellGrid = { };
			cellLink = new Dictionary();
			cellList = new Vector.<TableCell>;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		public function get columnSpacing():Number
		{
			return _columnSpacing;
		}
		
		public function set columnSpacing(value:Number):void
		{
			_columnSpacing = value;
			update();
		}
		
		public function get rowSpacing():Number 
		{
			return _rowSpacing;
		}
		
		public function set rowSpacing(value:Number):void 
		{
			_rowSpacing = value;
			update();
		}
		
		public function get numColumn():int 
		{
			return _numColumn;
		}
		
		public function get numRow():int 
		{
			return _numRow;
		}
		
		//--------------------------------------------------------------------------
		//
		//  追加・削除
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 行例インデックス位置にコンポーネントを追加する
		 * @param	x
		 * @param	y
		 * @param	item
		 * @return
		 */
		public function addItemAt(x:int, y:int, item:Component):TableCell
		{
			//すでにどこかに配置されてるアイテムを削除
			removeItem(item);
			
			item.addEventListener(Event.RESIZE, item_resizeHandler);
			
			var cell:TableCell = getCellAt(x, y);
			
			//既にセルがあれば削除する
			if (cell)
			{
				removeCell(cell);
			}
			
			cell = new TableCell(x, y, item, ALIGN_LEFT, ALIGN_TOP);
			cellList.push(cell);
			cellGrid[getKey(x, y)] = cell;
			cellLink[item] = cell;
			addChild(item);
			update();
			
			return cell;
		}
		
		/**
		 * 一番下に行を追加する
		 * @param	...args
		 */
		public function addRowItems(...args):Vector.<TableCell> 
		{
			var list:Vector.<TableCell> = new Vector.<TableCell>;
			var row:int = _numRow;
			for (var i:int = 0; i < args.length; i++) 
			{
				list.push(addItemAt(i, row, args[i]));
			}
			return list;
		}
		
		/**
		 * 
		 * @param	item
		 */
		public function removeItem(item:Component):void
		{
			item.removeEventListener(Event.RESIZE, item_resizeHandler);
			
			var cell:TableCell = cellLink[item];
			if (!cell) return;
			
			delete cellLink[item];
			removeCell(cell);
		}
		
		public function removeCell(cell:TableCell):void 
		{
			if (cell.component)
			{
				cell.component.removeEventListener(Event.RESIZE, item_resizeHandler);
			}
			cell.component = null;
			VectorUtil.deleteItem(cellList, cell);
			delete cellGrid[getKey(cell.x, cell.y)];
		}
		
		//--------------------------------------------------------------------------
		//
		//  情報取得
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 指定コンポーネントの行列インデックスを取得
		 * @param	item
		 * @return
		 */
		public function getPosition(item:Component):Point
		{
			var cell:TableCell = cellLink[item];
			if (!cell) return null;
			return new Point(cell.x, cell.y);
		}
		
		/**
		 * 行列インデックスでセルを取得
		 * @param	x
		 * @param	y
		 * @return
		 */
		public function getCellAt(x:int, y:int):TableCell
		{
			return cellGrid[getKey(x, y)];
		}
		
		/**
		 * コンポーネントでセルを取得
		 * @param	item
		 * @return
		 */
		public function getCell(item:Component):TableCell
		{
			return cellLink[item] as TableCell;
		}
		
		//--------------------------------------------------------------------------
		//
		//  各種情報設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 行列インデックス位置にあるセルの位置揃えを設定
		 * @param	x
		 * @param	y
		 * @param	alignX
		 * @param	alignY
		 */
		public function alignCellAt(x:int, y:int, alignX:String, alignY:String):void
		{
			var cell:TableCell = getCellAt(x, y);
			if (!cell) return;
			
			if (alignX) cell.alignX = alignX;
			if (alignY) cell.alignY = alignY;
		}
		
		/**
		 * 横インデックス位置指定で縦のセルに一括で位置揃えを設定
		 * @param	x
		 * @param	alignX
		 * @param	alignY
		 */
		public function alignColumnCells(x:int, alignX:String, alignY:String):void
		{
			for (var i:int = 0; i < _numRow; i++) 
			{
				var cell:TableCell = getCellAt(x, i);
				if (!cell) continue;
				if (alignX) cell.alignX = alignX;
				if (alignY) cell.alignY = alignY;
			}
		}
		
		/**
		 * 縦インデックス位置指定で横のセルに一括で位置揃えを設定
		 * @param	y
		 * @param	alignX
		 * @param	alignY
		 */
		public function alignRowCells(y:int, alignX:String, alignY:String):void
		{
			for (var i:int = 0; i < _numColumn; i++) 
			{
				var cell:TableCell = getCellAt(i, y);
				if (!cell) continue;
				cell.alignX = alignX;
				cell.alignY = alignY;
			}
		}
		
		/**
		 * コンポーネントのオフセット位置を設定
		 * @param	item
		 * @param	x
		 * @param	y
		 */
		public function setOffset(item:Component, x:Number, y:Number):void
		{
			var cell:TableCell = cellLink[item];
			if (!cell) return;
			
			cell.offset.x = x;
			cell.offset.y = y;
		}
		
		//--------------------------------------------------------------------------
		//
		//  描画処理
		//
		//--------------------------------------------------------------------------
		
		public function update():void
		{
			var col:Array = [];
			var row:Array = [];
			var cell:TableCell;
			
			var xMax:int = -1;
			var yMax:int = -1;
			for each (cell in cellList)
			{
				var w:Number = cell.component.width + cell.offset.x;
				var h:Number = cell.component.height + cell.offset.y;
				if (w > (col[cell.x] || 0))
				{
					col[cell.x] = w;
				}
				if (h > (row[cell.y] || 0))
				{
					row[cell.y] = h;
				}
				if (xMax  < cell.x) xMax = cell.x;
				if (yMax  < cell.y) yMax = cell.y;
			}
			
			var i:int;
			var xpos:Array = [];
			var ypos:Array = [];
			var xCount:int = 0;
			var yCount:int = 0;
			
			for (i = 0; i < col.length; i++)
			{
				xpos[i] = xCount;
				xCount += (col[i] || 0) + _columnSpacing;
			}
			for (i = 0; i < row.length; i++)
			{
				ypos[i] = yCount;
				yCount += (row[i] || 0) + _rowSpacing;
			}
			for each (cell in cellList)
			{
				var tx:Number;
				var ty:Number;
				var spaceX:Number = col[cell.x] - cell.component.width;
				var spaceY:Number = row[cell.y] - cell.component.height;
				switch(cell.alignX)
				{
					case ALIGN_CENTER	: tx = xpos[cell.x] + spaceX * 0.5; break;
					case ALIGN_RIGHT	: tx = xpos[cell.x] + spaceX; break;
					default				: tx = xpos[cell.x];
				}
				switch(cell.alignY)
				{
					case ALIGN_MIDDLE	: ty = ypos[cell.y] + spaceY * 0.5; break;
					case ALIGN_BOTTOM	: ty = ypos[cell.y] + spaceY; break;
					default				: ty = ypos[cell.y];
				}
				cell.component.x = tx + cell.offset.x;
				cell.component.y = ty + cell.offset.y;
			}
			
			width = xCount;
			height = yCount;
			_numColumn = xMax + 1;
			_numRow = yMax + 1;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function item_resizeHandler(e:Event):void
		{
			update();
		}
		
		private function getKey(x:int, y:int):String 
		{
			return x + "," + y;
		}
	
	}

}