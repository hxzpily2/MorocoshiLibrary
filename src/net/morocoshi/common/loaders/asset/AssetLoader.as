package net.morocoshi.common.loaders.asset
{
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import net.morocoshi.common.video.flv.FLV;
	import net.morocoshi.common.video.flv.FLVEvent;
	
	/**
	 * ...
	 * 
	 * @author	unknown
	 */
	public class AssetLoader extends EventDispatcher
	{
		private var _datas:Vector.<AssetItem> = new Vector.<AssetItem>();
		private var _object:Object = { };
		private var _stocks:Vector.<AssetItem> = new Vector.<AssetItem>();
		private var _completeFunc:Function;
		private var _progressFunc:Function;
		private var _errorFunc:Function;
		private var _errorCount:int = 0;
		private var _successCount:int = 0;
		private var _isLoading:Boolean = false;
		private var _activeItem:AssetItem;
		private var _loadedCount:int = 0;
		private var _strictMode:Boolean = true;
		private var _progress:Number = 0;
		
		private const MARK:String = "data_";
		
		static public const TYPE_IMAGE:String = "image";
		static public const TYPE_SWF:String = "swf";
		static public const TYPE_TEXT:String = "text";
		static public const TYPE_BYTES:String = "bytes";
		static public const TYPE_XML:String = "xml";
		static public const TYPE_MP3:String = "mp3";
		static public const TYPE_FLV:String = "flv";
		public function get itemNum():int { return _datas.length };
		
		public function get strictMode():Boolean { return _strictMode; }
		public function set strictMode(value:Boolean):void { _strictMode = value; }

		public function AssetLoader()
		{
		}
		
		/**
		 * 読み込むデータを登録します
		 * @param	src	ファイルパス
		 * @param	type	空文字で自動識別
		 * @param	id	データを取得する際に使うのID
		 * @param	rate	データ量の割合
		 */
		public function addData(src:String, type:String = "", id:String = "", rate:Number = 1, strict:Boolean = true):void
		{
			var item:AssetItem = new AssetItem();
			item.src = src;
			item.id = id;
			item.rate = rate;
			item.strict = strict;
			if (type == "")
			{
				var ext:String = (src.indexOf(".") == -1)? "" : String(src.split(".").reverse()[0]).toLowerCase();
				if (ext == "") type == "";
				else if (String("jpg.jpeg.gif.png").indexOf(ext) != -1) type = TYPE_IMAGE;
				else if (String("swf").indexOf(ext) != -1) type = TYPE_SWF;
				else if (String("txt.dat.log").indexOf(ext) != -1) type = TYPE_TEXT;
				else if (String("xml.dae").indexOf(ext) != -1) type = TYPE_XML;
				else if (String("mp3").indexOf(ext) != -1) type = TYPE_MP3;
				else if (String("flv").indexOf(ext) != -1) type = TYPE_FLV;
			}
			item.type = type;
			_datas.push(item);
			_object[MARK + id] = item;
		}
		
		/**
		 * 読み込み開始
		 * @param	complete	完了イベント
		 * @param	error	エラーイベント
		 * @param	progress	プログレスイベント
		 */
		public function load(complete:Function = null, error:Function = null, progress:Function = null):void
		{
			if (_isLoading) return;
			_completeFunc = complete;
			_progressFunc = progress;
			_errorFunc = error;
			_isLoading = true;
			_loadedCount = 0;
			_errorCount = 0;
			_successCount = 0;
			_stocks = _datas.concat();
			next();
		}
		
		public function removeFunction():void
		{
			_completeFunc = null;
			_progressFunc = null;
			_errorFunc = null;
		}
		
		private function next():void
		{
			if (_stocks.length == 0)
			{
				complete();
				return;
			}
			var item:AssetItem = _stocks.shift();
			_activeItem = item;
			
			if (item.type == TYPE_MP3)
			{
				var mloader:Sound = new Sound();
				mloader.addEventListener(Event.COMPLETE, onCompleteSound);
				mloader.addEventListener(IOErrorEvent.IO_ERROR, onErrorSound);
				mloader.load(new URLRequest(item.src));
			}
			else if (item.type == TYPE_FLV)
			{
				var floader:FLV = new FLV();
				floader.addEventListener(FLVEvent.LOAD_PROGRESS, onProgressFLV);
				floader.addEventListener(FLVEvent.LOAD_COMPLETE, onCompleteFLV);
				floader.addEventListener(FLVEvent.ERROR, onErrorFLV);
				floader.load(item.src, false);
			}
			else if (item.type == TYPE_TEXT || item.type == TYPE_XML)
			{
				var tloader:URLLoader = new URLLoader();
				tloader.addEventListener(Event.COMPLETE, onCompleteText);
				tloader.addEventListener(ProgressEvent.PROGRESS, onProgressText);
				tloader.addEventListener(IOErrorEvent.IO_ERROR, onErrorText);
				tloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorText);
				tloader.load(new URLRequest(item.src));
			}
			else if (item.type == TYPE_IMAGE || item.type == TYPE_SWF)
			{
				var iloader:Loader = new Loader();
				iloader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteImage);
				iloader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressImage);
				iloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
				iloader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
				iloader.load(new URLRequest(item.src));
			}
			else if (item.type == TYPE_BYTES)
			{
				var bloader:URLLoader = new URLLoader();
				bloader.dataFormat = URLLoaderDataFormat.BINARY;
				bloader.addEventListener(Event.COMPLETE, onCompleteText);
				bloader.addEventListener(ProgressEvent.PROGRESS, onProgressText);
				bloader.addEventListener(IOErrorEvent.IO_ERROR, onErrorText);
				bloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorText);
				bloader.load(new URLRequest(item.src));
			}
			else
			{
				next();
			}
		}
		
		private function onProgressFLV(e:FLVEvent):void
		{
			setActiveProgress(e.progress);
		}
		
		private function onProgressText(e:ProgressEvent):void
		{
			setActiveProgress(e.bytesLoaded / e.bytesTotal);
		}
		
		private function onProgressImage(e:ProgressEvent):void
		{
			setActiveProgress(e.bytesLoaded / e.bytesTotal);
		}
		
		private function setActiveProgress(per:Number):void
		{
			var trate:Number = 0;
			for each(var d:AssetItem in _datas) trate += d.rate;
			_progress = (per + _loadedCount) * _activeItem.rate / trate;
			notifyProgress();
		}
		
		private function onCompleteText(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			removeURLLoaderEvent(loader);
			_activeItem.progress = 1;
			_activeItem.success = true;
			switch(_activeItem.type)
			{
				case TYPE_TEXT:
					_activeItem.text = String(loader.data);
					break;
				case TYPE_BYTES:
					_activeItem.bytes = loader.data as ByteArray;
					break;
				case TYPE_XML:
					_activeItem.xml = new XML(loader.data);
					break;
			}
			_successCount++;
			next();
		}
		
		private function onCompleteSound(e:Event):void
		{
			var sound:Sound = e.currentTarget as Sound;
			removeSoundEvent(sound);
			_activeItem.progress = 1;
			_activeItem.sound = sound;
			_activeItem.success = true;
			_successCount++;
			next();
		}
		
		private function onCompleteFLV(e:FLVEvent):void
		{
			var flv:FLV = e.currentTarget as FLV;
			removeFLVEvent(flv);
			_activeItem.progress = 1;
			_activeItem.flv = flv;
			_activeItem.success = true;
			_successCount++;
			next();
		}
		
		private function onCompleteImage(e:Event):void
		{
			var info:LoaderInfo = e.currentTarget as LoaderInfo;
			removeInfoEvent(info);
			_activeItem.progress = 1;
			_activeItem.success = true;
			
			if (_activeItem.type == TYPE_IMAGE)
			{
				_activeItem.image = Bitmap(info.content).bitmapData;
			}
			if (_activeItem.type == TYPE_SWF)
			{
				_activeItem.avm1 = info.content as AVM1Movie;
				_activeItem.clip = info.content as MovieClip;
			}
			_loadedCount++;
			_successCount++;
			next();
		}
		
		private function onErrorFLV(e:FLVEvent):void
		{
			removeFLVEvent(e.currentTarget as FLV);
			_activeItem.progress = 0;
			_activeItem.success = false;
			_errorCount++;
			if (_strictMode && _activeItem.strict)
			{
				notifyError("sound notfound");
			}
			else
			{
				next();
			}
		}
		
		private function onErrorSound(e:ErrorEvent):void
		{
			removeSoundEvent(e.currentTarget as Sound);
			_activeItem.progress = 0;
			_activeItem.success = false;
			_errorCount++;
			if (_strictMode && _activeItem.strict)
			{
				notifyError("sound notfound");
			}
			else
			{
				next();
			}
		}
		
		private function onErrorImage(e:ErrorEvent):void
		{
			removeInfoEvent(e.currentTarget as LoaderInfo);
			_activeItem.progress = 0;
			_activeItem.success = false;
			_errorCount++;
			if (_strictMode && _activeItem.strict)
			{
				notifyError("image notfound");
			}
			else
			{
				next();
			}
		}
		
		private function onErrorText(e:ErrorEvent):void
		{
			removeURLLoaderEvent(e.currentTarget as URLLoader);
			_activeItem.progress = 0;
			_activeItem.success = false;
			_errorCount++;
			if (_strictMode && _activeItem.strict)
			{
				notifyError("text notfound");
			}
			else
			{
				next();
			}
		}
		
		private function removeFLVEvent(flv:FLV):void
		{
			flv.removeEventListener(FLVEvent.ERROR, onErrorFLV);
			flv.removeEventListener(FLVEvent.LOAD_PROGRESS, onProgressFLV);
			flv.removeEventListener(FLVEvent.LOAD_COMPLETE, onCompleteFLV);
		}
		
		private function removeSoundEvent(sound:Sound):void
		{
			sound.removeEventListener(Event.COMPLETE, onCompleteSound);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, onErrorSound);
		}
		
		private function removeInfoEvent(info:LoaderInfo):void
		{
			info.removeEventListener(Event.COMPLETE, onCompleteImage);
			info.removeEventListener(ProgressEvent.PROGRESS, onProgressImage);
			info.removeEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
			info.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
		}
		
		private function removeURLLoaderEvent(loader:URLLoader):void
		{
			loader.removeEventListener(Event.COMPLETE, onCompleteText);
			loader.removeEventListener(ProgressEvent.PROGRESS, onProgressImage);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorText);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorText);
		}
		
		public function isSuccessful(id:String):Boolean
		{
			var item:AssetItem = getItem(id);
			return (item && item.success);
		}
		
		public function getSound(id:String):Sound 
		{
			var item:AssetItem = getItem(id);
			return (item)? item.sound : null;
		}
		
		public function getXML(id:String):XML
		{
			var item:AssetItem = getItem(id);
			return (item)? item.xml : null;
		}
		
		public function getText(id:String):String
		{
			var item:AssetItem = getItem(id);
			return (item)? item.text : null;
		}
		
		public function getFLV(id:String):FLV
		{
			var item:AssetItem = getItem(id);
			return (item)? item.flv : null;
		}
		
		public function getAVM1Movie(id:String):AVM1Movie
		{
			var item:AssetItem = getItem(id);
			return (item)? item.avm1 : null;
		}
		
		public function getMovieClip(id:String):MovieClip
		{
			var item:AssetItem = getItem(id);
			return (item)? item.clip : null;
		}
		
		public function newClass(id:String, clip:String):*
		{
			return new (getMovieClip(id).loaderInfo.applicationDomain.getDefinition(clip));
		}
		
		public function getImage(id:String):BitmapData
		{
			var item:AssetItem = getItem(id);
			return (item)? item.image : null;
		}
		
		public function getItem(id:String):AssetItem 
		{
			return _object[MARK + id];
		}
		
		/**
		 * ロードを中断（※作り途中）
		 */
		public function stopLoad():void 
		{
			
		}
		
		private function complete():void
		{
			_activeItem = null;
			_isLoading = false;
			_progress = 1;
			notifyProgress();
			notifyComplete();
		}
		
		private function notifyComplete():void
		{
			var e:AssetLoaderEvent = createEvent(AssetLoaderEvent.COMPLETE);
			e.datas = _datas.concat();
			dispatchEvent(e);
			if (_completeFunc != null) _completeFunc(e);
			removeFunction();
		}
		
		private function notifyError(text:String = ""):void
		{
			var e:AssetLoaderEvent = createEvent(AssetLoaderEvent.ERROR);
			e.datas = _datas.concat();
			e.text = text;
			dispatchEvent(e);
			if (_errorFunc != null) _errorFunc(e);
			removeFunction();
		}
		
		private function notifyProgress():void
		{
			var e:AssetLoaderEvent = createEvent(AssetLoaderEvent.PROGRESS);
			e.datas = _datas.concat();
			dispatchEvent(e);
			if (_progressFunc != null) _progressFunc(e);
		}
		
		private function createEvent(type:String):AssetLoaderEvent
		{
			var e:AssetLoaderEvent = new AssetLoaderEvent(type);
			e.totalCount = _datas.length;
			e.loadedCount = _loadedCount;
			e.errorCount = _errorCount;
			e.isSuccess = (_errorCount == 0);
			e.successCount = _successCount;
			e.loader = this;
			e.progress = _progress;
			return e;
		}
		
	}
	
}