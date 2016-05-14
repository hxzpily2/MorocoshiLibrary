package net.morocoshi.common.loaders.tfp 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import net.morocoshi.common.loaders.tfp.events.TFPErrorEvent;
	
	[Event(name = "ioError", type = "flash.events.IOErrorEvent")]
	[Event(name = "securityError", type = "flash.events.SecurityErrorEvent")]
	[Event(name = "progress", type = "flash.events.ProgressEvent")]
	[Event(name = "complete", type = "flash.events.Event")]
	
	/**
	 * TFPファイルを読み込んでパースするクラス。
	 * 
	 * @author tencho
	 */
	public class TFPParser extends EventDispatcher
	{
		private var convertInstance:Boolean;
		private var library:TFPLibrary;
		
		/**全アセットデータの参照*/
		public var asset:Object;
		/**全フォルダデータの参照*/
		public var folder:Object;
		/**全てのファイルのリスト*/
		public var files:Vector.<TFPFile>;
		/**ルートフォルダ*/
		public var root:TFPFolder;
		/**データロード時に使用するURLLoaderクラス*/
		private var URLLoaderClass:Class;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function TFPParser() 
		{
			asset = { };
			folder = { };
			files = new Vector.<TFPFile>;
			URLLoaderClass = URLLoader;
		}
		
		//--------------------------------------------------------------------------
		//
		//  使用クラスの設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ロード時に使用するURLLoaderクラスを指定する
		 * @param	urlLoader
		 */
		public function setLoaderClass(urlLoader:Class):void
		{
			URLLoaderClass = urlLoader;
		}
		
		//--------------------------------------------------------------------------
		//
		//  データの読み込み、パース
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 指定URLからTFPファイルを読み込んでパースする
		 * @param	path	TFPファイルのパス
		 */
		public function load(path:String, convertInstance:Boolean = true, request:URLRequest = null):void
		{
			this.convertInstance = convertInstance;
			var loader:URLLoader = new URLLoaderClass();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatusHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, loader_progressHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
			loader.addEventListener(Event.COMPLETE, loader_completeHandler);
			if (!request)
			{
				request = new URLRequest();
			}
			request.url = path;
			loader.load(request);
		}
		
		/**
		 * TFPデータ（ByteArray）をパースする
		 * @param	byteArray	TFPデータ
		 */
		public function parse(byteArray:ByteArray, convertInstance:Boolean = true, clearByteArray:Boolean = true):void 
		{
			library = new TFPConverter().parse(byteArray);
			if (!library)
			{
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
				return;
			}
			
			for each(var f:TFPFile in library.files)
			{
				f.type = TFPLoader.extension.getTypeByFileName(f.name);
			}
			
			//インスタンスに変換する場合
			if (convertInstance)
			{
				var loader:InstanceLoader = new InstanceLoader();
				loader.addEventListener(TFPErrorEvent.INSTANTIATION_ERROR, instance_errorHandler);
				loader.addEventListener(Event.COMPLETE, instance_completeHandler);
				loader.load(library, clearByteArray);
			}
			else
			{
				complete();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  データの取得
		//
		//--------------------------------------------------------------------------
		
		/**
		 * フォルダパス指定でフォルダデータを取得
		 * @param	path
		 * @return
		 */
		public function getFolder(path:String):TFPFolder
		{
			if (path.charAt(path.length - 1) != "/") path += "/";
			return folder[path];
		}
		
		/**
		 * ファイルパス指定でファイルのデータを取得
		 * @param	path
		 * @return
		 */
		public function getAsset(path:String):*
		{
			return asset[path];
		}
		
		//--------------------------------------------------------------------------
		//
		//  データの破棄
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 読み込んだデータの参照を全て破棄する
		 */
		public function dispose():void
		{
			folder = { };
			asset = { };
			files.length = 0;
			library = null;
			root = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function loader_httpStatusHandler(e:HTTPStatusEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function loader_securityErrorHandler(e:SecurityErrorEvent):void 
		{
			removeLoaderEvent(e.currentTarget as URLLoader);
			dispatchEvent(e);
		}
		
		private function loader_ioErrorHandler(e:IOErrorEvent):void 
		{
			removeLoaderEvent(e.currentTarget as URLLoader);
			dispatchEvent(e);
		}
		
		private function loader_progressHandler(e:ProgressEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function loader_completeHandler(e:Event):void 
		{
			removeLoaderEvent(e.currentTarget as URLLoader);
			var data:ByteArray = URLLoader(e.currentTarget).data;
			parse(data, convertInstance);
		}
		
		private function instance_errorHandler(e:TFPErrorEvent):void 
		{
			removeInstanceEvent(e.currentTarget as InstanceLoader);
			dispatchEvent(e);
		}
		
		private function instance_completeHandler(e:Event):void 
		{
			removeInstanceEvent(e.currentTarget as InstanceLoader);
			complete();
		}
		
		/**
		 * 全ての処理が完了
		 */
		private function complete():void 
		{
			//libraryからデータを取り出す
			for each(var file:TFPFile in library.files)
			{
				asset[file.path] = file.asset;
			}
			for each(var fd:TFPFolder in library.folders)
			{
				folder[fd.path] = fd;
			}
			folder["/"] = root = library.root;
			files = library.files;
			library = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function removeLoaderEvent(loader:URLLoader):void 
		{
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatusHandler);
			loader.removeEventListener(Event.COMPLETE, loader_completeHandler);
			loader.removeEventListener(ProgressEvent.PROGRESS, loader_progressHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
		}
		
		private function removeInstanceEvent(loader:InstanceLoader):void 
		{
			loader.removeEventListener(Event.COMPLETE, instance_completeHandler);
			loader.removeEventListener(TFPErrorEvent.INSTANTIATION_ERROR, instance_errorHandler);
		}
		
	}

}