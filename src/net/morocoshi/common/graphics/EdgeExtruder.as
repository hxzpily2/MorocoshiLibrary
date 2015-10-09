package net.morocoshi.common.graphics 
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	/**
	 * PNG透過画像をStage3Dで表示する際のFlashの仕様によるふちの黒ずみ対策用画像生成クラス
	 * 
	 * @author tencho
	 */
	public class EdgeExtruder 
	{
		private var sprite:Sprite;
		private var roundCoord:Array;
		private var completeCallback:Function;
		private var progressCallback:Function;
		private var diffuseImage:BitmapData;
		private var opacityImage:BitmapData;
		private var resultImage:BitmapData;
		
		private var width:int;
		private var height:int;
		private var pixelLength:int;
		private var count:int;
		private var threshold:uint;
		private var extend:int;
		
		public function EdgeExtruder()
		{
			sprite = new Sprite();
		}
		
		/**
		 * 	
		 * @param	image		ソース画像
		 * @param	extend		引き延ばすピクセル数
		 * @param	transparent	分割後のdiffuse画像を透過画像にする
		 * @param	threshold	[0ｘ00～0xff]アルファ値がこの数値以下のピクセル部分を引き伸ばし対象にする
		 * @param	complete	complete(diffuse:BitmapData, opacity:BitmapData)
		 * @param	progress	progress(per:Number = 0.0-1.0)
		 */
		public function splitAndExtrudeAsync(image:BitmapData, extend:int, transparent:Boolean, threshold:uint, complete:Function, progress:Function = null):void
		{
			completeCallback = complete;
			progressCallback = progress;
			
			var opacity:BitmapData = new BitmapData(image.width, image.height, false, 0x0);
			opacity.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
			opacity.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
			opacity.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
			
			extrudeAsync(image, opacity, extend, transparent, threshold, function(result:BitmapData):void {	
				complete(result, opacity);
			}, progress);
		}
		
		/**
		 * diffuse画像とopacity画像から、透過領域に接する縁の色を拡張したdiffuse画像を生成する。
		 * @param	diffuse	diffuse画像
		 * @param	opacity	モノクロ透過領域画像
		 * @param	extend	引き伸ばすピクセル数
		 * @param	transparent	出力Bitmapの透過オプション設定
		 * @param	threshold	[0ｘ00～0xff]アルファ値がこの数値以下のピクセル部分を引き伸ばし対象にする
		 * @param	complete	complete(diffuse:BitmapData)
		 * @param	progress	progress(per:Number = 0.0-1.0)
		 * @return
		 */
		public function extrudeAsync(diffuse:BitmapData, opacity:BitmapData, extend:int, transparent:Boolean, threshold:uint, complete:Function, progress:Function = null):void
		{
			if (!diffuse.rect.equals(opacity.rect))
			{
				throw new Error("2つの画像のサイズが違います");
			}
			
			completeCallback = complete;
			progressCallback = progress;
			this.threshold = threshold;
			this.extend = extend;
			
			roundCoord = [];
			for (var ex:int = -extend; ex < extend; ex++)
			for (var ey:int = -extend; ey < extend; ey++)
			{
				var d:int = Math.max(Math.abs(ex), Math.abs(ey));
				if (!roundCoord[d]) roundCoord[d] = [];
				roundCoord[d].push( { x:ex, y:ey } );
			}
			
			resultImage = BitmapUtil.setTransparent(diffuse, transparent, 0);
			diffuseImage = diffuse;
			opacityImage = opacity;
			
			var dx:int;
			var dy:int;
			var i:int;
			
			diffuseImage.lock();
			opacityImage.lock();
			resultImage.lock();
			
			width = opacity.width;
			height = opacity.height;
			count = -1;
			pixelLength = opacity.width * opacity.height;
			
			sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void
		{
			var time:int = getTimer();
			
			while (getTimer() - time < 100)
			{
				count++;
				if (count >= pixelLength)
				{
					end();
					return;
				}
				
				var ix:int = count % width;
				var iy:int = count / width;
				//opacityのピクセル色をチェック
				var alpha:uint = opacityImage.getPixel(ix, iy) & 0xFF;
				if (alpha > threshold) continue;
				
				//周囲数pxの閾値を超過しているアルファを近い順に調べていく
				//閾値超過したピクセルがあったら
				//その座標のdiffuse色をresultにコピー
				var done:Boolean = false;
				for (var offset:int = 1; offset <= extend && done == false; offset++) 
				{
					var coords:Array = roundCoord[offset];
					for (var i:int = 0; i < coords.length; i++)
					{
						var dx:int = coords[i].x + ix;
						var dy:int = coords[i].y + iy;
						if (dx < 0 || dx >= width || dy < 0 || dy >= height) continue;
						if ((opacityImage.getPixel(dx, dy) & 0xFF) <= threshold) continue;
						resultImage.setPixel(ix, iy, diffuseImage.getPixel(dx, dy));
						done = true;
						break;
					}
				}
			}
			
			progressCallback(count / pixelLength);
		}
		
		private function end():void 
		{
			sprite.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			diffuseImage.unlock();
			opacityImage.unlock();
			resultImage.unlock();
			
			completeCallback(resultImage);
		}
		
		/**
		 * 一枚の画像をdiffuseとopacityに分離し、透過領域に接する縁の色を拡張したdiffuse画像とopacity画像を生成する。
		 * @param	image		ソース画像
		 * @param	extend		引き延ばすピクセル数
		 * @param	transparent	分割後のdiffuse画像を透過画像にする
		 * @param	threshold	[0ｘ00～0xff]アルファ値がこの数値以下のピクセル部分を引き伸ばし対象にする
		 * @return
		 */
		static public function splitAndExtrude(image:BitmapData, extend:int, transparent:Boolean, threshold:uint):Vector.<BitmapData>
		{
			var result:Vector.<BitmapData> = new Vector.<BitmapData>;
			
			//var diffuse:BitmapData = BitmapUtil.setTransparent(image, transparent, 0x0);
			var opacity:BitmapData = new BitmapData(image.width, image.height, false, 0x0);
			opacity.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
			opacity.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
			opacity.copyChannel(image, image.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
			
			result[0] = extrude(image, opacity, extend, transparent, threshold);
			result[1] = opacity;
			
			return result;
		}
		
		/**
		 * diffuse画像とopacity画像から、透過領域に接する縁の色を拡張したdiffuse画像を生成する。
		 * @param	diffuse	diffuse画像
		 * @param	opacity	モノクロ透過領域画像
		 * @param	extend	引き伸ばすピクセル数
		 * @param	transparent	出力Bitmapの透過オプション設定
		 * @param	threshold	[0ｘ00～0xff]アルファ値がこの数値以下のピクセル部分を引き伸ばし対象にする
		 * @return
		 */
		static public function extrude(diffuse:BitmapData, opacity:BitmapData, extend:int, transparent:Boolean, threshold:uint = 0x00):BitmapData
		{
			if (!diffuse.rect.equals(opacity.rect))
			{
				throw new Error("2つの画像のサイズが違います");
			}
			var roundCoord:Array = [];
			for (var ex:int = -extend; ex < extend; ex++)
			for (var ey:int = -extend; ey < extend; ey++)
			{
				var d:int = Math.max(Math.abs(ex), Math.abs(ey));
				if (!roundCoord[d]) roundCoord[d] = [];
				roundCoord[d].push( { x:ex, y:ey } );
			}
			var result:BitmapData = BitmapUtil.setTransparent(diffuse, transparent, 0);
			var dx:int;
			var dy:int;
			var i:int;
			
			diffuse.lock();
			opacity.lock();
			result.lock();
			
			var width:int = opacity.width;
			var height:int = opacity.height;
			for (var ix:int = 0; ix < width; ix++) 
			for (var iy:int = 0; iy < height; iy++) 
			{
				//opacityのピクセル色をチェック
				var alpha:uint = opacity.getPixel(ix, iy) & 0xFF;
				if (alpha > threshold) continue;
				
				//周囲数pxの閾値を超過しているアルファを近い順に調べていく
				//閾値超過したピクセルがあったら
				//その座標のdiffuse色をresultにコピー
				var done:Boolean = false;
				for (var offset:int = 1; offset <= extend; offset++) 
				{
					var coords:Array = roundCoord[offset];
					for (i = 0; i < coords.length; i++)
					{
						dx = coords[i].x + ix;
						dy = coords[i].y + iy;
						if (dx < 0 || dx >= width || dy < 0 || dy >= height) continue;
						if ((opacity.getPixel(dx, dy) & 0xFF) <= threshold) continue;
						result.setPixel(ix, iy, diffuse.getPixel(dx, dy));
						done = true;
						break;
					}
					if (done) break;
				}
				
			}
			
			diffuse.unlock();
			opacity.unlock();
			result.unlock();
			
			return result;
		}
		
	}

}