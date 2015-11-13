package net.morocoshi.moja3d.resources 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class SWFTextureResource extends ImageTextureResource 
	{
		private var _movieClip:MovieClip;
		private var _trimming:Rectangle;
		private var sprite:Sprite;
		private var context3D:ContextProxy;
		private var completeCallback:Function;
		private var _autoCapture:Boolean;
		
		public function SWFTextureResource(width:int = 128, height:int = 128, data:* = null, trimming:Rectangle = null) 
		{
			super(null);
			sprite = new Sprite();
			_autoCapture = true;
			_width = width;
			_height = height;
			_bitmapData = new BitmapData(width, height, true, 0x0);
			
			_trimming = new Rectangle(0, 0, width, height);
			
			if (data is MovieClip)
			{
				setMovieResource(data as MovieClip, trimming);
			}
			
			if (data is ByteArray)
			{
				setBytesResource(data as ByteArray, trimming);
			}
		}
		
		public function setContext3D(context3D:ContextProxy):void
		{
			this.context3D = context3D;
		}
		
		public function setMovieResource(target:MovieClip, trimming:Rectangle):void
		{
			if (trimming)
			{
				_trimming.copyFrom(trimming);
			}
			_movieClip = target;
			_hasResource = true;
			autoCapture = _autoCapture;
		}
		
		public function setBytesResource(target:ByteArray, trimming:Rectangle, complete:Function = null):void
		{
			completeCallback = complete;
			if (trimming)
			{
				_trimming.copyFrom(trimming);
			}
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, info_completeHandler);
			loader.loadBytes(target, new LoaderContext(false));
		}
		
		private function info_completeHandler(e:Event):void 
		{
			var info:LoaderInfo = e.currentTarget as LoaderInfo;
			info.removeEventListener(Event.COMPLETE, info_completeHandler);
			if (info.content is MovieClip)
			{
				setMovieResource(info.content as MovieClip, _trimming);
			}
			dispatchEvent(new Event(Event.COMPLETE));
			if (completeCallback != null)
			{
				completeCallback();
				completeCallback = null;
			}
		}
		
		private function tick(e:Event):void 
		{
			capture();
		}
		
		public function capture():void
		{
			_bitmapData.fillRect(_bitmapData.rect, 0x0);
			var matrix:Matrix = new Matrix();
			matrix.tx = _trimming.x;
			matrix.ty = _trimming.y;
			matrix.scale(_trimming.width / _width, _trimming.height / _height);
			_bitmapData.draw(_movieClip, matrix);
			setBitmapResource(_bitmapData, false);
			if (context3D)
			{
				upload(context3D, false);
			}
		}
		
		public function get movieClip():MovieClip 
		{
			return _movieClip;
		}
		
		public function get autoCapture():Boolean 
		{
			return _autoCapture;
		}
		
		public function set autoCapture(value:Boolean):void 
		{
			_autoCapture = value;
			if (_autoCapture)
			{
				sprite.addEventListener(Event.ENTER_FRAME, tick);
			}
			else
			{
				sprite.removeEventListener(Event.ENTER_FRAME, tick);
			}
		}
		
	}

}