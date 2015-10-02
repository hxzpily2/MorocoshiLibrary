package net.morocoshi.common.loaders.tfp.events 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * TFPLoaderがdispactchするエラーイベント
	 * 
	 * @author tencho
	 */
	public class TFPErrorEvent extends ErrorEvent 
	{
		/**TFPLoaderがファイルの読み込みに失敗した場合*/
		static public const LOAD_ERROR:String = "loadError";
		/**TFPLoaderがファイル読み込み後のインスタンス化に失敗した場合 (拡張子のミスでテキストデータを画像に変換しようとしたなど)*/
		static public const INSTANTIATION_ERROR:String = "instantiationError";
		
		/**
		 * リロードに必要なURLのリスト
		 * （image/test.jpgを読もうとしてimage.tfpが読まれた時にエラーが出た場合、image.tfpではなく元のimage/test.jpgがリストに加わります）
		 */
		public var allReloadPathList:Vector.<String>;
		
		/**
		 * エラーイベント（TFPIOErrorEvent、TFPSecurityErrorEvent）のリスト
		 */
		public var errorEventList:Vector.<ITFPFileErrorEvent>;
		
		private var _allBytesLoaded:uint;
		
		private var _allBytesTotal:uint;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 * @param	text
		 * @param	id
		 */
		public function TFPErrorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, text:String = "", id:int = 0) 
		{ 
			super(type, bubbles, cancelable, text, id);
			allReloadPathList = new Vector.<String>;
			errorEventList = new Vector.<ITFPFileErrorEvent>;
			_allBytesLoaded = 0;
			_allBytesTotal = 0;
		} 
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		public function get allBytesLoaded():uint 
		{
			return _allBytesLoaded;
		}
		
		public function get allBytesTotal():uint 
		{
			return _allBytesTotal;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		override public function clone():Event
		{
			var event:TFPErrorEvent = new TFPErrorEvent(type, bubbles, cancelable, text, errorID);
			event.allReloadPathList = allReloadPathList.concat();
			event.errorEventList = errorEventList.concat();
			return event;
		}
		
		public override function toString():String 
		{ 
			return formatToString("TFPErrorEvent", "type", "bubbles", "cancelable", "eventPhase", "text", "errorID"); 
		}
		
		public function attachErrorEvent(error:ITFPFileErrorEvent):void 
		{
			errorEventList.push(error);
			
			_allBytesLoaded += error.bytesLoaded;
			_allBytesTotal += error.bytesTotal;
			
			var n:int = error.reloadPathList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var path:String = error.reloadPathList[i];
				if (allReloadPathList.indexOf(path) == -1)
				{
					allReloadPathList.push(path);
				}
			}
		}
		
	}
	
}