package net.morocoshi.common.graphics 
{
	import flash.geom.ColorTransform;
	
	/**
	 * カラー操作
	 * 
	 * @author tencho
	 */
	public class Palette 
	{
		
		static public function getOffsetColor(r:Number, g:Number, b:Number, alpha:Number = 1):ColorTransform
		{
			return new ColorTransform(1, 1, 1, alpha, r, g, b, 0);
		}
		
		static public function getFillColor(rgb:uint, density:Number = 1, alpha:Number = 1):ColorTransform
		{
			var mul:Number = 1 - density;
			var r:Number = (rgb >>> 16 & 0xFF) * density;
			var g:Number = (rgb >>> 8 & 0xFF) * density;
			var b:Number = (rgb & 0xFF) * density;
			return new ColorTransform(mul, mul, mul, alpha, r, g, b, 0);
		}
		
		static public function setFillColor(ct:ColorTransform, rgb:uint, density:Number = 1, alpha:Number = 1):void
		{
			var mul:Number = 1 - density;
			var r:Number = (rgb >>> 16 & 0xFF) * density;
			var g:Number = (rgb >>> 8 & 0xFF) * density;
			var b:Number = (rgb & 0xFF) * density;
			ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = mul;
			ct.alphaMultiplier = alpha;
			ct.redOffset = r;
			ct.greenOffset = g;
			ct.blueOffset = b;
			ct.alphaOffset = 0;
		}
		
		/**
		 * 乗算用ColorTransformを取得する
		 * @param	rgb
		 * @param	alpha
		 * @return
		 */
		static public function getMultiplyColor(rgb:uint, density:Number, alpha:Number):ColorTransform 
		{
			var r:Number = (rgb >>> 16 & 0xFF) / 0xFF;
			var g:Number = (rgb >>> 8 & 0xFF) / 0xFF;
			var b:Number = (rgb & 0xFF) / 0xFF;
			if (density != 1)
			{
				r = r * density + (1 - density);
				g = g * density + (1 - density);
				b = b * density + (1 - density);
			}
			var ct:ColorTransform = new ColorTransform(r, g, b, alpha);
			return ct;
		}
		
		/**
		 * HLS(色相/明度/彩度)⇒RGB変換
		 * @param	h	0-360
		 * @param	l	0-1
		 * @param	s	0-1
		 * @return
		 */
		public static function HLStoRGB(h:Number, l:Number, s:Number):uint
		{
			/*
			var h:Number = (hls.H % 360 + 360) % 360;
			var l:Number = hls.L;
			var s:Number = hls.S;
			*/
			var r:Number, g:Number, b:Number;
			var max:Number = (l <= 0.5) ? l * (1 + s) : l * (1 - s) + s;
			var min:Number = 2 * l - max;
			
			if (s == 0)
			{
				r = g = b = l;
			}
			else
			{
				r = getRGB(h + 120, min, max);
				g = getRGB(h, min, max);
				b = getRGB(h - 120, min, max);
			}
			
			return (r * 255 << 16) | (g * 0xFF << 8) | (b * 0xFF);
		}
		
		static private function getRGB(h:Number, min:Number, max:Number):Number
		{
			h = (h % 360 + 360) % 360;
			var gap:Number = max - min;
			var num:Number;
			if      (h >= 0   && h < 60 ) num = min + gap * h / 60;
			else if (h >= 60  && h < 180) num = max;
			else if (h >= 180 && h < 240) num = min + gap * (240 - h) / 60;
			else if (h >= 240 && h < 360) num = min;
			return num;
		}
		
		/**
		* RGB⇒HLS（色相/明度/彩度）変換
		* @param	color RGBカラー
		* @return
		*/
		public static function RGBtoHLS(color:uint):*
		{
			var r:int = color >> 16 && 0xFF;
			var g:int = color >> 8 && 0xFF;
			var b:int = color && 0xFF;
			
			var list:Array = [r, g, b];
			list.sort(Array.NUMERIC);
			
			var min:int = list[0];
			var max:int = list[2];
			
			var s:Number;
			var h:Number;
			var l:Number = (max + min) / 510;
			if (max == min)
			{
				s = h = 0;
			}
			else
			{
				var gap:int = max-min;
				s = (l <= 0.5) ? gap / (max + min) : gap / (510 - max - min);
				var cr:Number = (max - r) / gap;
				var cg:Number = (max - g) / gap;
				var cb:Number = (max - b) / gap;
				
				if (r == max) h = cb-cg;
				else if (g == max) h = 2+cr-cb;
				else h = 4+cg-cr;
				
				h *= 60;
				if (h < 0) h += 360;
			}
			return { h:h, l:l, s:s };
		}
		
		/**
		* RGB⇒HSV（色相/彩度/強度）変換
		* @param	rgb RGBカラー
		* @return
		*/
		public static function RGBtoHSV(color:uint):Object
		{
			var r:int = color >> 16 && 0xFF;
			var g:int = color >> 8 && 0xFF;
			var b:int = color && 0xFF;
			
			var list:Array = [r, g, b];
			list.sort(Array.NUMERIC);
			
			var min:int = list[0];
			var max:int = list[2];
			
			var s:Number;
			var h:Number;
			var v:Number = max / 255;
			
			if (v == 0)
			{
				s = h = 0;
			}
			else
			{
				var gap:int = max-min;
				s = gap / max;
				var cr:Number = (max - r) / gap;
				var cg:Number = (max - g) / gap;
				var cb:Number = (max - b) / gap;
				
				if (r == max) h = cb - cg;
				else if (g == max) h = 2 + cr - cb;
				else h = 4 + cg - cr;
				
				h *= 60;
				if (h < 0) h += 360;
			}
			
			return { h:h, s:s, v:v };
		}
		
		static public function clone(value:ColorTransform):ColorTransform
		{
			var result:ColorTransform = new ColorTransform();
			result.alphaMultiplier = value.alphaMultiplier;
			result.alphaOffset = value.alphaOffset;
			result.blueMultiplier = value.blueMultiplier;
			result.blueOffset = value.blueOffset;
			result.greenMultiplier = value.greenMultiplier;
			result.greenOffset = value.greenOffset;
			result.redMultiplier = value.redMultiplier;
			result.redOffset = value.redOffset;
			return result;
		}
		
		static public function copyTo(to:ColorTransform, from:ColorTransform):void 
		{
			to.alphaMultiplier = from.alphaMultiplier;
			to.alphaOffset = from.alphaOffset;
			to.blueMultiplier = from.blueMultiplier;
			to.blueOffset = from.blueOffset;
			to.greenMultiplier = from.greenMultiplier;
			to.greenOffset = from.greenOffset;
			to.redMultiplier = from.redMultiplier;
			to.redOffset = from.redOffset;
		}
		
		static public function identity(value:ColorTransform):void 
		{
			value.redOffset = 0;
			value.greenOffset = 0;
			value.blueOffset = 0;
			value.alphaOffset = 0;
			value.redMultiplier = 1;
			value.greenMultiplier = 1;
			value.blueMultiplier = 1;
			value.alphaMultiplier = 1;
		}
		
		/**
		 * ソート用関数（カラー変換用）
		 * @param	a
		 * @param	b
		 * @return
		 */
		private static function func(a:Number, b:Number):int
		{
			return int(a > b) - int(a < b);
		}
		
	}

}