package net.morocoshi.components.minimal.color 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import net.morocoshi.graphics.Palette;
	/**
	 * ...
	 * @author tencho
	 */
	public class HueRing extends Sprite
	{
		private var ringColor:Bitmap;
		private var ringLine:Sprite;
		
		public function HueRing(radius:int, thickness:Number, line:Number) 
		{
			super();
			ringColor = new Bitmap(createGradientRing(radius - 1, thickness - 1));
			ringColor.x = ringColor.y = 1 - radius;
			ringLine = new Sprite();
			ringLine.graphics.beginFill(0x0, 1);
			ringLine.graphics.drawCircle(0, 0, radius);
			ringLine.graphics.drawCircle(0, 0, radius - line);
			ringLine.graphics.beginFill(0x0, 1);
			ringLine.graphics.drawCircle(0, 0, radius - thickness + line);
			ringLine.graphics.drawCircle(0, 0, radius - thickness);
			addChild(ringColor);
			addChild(ringLine);
		}
		
		private function createGradientRing(radius:int, thickness:Number):BitmapData
		{
			var size:Number = radius * 2;
			var bmd:BitmapData = new BitmapData(size, size, true, 0);
			bmd.lock();
			for (var ix:int = 0; ix < size; ix++) 
			for (var iy:int = 0; iy < size; iy++) 
			{
				var tx:Number = ix - radius;
				var ty:Number = iy - radius;
				var h:Number = Math.atan2(-ty, tx) / Math.PI * 180;
				var rate:Number = Math.sqrt(tx * tx + ty * ty) / radius;
				var minRate:Number = 1 - thickness / radius;
				var a:uint = (rate < minRate)? 0 : (rate > 1)? 0 : 0xFF000000;
				var rgb:uint = a | Palette.HLStoRGB(h, 0.5, 1);
				bmd.setPixel32(ix, iy, rgb);
			}
			bmd.unlock();
			return bmd;
		}
		
	}

}