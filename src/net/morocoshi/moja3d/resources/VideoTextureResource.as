package net.morocoshi.moja3d.resources 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author tencho
	 */
	public class VideoTextureResource extends ImageTextureResource 
	{
		private var _movieClip:MovieClip;
		private var sprite:Sprite;
		private var context3D:Context3D;
		private var completeCallback:Function;
		private var _autoCapture:Boolean;
		private var _netStream:NetStream;
		private var video:Video;
		private var _fps:Number;
		private var timer:Timer;
		private var _volume:Number;
		
		public function VideoTextureResource(width:int = 128, height:int = 128, data:* = null, fps:Number = 30, volume:Number = 1) 
		{
			super(null);
			sprite = new Sprite();
			_autoCapture = true;
			_fps = fps;
			_width = width;
			_height = height;
			_volume = volume;
			_bitmapData = new BitmapData(width, height, false, 0x0);
			
			video = new Video(_width, _height);
			
			if (data is ByteArray)
			{
				setBytesResource(data as ByteArray);
			}
			
			if (data is String)
			{
				setExternalResource(data as String);
			}
			
			updateTimer();
		}
		
		public function setContext3D(context3D:Context3D):void
		{
			this.context3D = context3D;
		}
		
		public function setExternalResource(path:String, complete:Function = null):void
		{
			completeCallback = complete;
			
			var nc:NetConnection = new NetConnection(); 
			nc.connect(null);
			_netStream = new NetStream(nc);
			_netStream.client = { onMetaData:function(...rest):void { }};
			_netStream.soundTransform = new SoundTransform(_volume, 0);
			_netStream.play(path);
			
			video.attachNetStream(_netStream);
		}
		
		public function setBytesResource(target:ByteArray, complete:Function = null):void
		{
			completeCallback = complete;
			
			var nc:NetConnection = new NetConnection(); 
			nc.connect(null);
			_netStream = new NetStream(nc);
			_netStream.client = { onMetaData:function(...rest):void { }};
			_netStream.soundTransform = new SoundTransform(_volume, 0);
			_netStream.appendBytes(target);
			
			video.attachNetStream(_netStream);
		}
		
		public function capture():void
		{
			_bitmapData.fillRect(_bitmapData.rect, 0x0);
			_bitmapData.draw(video);
			setBitmapResource(_bitmapData, false);
			if (context3D)
			{
				upload(context3D, false);
			}
		}
		
		public function updateTimer():void
		{
			if (timer)
			{
				timer.removeEventListener(TimerEvent.TIMER, timesUp);
				timer.stop();
				timer = null;
			}
			
			if (_autoCapture && _fps > 0)
			{
				timer = new Timer(1000 / _fps, 0);
				timer.addEventListener(TimerEvent.TIMER, timesUp);
				timer.start();
			}
		}
		
		private function timesUp(e:TimerEvent):void 
		{
			capture();
		}
		
		public function set autoCapture(value:Boolean):void 
		{
			_autoCapture = value;
			updateTimer();
		}
		
		public function get fps():Number 
		{
			return _fps;
		}
		
		public function set fps(value:Number):void 
		{
			_fps = value;
			updateTimer();
		}
		
		public function get netStream():NetStream 
		{
			return _netStream;
		}
		
	}

}