package net.morocoshi.common.graphics 
{
	import flash.display.BitmapData;
	
	/**
	 * ピクセル描画系処理
	 * 
	 * @author tencho
	 */
	public class PixelDraw
	{
		
		/**
		 * BitmapDataに直線を描画する
		 * @param	bmd
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @param	argb
		 * @param	skipFirst
		 */
		static public function line(bmd:BitmapData, x1:int, y1:int, x2:int, y2:int, argb:uint, skipFirst:Boolean = false):void
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