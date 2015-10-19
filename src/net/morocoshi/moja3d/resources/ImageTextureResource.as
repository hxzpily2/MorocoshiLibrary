package net.morocoshi.moja3d.resources 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import net.morocoshi.moja3d.events.Event3D;
	
	/**
	 * イメージテクスチャ用リソース
	 * 
	 * @author tencho
	 */
	public class ImageTextureResource extends TextureResource 
	{
		static public const BITMAP:String = "bitmap";
		static public const ATF:String = "atf";
		
		protected var _bitmapData:BitmapData;
		protected var _atf:ATFData;
		protected var resourceType:String;
		protected var _hasResource:Boolean;
		protected var _hasAlpha:Boolean;
		protected var _format:String;
		protected var _isParsed:Boolean;
		protected var isCubeMap:Boolean;
		protected var _width:int;
		protected var _height:int;
		
		private var completeCallback:Function;
		private var _mipmap:Boolean;
		
		/**
		 * コンストラクタ
		 * 
		 * @param	data	渡せる形式は、Bitmp、BitmapData、ATFデータ(ByteArray)、uint（0xRRGGBB）
		 * @param	parseAlpha	半透明ピクセルの有無を調べる。完全不透明な画像はdrawCallが減ってくれるが、画像の大きさに比例してチェックが重くなる。
		 */
		public function ImageTextureResource(data:*, parseAlpha:Boolean = false)
		{
			super();
			
			_isParsed = false;
			_hasAlpha = false;
			_mipmap = true;
			_width = 0;
			_height = 0;
			
			if (data == null)
			{
			}
			else if (data is uint)
			{
				setBitmapResource(new BitmapData(1, 1, false, data), true);
			}
			else if (data is Bitmap)
			{
				setBitmapResource(Bitmap(data).bitmapData, true);
			}
			else if (data is BitmapData)
			{
				setBitmapResource(data as BitmapData, true);
			}
			else if (data is ByteArray)
			{
				setATFResource(data as ByteArray);
			}
			else
			{
				throw new Error("イメージリソースに渡されたデータ型 [" + typeof(data) + "] が不正です！");
			}
		}
		
		public function setATFResource(data:ByteArray):void 
		{
			_bitmapData = null;
			isUploaded = false;
			resourceType = ATF;
			_hasResource = Boolean(data);
			_isParsed = true;
			_atf = new ATFData(data);
			_width = _atf.width;
			_height = _atf.height;
			isCubeMap = _atf.isCubeMap;
			_hasAlpha = _atf.hasAlpha;
			_format = _atf.format;
			notifyParsed();
		}
		
		/**
		 * BitmapDataからリソースを生成する
		 * @param	bitmapData	画像データ
		 * @param	parseAlpha	半透明ピクセルの有無を調べる。完全不透明な画像はdrawCallが減ってくれるが、画像の大きさに比例してチェックが重くなる。
		 */
		public function setBitmapResource(bitmapData:BitmapData, parseAlpha:Boolean):void 
		{
			_atf = null;
			_bitmapData = bitmapData;
			_width = _bitmapData.width;
			_height = _bitmapData.height;
			isUploaded = false;
			_isParsed = true;
			isCubeMap = false;
			
			//透過ピクセルが含まれているかチェックする
			_hasAlpha = _bitmapData && _bitmapData.transparent;
			if (_bitmapData && _bitmapData.transparent && parseAlpha)
			{
				//アルファが0xffでない領域の有無で判断。画像が大きくなるほど重くなる・・・
				_hasAlpha = _bitmapData.getColorBoundsRect(0xff000000, 0xff000000, false).width > 0;
			}
			resourceType = BITMAP;
			_hasResource = Boolean(_bitmapData);
			_format = Context3DTextureFormat.BGRA;
			notifyParsed();
		}
		
		override public function getSamplingOption():String
		{
			if (resourceType == ATF && _atf)
			{
				return _atf.getSamplingOption();
			}
			return "";
		}
		
		override public function dispose():void 
		{
			super.dispose();
			isUploaded = false;
			_isParsed = false;
		}
		
		override public function upload(context3D:Context3D, async:Boolean, complete:Function = null):void 
		{
			if (_hasResource == false || isUploaded)
			{
				if (complete != null)
				{
					complete(this);
				}
				return;
			}
			
			isUploaded = true;
			isReady = false;
			completeCallback = complete;
			
			//ATF
			if (resourceType == ATF)
			{
				if (_atf.isCubeMap == false)
				{
					createTexture(context3D, _atf.width, _atf.height);
				}
				else
				{
					if (texture)
					{
						texture.dispose();
					}
					texture = context3D.createCubeTexture(_atf.width, _atf.format, async);
				}
				
				if (async)
				{
					texture.addEventListener(Event.TEXTURE_READY, texture_textureReadyHandler);
				}
				if (isCubeMap == false)
				{
					Texture(texture).uploadCompressedTextureFromByteArray(_atf.data, 0, async);
				}
				else
				{
					CubeTexture(texture).uploadCompressedTextureFromByteArray(_atf.data, 0, async);
				}
				
				if (async == false)
				{
					notifyComplete();
				}
			}
			
			//BitmapData
			if (resourceType == BITMAP)
			{
				if (isCubeMap == false)
				{
					createTexture(context3D, _bitmapData.width, _bitmapData.height);
					if (_mipmap)
					{
						uploadBitmapTextureWithMipMaps(texture as Texture, _bitmapData);
					}
					else
					{
						Texture(texture).uploadFromBitmapData(_bitmapData, 0);
					}
					notifyComplete();
				}
				else
				{
					createTexture(context3D, _bitmapData.width, _bitmapData.height);
					uploadCubeTextureWithMipMaps(texture as CubeTexture, _bitmapData.width);
					notifyComplete();
				}
			}
		}
		
		protected function uploadCubeTextureWithMipMaps(squareTexture:CubeTexture, size:int):void
		{
		}
		
		protected function notifyParsed():void
		{
			dispatchEvent(new Event3D(Event3D.RESOURCE_PARSED));
		}
		
		protected function notifyComplete():void 
		{
			isReady = true;
			if (completeCallback != null)
			{
				completeCallback(this);
			}
		}
		
		private function texture_textureReadyHandler(e:Event):void 
		{
			texture.removeEventListener(Event.TEXTURE_READY, texture_textureReadyHandler);
			notifyComplete();
		}
		
		/**
		 * MIPMAP用画像の生成とアップロード
		 * @param	squareTexture
		 * @param	originalImage
		 */
		public function uploadBitmapTextureWithMipMaps(squareTexture:Texture, originalImage:BitmapData):void
		{
			var mipWidth:int = originalImage.width;
			var mipHeight:int = originalImage.height;
			var mipLevel:int = 0;
			var mipImage:BitmapData = new BitmapData(originalImage.width, originalImage.height, originalImage.transparent, 0x0);
			var scaleTransform:Matrix = new Matrix();
			
			while (true)
			{
				mipImage.fillRect(mipImage.rect, 0);
				mipImage.draw(originalImage, scaleTransform, null, null, null, true);
				squareTexture.uploadFromBitmapData(mipImage, mipLevel);
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
			mipImage.dispose();
			isReady = true;
		}
		
		override public function createTexture(context3D:Context3D, width:int, height:int):void 
		{
			//前回と同じならスキップ
			if (prevSize.x == width && prevSize.y == height)
			{
				return;
			}
			
			var notPow2:Boolean = !TextureUtil.checkPow2(width, height);
			if (notPow2)
			{
				throw new Error("テクスチャサイズが2の累乗ではありません。( " + width + "," + height + " )");
			}
			
			prevSize.x = width;
			prevSize.y = height;
			
			if (texture)
			{
				texture.dispose();
			}
			
			if (isCubeMap == false)
			{
				texture = context3D.createTexture(width, height, _format, false, 0);
			}
			else
			{
				texture = context3D.createCubeTexture(width, _format, false, 0);
			}
		}
		
		override public function clone():Resource 
		{
			var resource:* = (resourceType == ATF)? _atf : _bitmapData.clone();
			var result:ImageTextureResource = new ImageTextureResource(resource, false);
			result._hasAlpha = _hasAlpha;
			result.autoDispose = autoDispose;
			return result;
		}
		
		public function get hasAlpha():Boolean
		{
			return _hasAlpha;
		}
		
		public function get hasResource():Boolean 
		{
			return _hasResource;
		}
		
		public function get isParsed():Boolean 
		{
			return _isParsed;
		}
		
		public function get atf():ATFData 
		{
			return _atf;
		}
		
		public function get bitmapData():BitmapData 
		{
			return _bitmapData;
		}
		
		public function get width():int 
		{
			return _width;
		}
		
		public function get height():int 
		{
			return _height;
		}
		
		public function get mipmap():Boolean 
		{
			return _mipmap;
		}
		
		public function set mipmap(value:Boolean):void 
		{
			_mipmap = value;
		}
		
	}

}