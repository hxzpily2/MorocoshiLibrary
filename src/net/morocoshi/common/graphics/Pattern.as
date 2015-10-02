package net.morocoshi.common.graphics 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Pattern 
	{
		
		public function Pattern() 
		{
		}
		
		static public function tiling(pattern:BitmapData, width:int, height:int):BitmapData
		{
			var bmd:BitmapData = new BitmapData(width, height, true, 0);
			if (!pattern || !pattern.width || !pattern.height) return bmd;
			var W:int = Math.ceil(width / pattern.width);
			var H:int = Math.ceil(height / pattern.height);
			for (var ix:int = 0; ix < W; ix++)
			for (var iy:int = 0; iy < H; iy++)
			{
				bmd.copyPixels(pattern, pattern.rect, new Point(ix * pattern.width, iy * pattern.height));
			}
			return bmd;
		}
		
		static public function diagonal(line:int, space:int, rightUp:Boolean = true, color1:uint = 0xff000000, color2:uint = 0xffFFFFFF):BitmapData
		{
			var w:int = line + space;
			var bmd:BitmapData = new BitmapData(w, w, true, color2);
			for (var iy:int = 0; iy < w; iy++)
			for (var ix:int = 0; ix < w; ix++)
			{
				var xp:int = rightUp? w + ix - iy : ix + iy;
				var rgb:uint = (ix < line)? color1 : color2;
				bmd.setPixel32(xp % w, iy, rgb);
			}
			return bmd;
		}
		
		static public function grid(lineWidth:int = 1, lineHeight:int = 1, spaceWidth:int = 4, spaceHeight:int = 4, color1:uint = 0xff000000, color2:uint = 0xffFFFFFF):BitmapData 
		{
			var w:int = lineWidth + spaceWidth;
			var h:int = lineHeight + spaceHeight;
			var bmd:BitmapData = new BitmapData(w, h, true, color2);
			bmd.fillRect(new Rectangle(0, 0, w, lineHeight), color1);
			bmd.fillRect(new Rectangle(0, 0, lineWidth, h), color1);
			return bmd;
		}
		
		static public function cross(size:Number, argb:uint, background:uint = 0):BitmapData 
		{
			var bmd:BitmapData = new BitmapData(size, size, true, background);
			for (var i:int = 0; i < size; i++) 
			{
				bmd.setPixel32(i, i, argb);
				bmd.setPixel32(i, size - i - 1, argb);
			}
			return bmd;
		}
		
	}

}