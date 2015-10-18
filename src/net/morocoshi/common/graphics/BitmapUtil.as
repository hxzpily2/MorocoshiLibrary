package net.morocoshi.common.graphics
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.StageQuality;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * BitmapData処理色々
	 */
	public class BitmapUtil
	{
		/**縦or横に使えるピクセルの限界(Player10以上用)*/
		static public const MAXSIZE_FP10:int = 8191;
		/**縦or横に使えるピクセルの限界(Player9用)*/
		static public const MAXSIZE_FP9:int = 2880;
		/**縦×横の総ピクセル数の限界(Player10以上用)*/
		static public const MAXPIXELS:int = 16777215;
		
		public function BitmapUtil()
		{
		}
		
		/**
		 * 画像の透明な部分をトリミングする
		 * @param	bmd
		 * @return
		 */
		static public function trimTransparent(bmd:BitmapData):BitmapData
		{
			return trim(bmd, bmd.getColorBoundsRect(0xFF000000, 0x00000000, false));
		}
		
		/**
		 * 画像をトリミングする
		 * @param	bmd
		 * @param	rect
		 * @return
		 */
		static public function trim(bmd:BitmapData, rect:Rectangle):BitmapData
		{
			var img:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			img.copyPixels(bmd, rect, new Point());
			return img;
		}
		
		/**
		 * 画像サイズが限界を超えているか(Player9用)
		 * @param	width
		 * @param	height
		 * @return
		 */
		static public function isOverFP9(width:int, height:int):Boolean
		{
			return (width > MAXSIZE_FP9 || height > MAXSIZE_FP9);
		}
		
		/**
		 * 画像サイズが限界を超えているか(Player10以上用)
		 * @param	width
		 * @param	height
		 * @return
		 */
		static public function isOverFP10(width:int, height:int):Boolean
		{
			return (width > MAXSIZE_FP10 || height > MAXSIZE_FP10 || width * height > MAXPIXELS);
		}
		
		/**
		 * 画像を指定サイズで分割する
		 * @param	bmd
		 * @param	width
		 * @param	height
		 * @param	xnum
		 * @param	ynum
		 * @param	limit
		 * @return
		 */
		static public function split(bmd:BitmapData, width:int, height:int, xnum:int = 0, ynum:int = 0, limit:int = 0):Vector.<BitmapData>
		{
			if (xnum <= 0) xnum = int.MAX_VALUE;
			if (ynum <= 0) ynum = int.MAX_VALUE;
			if (limit <= 0) limit = int.MAX_VALUE;
			var wnum:int = Math.min(xnum, bmd.width / width);
			var hnum:int = Math.min(ynum, bmd.height / height);
			var num:Number = Math.min(wnum * hnum, limit);
			var bmds:Vector.<BitmapData> = new Vector.<BitmapData>();
			for (var i:int = 0; i < num; i++)
			{
				var tx:int = i % wnum * width;
				var ty:int = (i / wnum | 0) * height;
				var splitBmd:BitmapData = new BitmapData(width, height, true, 0);
				splitBmd.copyPixels(bmd, new Rectangle(tx, ty, width, height), new Point(), null, null, true);
				bmds.push(splitBmd);
			}
			return bmds;
		}
		
		/**
		 * BitmapDataを透明度の有無を変更した新しいBitmapDataを返す。無しにした場合はアルファチャンネルが削除される
		 * @param	image
		 * @param	transparent
		 * @return
		 */
		static public function setTransparent(image:BitmapData, transparent:Boolean):BitmapData
		{
			var color:uint = transparent? 0xff000000 : 0x000000;
			var result:BitmapData = new BitmapData(image.width, image.height, transparent, color);
			result.copyChannel(image, image.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
			result.copyChannel(image, image.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.RED);
			result.copyChannel(image, image.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
			if (transparent)
			{
				result.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}
			return result;
		}
		
		/**
		 * リサイズした新しいBitmapDataを生成する
		 * @param	bmd
		 * @param	width
		 * @param	height
		 * @param	smoothing
		 * @return
		 */
		static public function resize(bmd:BitmapData, width:int, height:int, smoothing:Boolean = true, quality:String = StageQuality.HIGH):BitmapData
		{
			var img:BitmapData = new BitmapData(width, height, bmd.transparent, 0);
			var scale:Matrix = new Matrix(width / bmd.width, 0, 0, height / bmd.height);
			if (img.hasOwnProperty("drawWithQuality"))
			{
				img["drawWithQuality"](bmd, scale, null, null, null, smoothing, quality);
			}
			else
			{
				img.draw(bmd, scale, null, null, null, smoothing);
			}
			return img;
		}
		
		/**
		 * colorTransform()した新しいBitmapDataを生成する
		 * @param	bmd
		 * @param	redMultiplier
		 * @param	greenMultiplier
		 * @param	blueMultiplier
		 * @param	alphaMultiplier
		 * @param	redOffset
		 * @param	greenOffset
		 * @param	blueOffset
		 * @param	alphaOffset
		 * @return
		 */
		static public function colorTransform(bmd:BitmapData, redMultiplier:Number = 1, greenMultiplier:Number = 1, blueMultiplier:Number = 1, alphaMultiplier:Number = 1, redOffset:Number = 0, greenOffset:Number = 0, blueOffset:Number = 0, alphaOffset:Number = 0):BitmapData 
		{
			var image:BitmapData = bmd.clone();
			image.colorTransform(image.rect, new ColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset));
			return image;
		}
		
		static public function changePixelAlpha(bmd:BitmapData, min:uint, max:uint, alpha:uint):void 
		{
			bmd.lock();
			
			var alpha32:uint = alpha << 24;
			var colors:Vector.<uint> = bmd.getVector(bmd.rect);
			var n:int = colors.length;
			for (var i:int = 0; i < n; i++)
			{
				var argb:uint = colors[i];
				var a:uint = argb >> 24;
				if (a >= min && a <= max)
				{
					colors[i] = alpha32 | (argb & 0xffffff);
				}
			}
			bmd.setVector(bmd.rect, colors);
			
			bmd.unlock();
		}
		
		/**
		 * 透明ピクセルが存在するかチェック
		 * @param	image
		 * @return
		 */
		static public function isTransparent(image:BitmapData):Boolean 
		{
			return (image.transparent && image.getColorBoundsRect(0xff000000, 0xff000000, false).width > 0);
		}
		
		/**
		 * アルファチャンネル画像を取得する
		 * @param	image
		 */
		static public function toAlphaChannel(image:BitmapData):BitmapData 
		{
			var result:BitmapData = new BitmapData(image.width, image.height, false, 0xffffff);
			if (image.transparent == false) return result;
			
			result.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
			result.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
			result.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
			
			return result;
		}
		
	}
	
}