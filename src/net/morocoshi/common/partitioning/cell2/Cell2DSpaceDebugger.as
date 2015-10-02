package net.morocoshi.common.partitioning.cell2 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Cell2DSpaceDebugger 
	{
		public var sprite:Sprite;
		private var partition:Cell2DSpacePartition;
		private var boxCanvas:BitmapData;
		private var lineCanvas:BitmapData;
		private var boxBmp:Bitmap;
		private var lineBmp:Bitmap;
		private var grid:Sprite;
		private var rect:Rectangle;
		private var _drawConnection:Boolean;
		
		public function Cell2DSpaceDebugger() 
		{
			rect = new Rectangle();
			sprite = new Sprite();
			grid = new Sprite();
			grid.cacheAsBitmap = true;
			_drawConnection = false;
			
			lineBmp = new Bitmap(null, "auto", true);
			boxBmp = new Bitmap(null, "auto", true);
			
			sprite.addChild(grid);
			sprite.addChild(lineBmp);
			sprite.addChild(boxBmp);
		}
		
		/**
		 * セル空間を指定して初期化
		 * @param	tree
		 */
		public function setCellSpace(partition:Cell2DSpacePartition):void
		{
			this.partition = partition;
			
			boxCanvas = new BitmapData(partition.width, partition.height, true, 0);
			lineCanvas = new BitmapData(partition.width, partition.height, true, 0);
			boxBmp.x = lineBmp.x = partition.left;
			boxBmp.y = lineBmp.y = partition.top;
			lineBmp.bitmapData = lineCanvas;
			boxBmp.bitmapData = boxCanvas;
			drawGrid();
		}
		
		/**
		 * 描画更新
		 */
		public function update():void
		{
			boxCanvas.lock();
			lineCanvas.lock();
			boxCanvas.fillRect(boxCanvas.rect, 0);
			lineCanvas.fillRect(lineCanvas.rect, 0);
			
			for each (var space:Dictionary in partition.spaceList)
			{
				for each (var item:Cell2DItem in space) 
				{
					var hit:Boolean = item.collisionList.length > 0;
					var rgb:uint = hit? 0xFF4444 : 0x444444;
					if (_drawConnection)
					{
						for each(var target:Cell2DItem in item.collisionList)
						{
							line(lineCanvas, (item._left + item._right) / 2 - lineBmp.x, (item._top + item._bottom) / 2 - lineBmp.y, (target._left + target._right) / 2 - lineBmp.x, (target._top + target._bottom) / 2 - lineBmp.y, 0xa0dd8888);
						}
					}
					fillRect(item, rgb, 0.5);
				}
			}
			
			boxCanvas.unlock();
			lineCanvas.unlock();
		}
		
		private function fillRect(item:Cell2DItem, rgb:uint, alpha:Number = 1):void 
		{
			rect.x = item.left - boxBmp.x;
			rect.y = item.top - boxBmp.y;
			rect.width = item.width;
			rect.height = item.height;
			var a:uint = alpha * 0xFF;
			if (a < 0x00) a = 0x00;
			if (a > 0xFF) a = 0xFF;
			boxCanvas.fillRect(rect, a << 24 | rgb);
		}
		
		private function drawGrid():void 
		{
			var rgb:uint;
			var g:Graphics = grid.graphics;
			g.clear();
			for (var ix:int = 0; ix <= partition.segmentW; ix++)
			{
				rgb = (ix == partition.segmentW / 2)? 0x666666 : 0xDDDDDD;
				g.lineStyle(1, rgb, 1, true);
				var x:Number = ix * partition.width / partition.segmentW + partition.left;
				g.moveTo(x, partition.top);
				g.lineTo(x, partition.bottom);
			}
			for (var iy:int = 0; iy <= partition.segmentH; iy++) 
			{
				rgb = (iy == partition.segmentH / 2)? 0x666666 : 0xDDDDDD;
				g.lineStyle(1, rgb, 1, true);
				var y:Number = iy * partition.height / partition.segmentH + partition.top;
				g.moveTo(partition.left, y);
				g.lineTo(partition.left + partition.width, y);
			}
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
		
		public function get drawConnection():Boolean 
		{
			return _drawConnection;
		}
		
		public function set drawConnection(value:Boolean):void 
		{
			_drawConnection = value;
		}
		
	}

}