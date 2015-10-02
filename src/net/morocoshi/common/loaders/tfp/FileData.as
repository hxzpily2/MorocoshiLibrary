package net.morocoshi.common.loaders.tfp 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import net.morocoshi.common.loaders.tfp.events.ITFPFileErrorEvent;
	import net.morocoshi.common.loaders.tfp.events.TFPEventUtil;
	
	/**
	 * ファイルを1つロードする
	 * 
	 * @author tencho
	 */
	public class FileData extends EventDispatcher
	{
		public var path:String;
		public var type:String;
		public var loadedRate:Number;
		public var fileList:Vector.<TFPFile>;
		/**キャッシュ対策用ハッシュ*/
		public var cacheHash:String;
		private var lastHttpStatus:int;
		private var assetPathList:Array;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @param	path	読み込むファイルパス
		 * @param	type	拡張子から判別したファイルの種類
		 * @param	assetPathList	読み込み元ファイルパス
		 */
		public function FileData(path:String, type:String, assetPathList:Array)
		{
			this.path = path;
			this.type = type;
			this.assetPathList = assetPathList;
			lastHttpStatus = 0;
			loadedRate = 0;
			cacheHash = "";
			fileList = new Vector.<TFPFile>;
		}
		
		//--------------------------------------------------------------------------
		//
		//  読み込み
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ファイル読み込み
		 * @param	urlRequest
		 * @param	URLLoaderClass
		 */
		public function load(urlRequest:URLRequest, URLLoaderClass:Class):void
		{
			fileList.length = 0;
			loadedRate = 0;
			//アセットの読み込み開始
			if (type == TFPAssetType.TFP)
			{
				//TFPファイルの読み込み＆展開
				var parser:TFPParser = new TFPParser();
				parser.setLoaderClass(URLLoaderClass);
				parser.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				parser.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				parser.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				parser.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				parser.addEventListener(Event.COMPLETE, tfp_completeHandler);
				//TFPを展開するが、インスタンス変換までは行わない
				parser.load(getHashPath(), false, urlRequest);
			}
			else
			{
				//非TFPファイルの読み込み開始(※ここは引数のクラスでnewしてます)
				var loader:URLLoader = new URLLoaderClass();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				loader.addEventListener(Event.COMPLETE, bytes_completeHandler);
				urlRequest.url = getHashPath();
				loader.load(urlRequest);
			}
		}
		
		private function getHashPath():String 
		{
			return cacheHash? path + "?" + cacheHash : path;
		}
		
		/**
		 * 全てのTFPFileデータの中身を破棄する。どこかにデータを参照渡ししている場合は注意。
		 */
		public function dipose():void 
		{
			if (!fileList) return;
			
			for (var i:int = 0; i < fileList.length; i++) 
			{
				fileList[i].dispose();
			}
			fileList.length = 0;
		}
		
		/**
		 * 読み込んだファイルの最新ハッシュを更新する
		 * @param	lastCacheHash
		 */
		public function setLastCacheHash(lastCacheHash:Object):void 
		{
			for each(var file:TFPFile in fileList)
			{
				lastCacheHash[file.path] = cacheHash;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		private function httpStatusHandler(e:HTTPStatusEvent):void 
		{
			lastHttpStatus = e.status;
		}
		
		private function progressHandler(e:ProgressEvent):void 
		{
			loadedRate = e.bytesLoaded / e.bytesTotal;
			notifyProgress(loadedRate);
		}
		
		/**
		 * TFPデータ読み込み完了
		 * @param	e
		 */
		private function tfp_completeHandler(e:Event):void 
		{
			removeEvents(e.currentTarget as EventDispatcher);
			
			var tfp:TFPParser = e.currentTarget as TFPParser;
			var split:Array = path.split("/");
			var baseDir:String = "";
			if (split.length >= 2)
			{
				split.pop();
				baseDir = split.join("/") + "/";
			}
			for each (var file:TFPFile in tfp.files)
			{
				file.path = baseDir + file.path;
				fileList.push(file);
			}
			
			complete();
		}
		
		/**
		 * 非TFPデータ読み込み完了
		 * @param	e
		 */
		private function bytes_completeHandler(e:Event):void 
		{
			removeEvents(e.currentTarget as EventDispatcher);
			
			var loader:URLLoader = e.currentTarget as URLLoader;
			var file:TFPFile = new TFPFile("", loader.data, type);
			file.path = path;
			fileList.push(file);
			complete();
		}
		
		
		
		/**
		 * 読み込み状況を通知する
		 * @param	force	
		 */
		private function notifyProgress(rate:Number):void 
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, rate, 1));
		}
		
		
		private function complete():void 
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * IOエラー、セキュリティエラー発生時
		 * @param	e
		 */
		private function errorHandler(e:ErrorEvent):void 
		{
			removeEvents(e.currentTarget as EventDispatcher);
			
			//リロード用URLリスト
			var reloadPathList:Vector.<String> = new Vector.<String>;
			for (var i:int = 0; i < assetPathList.length; i++) 
			{
				reloadPathList.push(assetPathList[i]);
			}
			
			//エラーイベント発行
			var errorEvent:ITFPFileErrorEvent = TFPEventUtil.toTFPFileErrorEvent(e);
			errorEvent.reloadPathList = reloadPathList;
			errorEvent.status = lastHttpStatus;
			errorEvent.actualUrl = getHashPath();
			dispatchEvent(errorEvent as ErrorEvent);
		}
		
		/**
		 * イベントリスナー一括削除
		 * @param	target
		 */
		private function removeEvents(target:EventDispatcher):void
		{
			target.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			target.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			target.removeEventListener(Event.COMPLETE, tfp_completeHandler);
			target.removeEventListener(Event.COMPLETE, bytes_completeHandler);
		}
		
	}

}