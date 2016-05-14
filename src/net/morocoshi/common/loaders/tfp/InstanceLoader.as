package net.morocoshi.common.loaders.tfp 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.utils.Dictionary;
	import net.morocoshi.common.loaders.tfp.events.TFPErrorEvent;
	import net.morocoshi.common.loaders.tfp.events.TFPIOErrorEvent;
	
	/**
	 * TFPLibrary内の全ファイルのByteArrayをインスタンスに変換するクラス
	 * @author tencho
	 */
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "instantiationError", type = "net.morocoshi.loaders.tfp.events.TFPErrorEvent")]
	
	public class InstanceLoader extends EventDispatcher
	{
		private var completeCount:int;
		private var totalFileNum:int;
		private var memory:Dictionary = new Dictionary();
		private var errorEvent:TFPErrorEvent;
		private var clearByteArray:Boolean;
				
		public function InstanceLoader() 
		{
		}
		
		/**
		 * TFPLibraryオブジェクト内の全TFPFileのByteArrayをインスタンスに変換する。TFPFileが持つ不用なByteArrayはここで破棄される
		 * @param	library	TFPLibraryオブジェクト
		 * @param	clearByteArray	インスタンス変換後にTFPFile.byteArrayをclearする
		 */
		public function load(library:TFPLibrary, clearByteArray:Boolean):void
		{
			completeCount = 0;
			this.clearByteArray = clearByteArray;
			
			var text:String = "[TFP]アセットのインスタンス化に失敗しました。";
			errorEvent = new TFPErrorEvent(TFPErrorEvent.INSTANTIATION_ERROR, false, false, text, 0);
				
			if (!library.files.length)
			{
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			totalFileNum = library.files.length;
			for each(var f:TFPFile in library.files)
			{
				parseFile(f);
			}
		}
		
		private function parseFile(f:TFPFile):void
		{
			if (f.asset)
			{
				completeFile(f);
				return;
			}
			
			if (!f.byteArray)
			{
				errorFile(f);
				return;
			}
			
			switch(f.type)
			{
				case TFPAssetType.TFP:
				case TFPAssetType.BYTEARRAY:
					f.asset = f.byteArray;
					completeFile(f);
					break;
				case TFPAssetType.SOUND:
					var sound:Sound = new Sound();
					sound.loadCompressedDataFromByteArray(f.byteArray, f.byteArray.length);
					if (clearByteArray)
					{
						f.byteArray.clear();
					}
					f.asset = sound;
					/*
					 * サウンドのエラーチェック（重そうなので無効にしてる）
					try
					{
						sound.play(0, 1).stop();
					}
					catch(e:Error)
					{
						errorFile(f);
						return;
					}
					*/
					completeFile(f);
					break;
				case TFPAssetType.TEXT:
					f.asset = f.byteArray.readUTFBytes(f.byteArray.length);
					if (clearByteArray)
					{
						f.byteArray.clear();
					}
					completeFile(f);
					break;
				case TFPAssetType.XML:
					f.asset = new XML(f.byteArray.readUTFBytes(f.byteArray.length));
					if (clearByteArray)
					{
						f.byteArray.clear();
					}
					completeFile(f);
					break;
				//FLV変換は未検証
				case TFPAssetType.VIDEO:
					var nc:NetConnection = new NetConnection();
					nc.connect(null);
					var ns:NetStream = new NetStream(nc);
					ns.client = { onMetaData:flv_metaDataHandler };
					ns.play(null);
					ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
					ns.appendBytes(f.byteArray);
					ns.pause();
					f.asset = ns;
					completeFile(f);
					break;
				case TFPAssetType.IMAGE:
					var loader:Loader = new Loader();
					memory[loader.contentLoaderInfo] = f;
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_completeHandler);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, image_errorHandler);
					loader.loadBytes(f.byteArray);
					break;
			}
		}
		
		private function flv_metaDataHandler(obj:*):void 
		{
		}
		
		private function image_completeHandler(e:Event):void 
		{
			var contentLoaderInfo:LoaderInfo = e.target as LoaderInfo;
			contentLoaderInfo.removeEventListener(Event.COMPLETE, image_completeHandler);
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, image_errorHandler);
			
			var f:TFPFile = memory[e.currentTarget];
			//画像のByteArray破棄
			if (clearByteArray)
			{
				f.byteArray.clear();
			}
			try
			{
				f.asset = Bitmap(LoaderInfo(e.currentTarget).content).bitmapData;
			}
			catch (e:Error)
			{
				//セキュリティサンドボックスエラー
				errorFile(f);
				return;
			}
			completeFile(f);
		}
		
		private function image_errorHandler(e:IOErrorEvent):void 
		{
			var contentLoaderInfo:LoaderInfo = e.target as LoaderInfo;
			contentLoaderInfo.removeEventListener(Event.COMPLETE, image_completeHandler);
			contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, image_errorHandler);
			
			var f:TFPFile = memory[e.currentTarget];
			errorFile(f);
		}
		
		private function completeFile(f:TFPFile):void
		{
			if (clearByteArray)
			{
				f.byteArray = null;
			}
			f.error = false;
			countUp();
		}
		
		private function errorFile(f:TFPFile):void
		{
			f.byteArray = null;
			f.error = true;
			
			var error:TFPIOErrorEvent = new TFPIOErrorEvent(IOErrorEvent.IO_ERROR, false, false, errorEvent.text, 0);
			error.actualUrl = f.path;
			error.reloadPathList.push(f.path);
			errorEvent.attachErrorEvent(error);
			
			countUp();
		}
		
		private function countUp():void 
		{
			if (++completeCount < totalFileNum) return;
			
			if (errorEvent.errorEventList.length)
			{
				dispatchEvent(errorEvent);
				return;
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}