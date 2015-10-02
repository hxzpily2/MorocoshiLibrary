package net.morocoshi.common.partitioning.quadtree 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * 四分木領域描画用クラス
	 * 
	 * @author tencho
	 */
	public class QuadTreeDebugger
	{
		
		public var sprite:Sprite = new Sprite();
		
		private var tree:QuadTree;
		private var grid:Sprite = new Sprite();
		private var boxCanvas:BitmapData;
		private var lineCanvas:BitmapData;
		private var rect:Rectangle = new Rectangle();
		private var _drawAlpha:Number = 0.4;
		private var _drawConnection:Boolean = true;
		private var _drawCollision:Boolean = true;
		private var _numIntersect:int = 0;
		private var lineBmp:Bitmap
		private var boxBmp:Bitmap;
		
		/**
		 * コンストラクタ
		 */
		public function QuadTreeDebugger() 
		{
			grid.cacheAsBitmap = true;
			
			sprite.addChild(grid);
			lineBmp = new Bitmap(null, "auto", true);
			boxBmp = new Bitmap(null, "auto", true);
			sprite.addChild(lineBmp);
			sprite.addChild(boxBmp);
		}
		
		/**衝突ペア同士を結ぶラインを描画する*/
		public function get drawConnection():Boolean { return _drawConnection; }
		public function set drawConnection(value:Boolean):void { _drawConnection = value; }
		
		/**交差判定数*/
		public function get numIntersect():int { return _numIntersect; }
		
		/**コリジョン矩形の塗りの不透明度*/
		public function get drawAlpha():Number { return _drawAlpha; }
		public function set drawAlpha(value:Number):void { _drawAlpha = value; }
		
		/**コリジョン矩形を描画する*/
		public function get drawCollision():Boolean { return _drawCollision; }
		public function set drawCollision(value:Boolean):void { _drawCollision = value; }
		
		/**
		 * 四分木空間を指定して初期化
		 * @param	tree
		 */
		public function setQuadTree(tree:QuadTree):void
		{
			this.tree = tree;
			var seg:int = Math.pow(2, tree.level);
			boxCanvas = new BitmapData(tree.rect.width, tree.rect.height, true, 0);
			lineCanvas = new BitmapData(tree.rect.width, tree.rect.height, true, 0);
			boxBmp.x = lineBmp.x = tree.rect.x;
			boxBmp.y = lineBmp.y = tree.rect.y;
			lineBmp.bitmapData = lineCanvas;
			boxBmp.bitmapData = boxCanvas;
			drawGrid(grid.graphics, tree.rect, seg, seg);
		}
		
		private function drawGrid(g:Graphics, rect:Rectangle, segW:int, segH:int):void 
		{
			var rgb:uint;
			g.clear();
			for (var ix:int = 0; ix <= segW; ix++)
			{
				rgb = (ix == segW / 2)? 0x666666 : 0xDDDDDD;
				g.lineStyle(1, rgb, 1, true);
				var x:Number = ix * rect.width / segW + rect.x;
				g.moveTo(x, rect.top);
				g.lineTo(x, rect.bottom);
			}
			for (var iy:int = 0; iy <= segH; iy++) 
			{
				rgb = (iy == segH / 2)? 0x666666 : 0xDDDDDD;
				g.lineStyle(1, rgb, 1, true);
				var y:Number = iy * rect.height / segH + rect.y;
				g.moveTo(rect.left, y);
				g.lineTo(rect.right, y);
			}
		}
		
		/**
		 * 描画更新
		 */
		public function update():void
		{
			boxCanvas.fillRect(boxCanvas.rect, 0);
			lineCanvas.fillRect(lineCanvas.rect, 0);
			boxCanvas.lock();
			lineCanvas.lock();
			//
			_numIntersect = 0;
			for each (var cell:TreeCell in tree.cells)
			{
				if (!cell) continue;
				var data:TreeData = cell.root;
				while (data)
				{
					var hit:Boolean = false;
					var next:TreeData = data.next;
					_numIntersect += data.collisions.length;
					for each(var target:TreeData in data.collisions)
					{
						if(_drawConnection) line(lineCanvas, (data._left + data._right) / 2 - lineBmp.x, (data._top + data._bottom) / 2 - lineBmp.y, (target._left + target._right) / 2 - lineBmp.x, (target._top + target._bottom) / 2 - lineBmp.y, 0xa0dd8888);
						if (!hit) hit = intersect(data, target);
					}
					if (_drawCollision)
					{
						var rgb:uint = !data._useHitList ? 0x444444 : hit? 0xFF2A00 : 0x0000FF;
						fillRect(data, rgb, _drawAlpha);
					}
					data = next;
				}
			}
			//
			boxCanvas.unlock();
			lineCanvas.unlock();
		}
		
		private function intersect(a:TreeData, b:TreeData):Boolean
		{
			return !(a._right < b._left || a._left > b._right || a._bottom < b._top || a._top > b._bottom);
		}
		
		private function fillRect(data:TreeData, rgb:uint, alpha:Number = 1):void 
		{
			rect.x = data._left - boxBmp.x;
			rect.y = data._top - boxBmp.y;
			rect.width = data._width;
			rect.height = data._height;
			var a:uint = alpha * 0xFF;
			if (a < 0x00) a = 0x00;
			if (a > 0xFF) a = 0xFF;
			boxCanvas.fillRect(rect, a << 24 | rgb);
		}
		
		private function line(bmd:BitmapData, x1:int, y1:int, x2:int, y2:int, argb:uint, skipFirst:Boolean = false):void
		{
			var dx:int = (x2 > x1)? x2 - x1 : x1 - x2;
			var dy:int = (y2 > y1)? y2 - y1 : y1 - y2;
			var tx:int = (x2 > x1)? 1 : -1
			var ty:int = (y2 > y1)? 1 : -1;
			var e:int, i:int, x:int = x1, y:int = y1;
			if (dx >= dy)
			{
				e = 2 * dy - dx;
				for (i = 0; i <= dx; i++)
				{
					if (!skipFirst || i) bmd.setPixel32(x, y, argb);
					x += tx;
					e += 2*dy;
					if (e >= 0)
					{
						y += ty;
						e -= 2 * dx;
					}
				}
			}
			else
			{
				e = 2 * dx - dy;
				for (i = 0; i <= dy; i++)
				{
					if (!skipFirst || i) bmd.setPixel32(x, y, argb);
					y += ty;
					e += 2 * dx;
					if (e >= 0)
					{
						x += tx;
						e -= 2 * dy;
					}
				}
			}
		}
		
	}

}