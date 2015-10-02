package net.morocoshi.common.partitioning.cell2 
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Cell2DItem 
	{
		public var world:Cell2DSpacePartition;
		/**未実装*/
		public var enabled:Boolean;
		/**登録されている空間*/
		public var linkSpace:Dictionary;
		/**関連付けられているデータ*/
		public var data:*;
		
		//このアイテムの矩形を構成する4点の所属セルインデックス
		private var x0:int = -1;
		private var x1:int = -1;
		private var y0:int = -1;
		private var y1:int = -1;
		//衝突判定チェック用
		private var frame:int = -1;
		
		internal var _left:Number;
		internal var _top:Number;
		internal var _right:Number;
		internal var _bottom:Number;
		internal var _width:Number;
		internal var _height:Number;
		
		/**このアイテムと接触する可能性のある他のアイテム*/
		public var collisionList:Vector.<Cell2DItem>;
		
		public function Cell2DItem() 
		{
			enabled = true;
			linkSpace = new Dictionary();
			collisionList = new Vector.<Cell2DItem>;
		}
		
		/**
		 * 既に衝突判定を行ったかどうか
		 */
		public function get checked():Boolean
		{
			return frame == world.frame;
		}
		
		/**
		 * 既に衝突判定をしたらフラグを立てておく
		 */
		public function setChecked():void
		{
			frame = world.frame;
		}
		
		/**
		 * このアイテムをリサイズしてセルへの所属を登録しなおす
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @return
		 */
		public function resize(x:Number, y:Number, width:Number, height:Number):Boolean
		{
			_left = x;
			_top = y;
			_width = width;
			_height = height;
			_right = x + width;
			_bottom = y + height;
			
			if (!world) return false;
			
			var ix0:int = world.getIndexX(_left);
			var ix1:int = world.getIndexX(_right);
			var iy0:int = world.getIndexY(_top);
			var iy1:int = world.getIndexY(_bottom);
			
			//所属セルが変化しなければ終了
			if (x0 == ix0 && x1 == ix1 && y0 == iy0 && y1 == iy1)
			{
				return false;
			}
			
			x0 = ix0;
			x1 = ix1;
			y0 = iy0;
			y1 = iy1;
			
			//いったんセルから削除
			remove();
			
			//新しいセルへ再登録
			var space:Dictionary;
			for (var ix:int = ix0; ix <= ix1; ix++) 
			for (var iy:int = iy0; iy <= iy1; iy++) 
			{
				var index:int = ix + iy * world._segmentW;
				space = world._spaceList[index];
				space[this] = this;
				linkSpace[space] = space;
			}
			return true;
		}
		
		/**
		 * このアイテムを登録されているセルから切り離す
		 */
		public function remove():void 
		{
			for each(var space:Dictionary in linkSpace)
			{
				delete space[this];
				delete linkSpace[space];
			}
		}
		
		/**
		 * このアイテムと接触する可能性のあるアイテムをリストアップする
		 */
		public function updateCollision():void 
		{
			if (!collisionList)
			{
				collisionList = new Vector.<Cell2DItem>;
			}
			else
			{
				collisionList.length = 0;
			}
			
			var cache:Dictionary = new Dictionary();
			//自分の所属しているセル内のアイテムを全てチェック
			for each(var space:Dictionary in linkSpace)
			{
				for each(var item:Cell2DItem in space)
				{
					//複数セルにまたがっている同じアイテムは重複して調べない
					if (item == this || cache[item]) continue;
					collisionList.push(item);
					cache[item] = true;
				}
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
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
	}

}