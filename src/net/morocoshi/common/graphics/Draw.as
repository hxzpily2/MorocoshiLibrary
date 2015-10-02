package net.morocoshi.common.graphics
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * グラフィックを描画する
	 */
	public class Draw
	{
		
		static public function star(g:Graphics, size1:Number = 100, size2:Number = 5, num:uint = 8, color:uint = 0x000000, alpha:Number = 1):void
		{
			g.lineStyle();
			g.beginFill(color, alpha);
			var i:int, L:int = num * 2, t:Number = 360 / L;
			for (i = 0; i < L; i ++)
			{
				var r:Number = (i % 2)? size2 : size1;
				var rad:Number = Math.PI / 180 * i * t;
				var x:Number = Math.cos(rad) * r;
				var y:Number = Math.sin(rad) * r;
				if (i == 0) g.moveTo(x, y);
				else g.lineTo(x, y);
			}
			g.endFill();
		}
		
		static public function polygon(g:Graphics, points:Vector.<Point>):void
		{
			var i:int, p:Point;
			for (i = 0; i < points.length; i++) {
				p = points[i];
				if (!i) g.moveTo(p.x, p.y);
				else g.lineTo(p.x, p.y);
			}
		}
		
		static public function bitmapFillFrame(g:Graphics, x:Number, y:Number, width:Number, height:Number, size:Number, bmd:BitmapData, scaleX:Number = 1, scaleY:Number = 1, tx:Number = 0, ty:Number = 0):void
		{
			g.beginBitmapFill(bmd, new Matrix(scaleX, 0, 0, scaleY, x + tx, y + ty), true);
			g.drawRect(x, y, width, height);
			g.drawRect(x + size, y + size, width - size * 2, height - size * 2);
			g.endFill();
		}
		
		static public function bitmapFillBox(g:Graphics, x:Number, y:Number, width:Number, height:Number, bmd:BitmapData, scaleX:Number = 1, scaleY:Number = 1, tx:Number = 0, ty:Number = 0, smooth:Boolean = false):void
		{
			g.beginBitmapFill(bmd, new Matrix(scaleX, 0, 0, scaleY, x + tx, y + ty), true, smooth);
			g.drawRect(x, y, width, height);
			g.endFill();
		}
		
		static public function frame(g:Graphics, x:Number, y:Number, width:Number, height:Number, size:Number = 1, rgb:uint = 0x000000, alpha:Number = 1):void
		{
			g.beginFill(rgb, alpha);
			g.drawRect(x, y, width, height);
			g.drawRect(x + size, y + size, width - size * 2, height - size * 2);
			g.endFill();
		}
		
		static public function box(g:Graphics, x:Number, y:Number, width:Number, height:Number, rgb:uint = 0x000000, alpha:Number = 1):void
		{
			g.beginFill(rgb, alpha);
			g.drawRect(x, y, width, height);
			g.endFill();
		}
		
		static public function circle(g:Graphics, x:Number, y:Number, width:Number, height:Number, rgb:uint = 0x000000, alpha:Number = 1):void
		{
			g.beginFill(rgb, alpha);
			g.drawEllipse(x - width, y - height, width * 2, height * 2);
			g.endFill();
		}
		
		static public function beginGradientFill(g:Graphics, x:Number, y:Number, width:Number, height:Number, isLinear:Boolean, rotation:Number, rgbs:Array, alphas:Array, ratios:Array = null):void
		{
			var i:int;
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(width, height, rotation * Math.PI / 180, x, y);
			
			var len:int = rgbs.length;
			if (!ratios)
			{
				ratios = [];
				for (i = 0; i < len; i++) ratios[i] = i / (len - 1);
			}
			for (i = 0; i < len; i++) ratios[i] *= 0xFF;
			
			g.beginGradientFill(isLinear? GradientType.LINEAR : GradientType.RADIAL, rgbs, alphas, ratios, mtx);
		}
		
		static public function gradientBox(g:Graphics, x:Number, y:Number, width:Number, height:Number, isLinear:Boolean, rotation:Number, rgbs:Array, alphas:Array, ratios:Array = null):void
		{
			beginGradientFill(g, x, y, width, height, isLinear, rotation, rgbs, alphas, ratios);
			g.drawRect(x, y, width, height);
			g.endFill();
		}
		
		static public function gradientCircle(g:Graphics, x:Number, y:Number, width:Number, height:Number, isLinear:Boolean, rotation:Number, rgbs:Array, alphas:Array, ratios:Array = null):void
		{
			var i:int;
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(width * 2, height * 2, rotation * Math.PI / 180, x - width, y - height);
			
			var len:int = rgbs.length;
			if (!ratios)
			{
				ratios = [];
				for (i = 0; i < len; i++) ratios[i] = i / (len - 1);
			}
			for (i = 0; i < len; i++) ratios[i] *= 0xFF;
			
			g.beginGradientFill(isLinear? GradientType.LINEAR : GradientType.RADIAL, rgbs, alphas, ratios, mtx);
			g.drawEllipse(x - width, y - height, width * 2, height * 2);
			g.endFill();
		}
		
		static public function roundFrame(g:Graphics, x:Number, y:Number, width:Number, height:Number, roundX:Number = 0, roundY:Number = 0, size:Number = 1, rgb:uint = 0x000000, alpha:Number = 1):void 
		{
			g.beginFill(rgb, alpha);
			g.drawRoundRect(x, y, width, height, roundX, roundY);
			g.drawRoundRect(x + size, y + size, width - size * 2, height - size * 2, roundX - size, roundY - size);
			g.endFill();
		}
		
		static public function roundBox(g:Graphics, x:Number, y:Number, width:Number, height:Number, roundX:Number = 0, roundY:Number = 0, rgb:uint = 0x000000, alpha:Number = 1):void 
		{
			g.beginFill(rgb, alpha);
			g.drawRoundRect(x, y, width, height, roundX, roundY);
			g.endFill();
		}
		
		static public function gradientRoundBox(g:Graphics, x:Number, y:Number, width:Number, height:Number, roundX:Number, roundY:Number, isLinear:Boolean, rotation:Number, rgbs:Array, alphas:Array, ratios:Array = null):void 
		{
			var i:int;
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(width, height, rotation * Math.PI / 180, x, y);
			
			var len:int = rgbs.length;
			if (!ratios)
			{
				ratios = [];
				for (i = 0; i < len; i++) ratios[i] = i / (len - 1);
			}
			for (i = 0; i < len; i++) ratios[i] *= 0xFF;
			
			g.beginGradientFill(isLinear? GradientType.LINEAR : GradientType.RADIAL, rgbs, alphas, ratios, mtx);
			g.drawRoundRect(x, y, width, height, roundX, roundY);
			g.endFill();
		}
		
	}

}