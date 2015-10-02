package net.morocoshi.common.graphics
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	/**
	 * グラフィックを生成する
	 */
	public class Create
	{
		/**
		 * 単色円Spriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	rgb
		 * @param	alpha
		 * @return
		 */
		static public function circle(x:Number, y:Number, width:Number, height:Number, rgb:uint = 0x000000, alpha:Number = 1):Sprite
		{
			var sp:Sprite = new Sprite();
			Draw.circle(sp.graphics, x, y, width, height, rgb, alpha);
			return sp;
		}
		
		/**
		 * グラデーション円Spriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	rgbs
		 * @param	alphas
		 * @param	ratios
		 * @return
		 */
		static public function gradientCircle(x:Number, y:Number, width:Number, height:Number, isLinear:Boolean, rotation:Number, rgbs:Array, alphas:Array, ratios:Array = null):Sprite
		{
			var sp:Sprite = new Sprite();
			Draw.gradientCircle(sp.graphics, x, y, width, height, isLinear, rotation, rgbs, alphas, ratios);
			return sp;
		}
		
		/**
		 * 単色四角形Spriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	rgb
		 * @param	alpha
		 * @param	tx
		 * @param	ty
		 * @return
		 */
		static public function box(x:Number, y:Number, width:Number, height:Number, rgb:uint = 0x000000, alpha:Number = 1, tx:Number = 0, ty:Number = 0):Sprite
		{
			var sp:Sprite = new Sprite();
			Draw.box(sp.graphics, x, y, width, height, rgb, alpha);
			sp.x = tx;
			sp.y = ty;
			return sp;
		}
		
		/**
		 * グラデーション四角形Spriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	isLinear
		 * @param	rotation
		 * @param	rgbs
		 * @param	alphas
		 * @param	ratios
		 * @return
		 */
		static public function gradientBox(x:Number, y:Number, width:Number, height:Number, isLinear:Boolean, rotation:Number, rgbs:Array, alphas:Array, ratios:Array = null):Sprite
		{
			var sp:Sprite = new Sprite();
			Draw.gradientBox(sp.graphics, x, y, width, height, isLinear, rotation, rgbs, alphas, ratios);
			return sp;
		}
		
		/**
		 * Bitmapを包んだSpriteを生成する
		 * @param	bmd
		 * @param	smoothing
		 * @param	scaleX
		 * @param	scaleY
		 * @param	tx
		 * @param	ty
		 * @param	x
		 * @param	y
		 * @return
		 */
		static public function spriteBmp(bmd:BitmapData, smoothing:Boolean = true, scaleX:Number = 1, scaleY:Number = 1, tx:Number = 0, ty:Number = 0, x:Number = 0, y:Number = 0):Sprite
		{
			var sp:Sprite = new Sprite();
			sp.addChild(bitmap(bmd, smoothing, tx, ty, scaleX, scaleY));
			sp.x = x;
			sp.y = y;
			return sp;
		}
		
		/**
		 * 画像塗りフレームSpriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	size
		 * @param	bmd
		 * @param	scaleX
		 * @param	scaleY
		 * @param	tx
		 * @param	ty
		 * @return
		 */
		static public function bitmapFillFrame(x:Number, y:Number, width:Number, height:Number, size:Number, bmd:BitmapData, scaleX:Number = 1, scaleY:Number = 1, tx:Number = 0, ty:Number = 0):Sprite
		{
			var sp:Sprite = new Sprite();
			Draw.bitmapFillFrame(sp.graphics, x, y, width, height, size, bmd, scaleX, scaleY, tx, ty);
			return sp;
		}
		
		/**
		 * 画像塗り四角形Spriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	bmd
		 * @param	scaleX
		 * @param	scaleY
		 * @param	tx
		 * @param	ty
		 * @return
		 */
		static public function bitmapFillBox(x:Number, y:Number, width:Number, height:Number, bmd:BitmapData, scaleX:Number = 1, scaleY:Number = 1, tx:Number = 0, ty:Number = 0, smooth:Boolean = false):Sprite
		{
			var sp:Sprite = new Sprite();
			Draw.bitmapFillBox(sp.graphics, x, y, width, height, bmd, scaleX, scaleY, tx, ty, smooth);
			return sp;
		}
		
		/**
		 * Bitmapを生成する
		 * @param	bmd
		 * @param	smoothing
		 * @param	x
		 * @param	y
		 * @param	scaleX
		 * @param	scaleY
		 * @return
		 */
		static public function bitmap(bmd:BitmapData, smoothing:Boolean = true, x:Number = 0, y:Number = 0, scaleX:Number = 1, scaleY:Number = 1):Bitmap
		{
			var bmp:Bitmap = new Bitmap(bmd, "auto", smoothing);
			bmp.scaleX = scaleX;
			bmp.scaleY = scaleY;
			bmp.x = x;
			bmp.y = y;
			return bmp;
		}
		
		/**
		 * フレームSpriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	size
		 * @param	rgb
		 * @param	alpha
		 * @return
		 */
		static public function frame(x:Number, y:Number, width:Number, height:Number, size:Number = 1, rgb:uint = 0x000000, alpha:Number = 1):Sprite
		{
			var sp:Sprite = new Sprite();
			Draw.frame(sp.graphics, x, y, width, height, size, rgb, alpha);
			return sp;
		}
		
		/**
		 * 角丸四角形Spriteを生成する
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	roundX
		 * @param	roundY
		 * @param	rgb
		 * @param	alpha
		 * @param	tx
		 * @param	ty
		 * @return
		 */
		static public function roundBox(x:Number, y:Number, width:Number, height:Number, roundX:Number = 0, roundY:Number = 0, rgb:uint = 0x000000, alpha:Number = 1, tx:Number = 0, ty:Number = 0):Sprite 
		{
			var sp:Sprite = new Sprite();
			Draw.roundBox(sp.graphics, x, y, width, height, roundX, roundY, rgb, alpha);
			sp.x = tx;
			sp.y = ty;
			return sp;
		}
		
	}

}