package net.morocoshi.common.partitioning.quadtree 
{
	/**
	 *　四分木用コリジョンデータ
	 * 
	 * @author tencho
	 */
	public class TreeData
	{
		/**任意データ*/
		public var data:*;
		/**衝突リスト*/
		public var collisions:Vector.<TreeData> = new Vector.<TreeData>;
		
		/**四分木管理*/
		internal var tree:QuadTree;
		/**登録されている空間*/
		internal var cell:TreeCell;
		/**前のデータ*/
		internal var prev:TreeData;
		/**次のデータ*/
		internal var next:TreeData;
		/**最後に格納されていたセル番号*/
		internal var cellNum:int = -1;
		
		internal var _enabled:Boolean = true;
		internal var _useHitList:Boolean = true;
		internal var _left:Number = 0;
		internal var _top:Number = 0;
		internal var _right:Number = 0;
		internal var _bottom:Number = 0;
		internal var _width:Number = 0;
		internal var _height:Number = 0;
		
		/**
		 * コンストラクタ
		 * @param	data	任意データ
		 * @param	x	コリジョン矩形のX座標
		 * @param	y	コリジョン矩形のY座標
		 * @param	width	コリジョン矩形の幅
		 * @param	height	コリジョン矩形の高さ
		 */
		public function TreeData(data:* = null, x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) 
		{
			setRect(x, y, width, height);
			this.data = data;
		}
		
		public function get x():Number { return _left; }
		public function set x(value:Number):void
		{
			_left = value;
			_right = _left + _width;
			if(tree) tree.resizeData(this);
		}
		
		public function get y():Number { return _top; }
		public function set y(value:Number):void
		{
			_top = value;
			_bottom = _top + _height;
			if(tree) tree.resizeData(this);
		}
		
		public function get width():Number { return _width; }
		public function set width(value:Number):void
		{
			_width = value;
			_left = _right + _width;
			if(tree) tree.resizeData(this);
		}
		
		public function get height():Number { return _height; }
		public function set height(value:Number):void
		{
			_height = value;
			_bottom = _top + _height;
			if(tree) tree.resizeData(this);
		}
		
		/**自分自身の衝突リストを使うか*/
		public function get useHitList():Boolean { return _useHitList; }
		public function set useHitList(value:Boolean):void { _useHitList = value; }
		
		/**交差判定処理の対象か*/
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void { _enabled = value; }
		
		/**
		 * コリジョン矩形のサイズ変更
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 */
		public function setRect(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0):void
		{
			_left = x;
			_top = y;
			_width = width;
			_height = height;
			_right = x + width;
			_bottom = y + height;
			if(tree) tree.resizeData(this);
		}
		
		internal function remove():Boolean
		{
			if (!cell) return false;
			cell.remove(this);
			if (prev) prev.next = next;
			if (next) next.prev = prev;
			prev = null;
			next = null;
			cell = null;
			return true;
		}
		
		public function dispose():void
		{
			remove();
			data = null;
			tree = null;
			cellNum = -1;
			collisions.length = 0;
		}
		
	}
}