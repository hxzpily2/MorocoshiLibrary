package net.morocoshi.common.partitioning.quadtree 
{
	import flash.geom.Rectangle;
	/**
	 * 線形四分木クラス
	 * 
	 * @author tencho
	 */
	public class QuadTree
	{
		static public const MAX_LEVEL:int = 8;
		
		private var pows:Vector.<int> = new Vector.<int>;
		private var unitW:Number;
		private var unitH:Number;
		private var stock:Vector.<TreeData> = new Vector.<TreeData>;
		private var numSplit:int;
		
		private var _level:int;
		private var _rect:Rectangle = new Rectangle();
		private var _numCells:int = 0;
		private var _cells:Vector.<TreeCell>;
		private var lastData:TreeData;
		
		/**
		 * コンストラクタ
		 */
		public function QuadTree() 
		{
		}
		
		/**四分木領域*/
		public function get rect():Rectangle { return _rect; }
		/**セルの最大数*/
		public function get numCells():int { return _numCells; }
		/**空間分割レベル*/
		public function get level():int { return _level; }
		/**生成予定の全セルリスト*/
		public function get cells():Vector.<TreeCell> { return _cells; }
		
		/**
		 * 初期化する
		 * @param	level	セルの分割レベル　1～8
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 */
		public function init(level:int, x:Number, y:Number, width:Number, height:Number):void
		{
			if (level < 1) throw new Error("分割数が少なすぎます。（最小1）");
			if (level > MAX_LEVEL) throw new Error("分割数が多すぎます。（最大" + MAX_LEVEL + "）");
			pows[0] = 1;
			for (var i:int = 1; i <= level + 1; i++) pows[i] = pows[i - 1] * 4;
			_numCells = (pows[level + 1] - 1) / 3;
			_cells = new Vector.<TreeCell>(_numCells, true);
			
			_rect.x = x;
			_rect.y = y;
			_rect.width = width;
			_rect.height = height;
			numSplit = 1 << level;
			unitW = _rect.width / numSplit;
			unitH = _rect.height / numSplit;
			_level = level;
		}
		
		/**
		 * データ登録
		 * @param	data
		 * @return
		 */
		public function addData(data:TreeData):TreeData
		{
			var num:int = getCellIndex(data._left, data._top, data._right, data._bottom);
			if (num >= _numCells) return null;
			if (!_cells[num]) createCell(num);
			data.tree = this;
			data.cellNum = num;
			_cells[num].push(data);
			return data;
		}
		
		/**
		 * データ矩形をリサイズして新しいセルに移動する。前回のセルから動いたらtrue、動かなければfalseが返る。
		 * @param	data
		 */
		internal function resizeData(data:TreeData):Boolean
		{
			if (!data.cell) return false;
			var num:int = getCellIndex(data._left, data._top, data._right, data._bottom);
			if (data.cellNum == num || num >= _numCells) return false;
			lastData = null;
			data.cellNum = num;
			data.remove();
			if (!_cells[num]) createCell(num);
			_cells[num].push(data);
			return true;
		}
		
		/**
		 * 指定コリジョンの衝突する可能性のあるコリジョンリストを更新する
		 * @param	data
		 */
		public function checkNearCollision(data:TreeData):void
		{
			//if (!data._useHitList) return;
			if (lastData == data) return;
			data.collisions.length = 0;
			addNearCollisions(data, data.cellNum, 0);
			lastData = data;
		}
		
		private function addNearCollisions(data:TreeData, index:int, child:int = 0):void
		{
			if (index >= _numCells || !_cells[index]) return;
			
			//同じセル内の他のコリジョンをリストに加える
			var data1:TreeData = _cells[index].root;
			while (data1)
			{
				if (data1 != data)
				{
					data.collisions.push(data1);
				}
				data1 = data1.next;
			}
			
			if (child <= 0)
			{
				//子のセルを辿る
				for (var i:int = 0; i < 4; i++)
				{
					var nextIndex:int = (index << 2) + 1 + i;
					if (nextIndex < _numCells) addNearCollisions(data, nextIndex, child - 1);
				}
			}
			
			if (child >= 0)
			{
				//親のセルを辿る
				index = (index - 1) >> 2;
				if (index >= 0) addNearCollisions(data, index, child + 1);
			}
		}
		
		/**
		 * 全てのコリジョンの衝突する可能性のあるコリジョンリストを更新する
		 */
		public function checkAllCollisions():void
		{
			if (!_cells[0]) return;
			stock.length = 0;
			
			for each (var cell:TreeCell in _cells) 
			{
				if (!cell) continue;
				var data:TreeData = cell.root;
				while (data)
				{
					data.collisions.length = 0;
					data = data.next;
				}
			}
			getCollisionList(0);
		}
		
		/**
		 * 空間を破棄する
		 */
		public function dispose():void 
		{
			if (!_cells) return;
			for each (var cell:TreeCell in _cells) 
			{
				if (!cell) continue;
				var data:TreeData = cell.root;
				while (data)
				{
					var next:TreeData = data.next;
					data.dispose();
					data = next;
				}
			}
			_cells = null;
		}
		
		private function getCollisionList(index:int):void 
		{
			var data1:TreeData = _cells[index].root;
			while (data1)
			{
				var data2:TreeData = data1.next;
				//同じセル内のコリジョン同士お互いにリストに加える
				while (data2)
				{
					if (data1._useHitList) data1.collisions.push(data2);
					if (data2._useHitList) data2.collisions.push(data1);
					data2 = data2.next;
				}
				//リストにストックがあればセル内のコリジョンとお互いにリストに加える
				for each(var stk:TreeData in stock)
				{
					if (data1._useHitList) data1.collisions.push(stk);
					if (stk._useHitList) stk.collisions.push(data1);
				}
				data1 = data1.next;
			}
			var noChild:Boolean = false;
			var stockNum:int = 0;
			for (var i:int = 0; i < 4; i++) 
			{
				var childIndex:int = (index << 2) + 1 + i;
				if (childIndex < _numCells && _cells[childIndex])
				{
					if (!noChild)
					{
						var data:TreeData = _cells[index].root;
						while (data)
						{
							//リストにストックする
							stock.push(data);
							stockNum++;
							data = data.next;
						}
					}
					noChild = true;
					getCollisionList(childIndex);
				}
			}
			if (noChild)
			{
				stock.length -= stockNum;
				//while (stockNum--) stock.pop();
			}
		}
		
		/**
		 * 必要なセルを作る
		 * @param	num
		 */
		private function createCell(num:int):void
		{
			//親のセルを辿って存在しないセルを全て生成する
			while (num >= 0 && num < _numCells && !_cells[num])
			{
				//isUpdated = true;
				_cells[num] = new TreeCell(this);
				num = (num - 1) >> 2;
			}
		}
		
		/**
		 * ビットを分割
		 * @param	n
		 * @return
		 */
		private function separateBit(n:uint):uint
		{
			n = (n | (n << 8)) & 0x00ff00ff;
			n = (n | (n << 4)) & 0x0f0f0f0f;
			n = (n | (n << 2)) & 0x33333333;
			return (n | (n << 1)) & 0x55555555;
		}
		
		/**
		 * モートン番号を算出
		 * @param	x
		 * @param	y
		 * @return
		 */
		private function getMorton(x:Number, y:Number):uint
		{
			x = (x - _rect.left) / unitW | 0;
			y = (y - _rect.top) / unitH | 0;
			if (x < 0) x = 0;
			if (y < 0) y = 0;
			if (x >= numSplit) x = numSplit - 1;
			if (y >= numSplit) y = numSplit - 1;
			return separateBit(x) | (separateBit(y) << 1);
		}
		
		/**
		 * 矩形から空間インデックスを取得
		 * @param	left
		 * @param	top
		 * @param	right
		 * @param	bottom
		 * @return
		 */
		private function getCellIndex(left:Number, top:Number, right:Number, bottom:Number):uint
		{
			var lt:uint = getMorton(left, top);
			var rb:uint = getMorton(right, bottom);
			var def:uint = lt ^ rb;
			var max:int = 0;
			for (var i:int = 0; i < _level; i++) 
			{
				var t:int =  (def >> (i * 2)) & 0x3;
				if (t != 0) max = i + 1;
			}
			var num:Number = (rb >> (max * 2)) + (pows[_level - max] - 1) / 3;
			if (num > _numCells) num = 0xffffffff;
			return num;
		}
		
	}

}