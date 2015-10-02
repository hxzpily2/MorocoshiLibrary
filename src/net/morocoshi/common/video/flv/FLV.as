package net.morocoshi.common.video.flv
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	 * FLVビデオ
	 * 
	 * @author	unknown
	 */
	public class FLV extends EventDispatcher
	{
		private var _stream:NetStream;
		private var _video:Video;
		private var _loop:Boolean = false;
		private var _sp:Sprite = new Sprite();
		private var _metaData:FLVData = new FLVData();
		private var _isGetMeta:Boolean = false;
		private var _isPlaying:Boolean = true;
		//最後にチェックしたロード済みの割合
		private var _lastProgress:Number = -1;
		private var _volume:Number = 1;
		private var _panning:Number = 0;
		private var lastTime:Number = -1;
		
		/**再生の開始*/
		static public const STATUS_PLAY_START:String = "NetStream.Play.Start";
		/***/
		static public const STATUS_PLAY_STOP:String = "NetStream.Play.Stop";
		/**バッファを満たしたので再生*/
		static public const STATUS_BUFFER_FULL:String = "NetStream.Buffer.Full";
		/**バッファが空になったので中断*/
		static public const STATUS_BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
		/**ストリーム読み込みが終了した*/
		static public const STATUS_BUFFER_FLUSH:String = "NetStream.Buffer.Flush";
		/**FLV ファイルが見つからない*/
		static public const STATUS_PLAY_STREAMNOTFOUND:String = "NetStream.Play.StreamNotFound";
		/**その他のエラー*/
		static public const STATUS_PLAY_FAILED:String = "NetStream.Play.Failed";
		/**シークが失敗した*/
		static public const STATUS_SEEK_FAILED:String = "NetStream.Seek.Failed";
		/**有効ではないシーク時間を指定した(指定可能なシーク時間:event.info.details)*/
		static public const STATUS_SEEK_INVALIDTIME:String = "NetStream.Seek.InvalidTime";
		/**シーク操作を完了できた*/
		static public const STATUS_SEEK_NOTIFY:String = "NetStream.Seek.Notify";
		
		public function FLV()
		{
			var connection:NetConnection = new NetConnection();
			connection.connect(null);
			
			_stream = new NetStream(connection);
			_stream.bufferTime = 5.0;
			_stream.addEventListener(IOErrorEvent.IO_ERROR, stream_errorHandler);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, stream_statusHandler);
			
			var client:Object = { };
			client.onMetaData = onMetaData;
			_stream.client = client;
		}
		
		/**
		 * netStreamクラスをFLVクラスから切り離す(closeはしない)
		 */
		public function disconnect():void
		{
			_stream.client = { };
			_sp.removeEventListener(Event.ENTER_FRAME, onTick);
			_stream.removeEventListener(IOErrorEvent.IO_ERROR, stream_errorHandler);
			_stream.removeEventListener(NetStatusEvent.NET_STATUS, stream_statusHandler);
			_stream = null;
		}
		
		private function stream_errorHandler(e:IOErrorEvent):void
		{
			displatchError();
		}
		
		private function stream_statusHandler(e:NetStatusEvent):void
		{
			var code:String = e.info.code;
			if (code == STATUS_SEEK_INVALIDTIME)
			{
			}
			if (code == STATUS_PLAY_STREAMNOTFOUND)
			{
				displatchError();
			}
			if (code == STATUS_BUFFER_EMPTY && _isPlaying)
			{
				//play();
			}
			if (code == STATUS_PLAY_STOP)
			{
				if (_loop)
				{
					seek(0);
					play();
				}
				else
				{
					stop();
				}
				dispatchEvent(new FLVEvent(FLVEvent.PLAY_COMPLETE));
			}
			if (code == STATUS_PLAY_START && !_isPlaying)
			{
				_stream.pause();
				_stream.seek(_stream.time);
			}
		}
		
		private function onMetaData(param:Object):void
		{
			if (_isGetMeta) return;
			_isGetMeta = true;
			_metaData.duration = (param.duration)? param.duration : -1;
			if (param.width && param.height)
			{
				_metaData.size = new Rectangle();
				_metaData.size.width = (param.width)? param.width : 0;
				_metaData.size.height = (param.height)? param.height : 0;
			}
			var evt:FLVEvent = new FLVEvent(FLVEvent.METADATA);
			evt.data = _metaData;
			dispatchEvent(evt);
			//"ビデオレート : " + param.videodatarate + "kb");
			//"フレームレート : " + param.framerate + "fps");
			//"コーデックＩＤ : " + param.videocodecid);
		}
		
		/**
		 * FLVファイル読み込み開始
		 * @param	src	FLVパス
		 * @param	isPlay	ロード後再生するか
		 */
		public function load(src:String, isPlay:Boolean = true):void
		{
			_stream.close();
			_sp.addEventListener(Event.ENTER_FRAME, onTick);
			_sp.addEventListener(Event.ENTER_FRAME, displatchTime);
			_isPlaying = isPlay;
			_isGetMeta = false;
			_lastProgress = -1;
			_stream.play(src);
			
			dispatchEvent(new FLVEvent(FLVEvent.PLAYSTOP));
			displatchTime();
		}
		
		/**
		 * 秒単位でシークする
		 * @param	time
		 */
		public function seek(time:Number):void
		{
			_stream.seek(time);
			displatchTime();
		}
		
		private function displatchTime(e:Event = null):void
		{
			var time:Number = _stream? _stream.time : 0;
			if (lastTime == time) return;
			
			lastTime = time;
			var evt:FLVEvent = new FLVEvent(FLVEvent.SEEK);
			evt.time = time;
			dispatchEvent(evt);
		}
		
		private function displatchError():void
		{
			var evt:FLVEvent = new FLVEvent(FLVEvent.ERROR);
			dispatchEvent(evt);
		}
		
		/**
		 * 停止する
		 */
		public function stop():void
		{
			_isPlaying = false;
			_stream.pause();
			dispatchEvent(new FLVEvent(FLVEvent.PLAYSTOP));
			displatchTime();
		}
		
		/**
		 * 再生と停止を切り替える
		 * @return
		 */
		public function playstop():Boolean
		{
			if (_isPlaying) stop();
			else play();
			return _isPlaying;
		}
		
		/**
		 * 再生する
		 */
		public function play():void
		{
			_isPlaying = true;
			_stream.resume();
			
			dispatchEvent(new FLVEvent(FLVEvent.PLAYSTOP));
			displatchTime();
		}
		
		public function close():void 
		{
			stop();
			_stream.close();
		}
		
		private function applySoundTransform():void 
		{
			var st:SoundTransform = new SoundTransform(_volume, _panning);
			_stream.soundTransform = st;
		}
		
		private function onTick(e:Event):void
		{
			var per:Number = (_stream.bytesTotal)? _stream.bytesLoaded / _stream.bytesTotal : 0;
			if (_lastProgress != per)
			{
				_lastProgress = per;
				var evt:FLVEvent = new FLVEvent(FLVEvent.LOAD_PROGRESS);
				evt.progress = per;
				evt.bytesLoaded = _stream.bytesLoaded;
				evt.bytesTotal = _stream.bytesTotal;
				dispatchEvent(evt);
				if (per == 1) dispatchEvent(new FLVEvent(FLVEvent.LOAD_COMPLETE));
			}
			if (per == 1)
			{
				_sp.removeEventListener(Event.ENTER_FRAME, onTick);
			}
		}
		
		/**
		 * NetStream。これをVideoやStageVideoに関連付けて表示する。
		 */
		public function get stream():NetStream
		{
			return _stream;
		}
		
		/**
		 * ループのON/OFF
		 */
		public function get loop():Boolean
		{
			return _loop;
		}
		
		public function set loop(value:Boolean):void
		{
			_loop = value;
		}
		
		/**
		 * メタデータ
		 */
		public function get metaData():FLVData
		{
			return _metaData;
		}
		
		/**
		 * 再生中かどうか
		 */
		public function get isPlaying():Boolean 
		{
			return _isPlaying;
		}
		
		public function get volume():Number 
		{
			return _volume;
		}
		
		public function set volume(value:Number):void 
		{
			_volume = value;
			applySoundTransform();
		}
		
		public function get panning():Number 
		{
			return _panning;
		}
		
		public function set panning(value:Number):void 
		{
			_panning = value;
			applySoundTransform();
		}
		
	}
	
}