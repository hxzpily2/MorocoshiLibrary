package net.morocoshi.moja3d.resources 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.geom.Matrix;
	
	/**
	 * BitmapData6枚で構成されるキューブマップ用リソース。ATFのキューブマップはImageTextureResourceの方を使ってください。
	 * 
	 * @author tencho
	 */
	public class CubeTextureResource extends ImageTextureResource 
	{
		public var left:BitmapData;
		public var right:BitmapData;
		public var bottom:BitmapData;
		public var top:BitmapData;
		public var back:BitmapData;
		public var front:BitmapData;
		public var cubeTexture:CubeTexture;
		
		public function CubeTextureResource(left:BitmapData, right:BitmapData, bottom:BitmapData, top:BitmapData, back:BitmapData, front:BitmapData) 
		{
			super(null);
			setCubeResource(left, right, bottom, top, back, front);
		}
		
		public function setCubeResource(left:BitmapData, right:BitmapData, bottom:BitmapData, top:BitmapData, back:BitmapData, front:BitmapData):void 
		{
			_atf = null;
			_bitmapData = left;
			_isParsed = true;
			
			this.left = left;
			this.right = right;
			this.bottom = bottom;
			this.top = top;
			this.back = back;
			this.front = front;
			
			_hasResource = (left && right && bottom && top && back && front);
			resourceType = BITMAP;
			isCubeMap = true;
			_format = Context3DTextureFormat.BGRA;
			
			notifyParsed();
		}
		
		override protected function uploadCubeTextureWithMipMaps(squareTexture:CubeTexture, size:int):void 
		{
			var mipLevel:int = 0;
			//var mipImage:BitmapData = new BitmapData(size, size, false, 0x0);
			var mipWidth:int = size;
			var mipHeight:int = size;
			var scaleTransform:Matrix = new Matrix();
			
			var i:int;
			var images:Array = [right, left, top, bottom, front, back];
			//var images:Array = [left, right, back, front, down, top];
			var rawImages:Vector.<BitmapData> = new Vector.<BitmapData>;
			for (i = 0; i < 6; i++) 
			{
				rawImages.push(images[i].clone());
			}
			
			while (true)
			{
				//mipImage.draw(size, scaleTransform, null, null, null, true);
				for (i = 0; i < 6; i++) 
				{
					rawImages[i].fillRect(rawImages[i].rect, 0);
					rawImages[i].draw(images[i], scaleTransform, null, null, null, true);
					squareTexture.uploadFromBitmapData(rawImages[i], i, mipLevel);
				}
				scaleTransform.scale(0.5, 0.5);
				
				if (mipWidth == 1 && mipHeight == 1)
				{
					break;
				}
				
				mipLevel++;
				mipWidth >>= 1;
				mipHeight >>= 1;
				if (mipWidth == 0) mipWidth = 1;
				if (mipHeight == 0) mipHeight = 1;
			}
			//mipImage.dispose();
			isReady = true;
		}
		
		override public function clone():Resource 
		{
			return new CubeTextureResource(left, right, bottom, top, back, front);
		}
		
	}

}