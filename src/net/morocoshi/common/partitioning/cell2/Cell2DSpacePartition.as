package net.morocoshi.common.partitioning.cell2 
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Cell2DSpacePartition 
	{
		public var frame:int;
		internal var _left:Number;
		internal var _top:Number;
		internal var _right:Number;
		internal var _bottom:Number;
		internal var _cellWidth:Number;
		internal var _cellHeight:Number;
		internal var _segmentW:int;
		internal var _segmentH:int;
		internal var _spaceList:Vector.<Dictionary>;
		private var collisionList:Vector.<Cell2DItem>;
		
		public function Cell2DSpacePartition() 
		{
			_spaceList = new Vector.<Dictionary>;
			collisionList = new Vector.<Cell2DItem>;
		}
		
		public function build(left:Number, top:Number, width:Number, height:Number, segmentW:int, segmentH:int):void
		{
			_left = left;
			_top = top;
			_right = _left + width;
			_bottom = _top + height;
			_cellWidth = width / segmentW;
			_cellHeight = height / segmentH;
			_segmentW = segmentW;
			_segmentH = segmentH;
			
			for (var ix:int = 0; ix < segmentW; ix++) 
			for (var iy:int = 0; iy < segmentH; iy++) 
			{
				_spaceList.push(new Dictionary());
			}
		}
		
		public function get left():Number 
		{
			return _left;
		}
		
		public function get top():Number 
		{
			return _top;
		}
		
		public function get right():Number 
		{
			return _right;
		}
		
		public function get bottom():Number 
		{
			return _bottom;
		}
		
		public function get cellWidth():Number 
		{
			return _cellWidth;
		}
		
		public function get cellHeight():Number 
		{
			return _cellHeight;
		}
		
		public function get width():Number 
		{
			return _right - _left;
		}
		
		public function get height():Number 
		{
			return _bottom - _top;
		}
		
		public function get segmentW():int 
		{
			return _segmentW;
		}
		
		public function get segmentH():int 
		{
			return _segmentH;
		}
		
		public function get spaceList():Vector.<Dictionary> 
		{
			return _spaceList;
		}
		
		/**
		 * アイテムを空間内に追加
		 * @param	item
		 * @return
		 */
		public function addItem(item:Cell2DItem):Cell2DItem
		{
			item.world = this;
			item.resize(item.left, item.top, item.width, item.height);
			return item;
		}
		
		/**
		 * アイテムを空間から削除
		 * @param	item
		 */
		public function removeItem(item:Cell2DItem):void 
		{
			item.remove();
			item.world = null;
		}
		
		public function createItem(x:Number, y:Number, width:Number, height:Number, data:*):Cell2DItem 
		{
			var item:Cell2DItem = new Cell2DItem();
			item.world = this;
			item.data = data;
			item.resize(x, y, width, height);
			return item;
		}
		
		public function getIndexX(x:Number):int 
		{
			var tx:int = (x - _left) / _cellWidth;
			if (tx < 0) tx = 0;
			if (tx >= _segmentW) tx = _segmentW - 1;
			return tx;
		}
		
		public function getIndexY(y:Number):int 
		{
			var ty:int = (y - _top) / _cellHeight;
			if (ty < 0) ty = 0;
			if (ty >= _segmentH) ty = _segmentH - 1;
			return ty;
		}
		
		public function getCollisionList(left:Number, top:Number, right:Number, bottom:Number):Vector.<Cell2DItem> 
		{
			collisionList.length = 0;
			
			var ix0:int = getIndexX(left);
			var ix1:int = getIndexX(right);
			var iy0:int = getIndexY(top);
			var iy1:int = getIndexY(bottom);
			
			var cache:Dictionary = new Dictionary();
			
			for (var ix:int = ix0; ix <= ix1; ix++) 
			for (var iy:int = iy0; iy <= iy1; iy++) 
			{
				var index:int = ix + iy * _segmentW;
				var space:Dictionary = _spaceList[index];
				for each(var item:Cell2DItem in space)
				{
					if (cache[item]) continue;
					cache[item] = true;
					collisionList.push(item);
				}
			}
			return collisionList;
		}
		
		/**
		 * 時間を進めて衝突済みフラグをリセットする
		 */
		public function step():void 
		{
			frame++;
		}
		
	}

}