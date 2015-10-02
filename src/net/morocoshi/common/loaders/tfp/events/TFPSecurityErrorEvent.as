package net.morocoshi.common.loaders.tfp.events 
{
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	
	/**
	 * ファイル読み込みエラーイベント
	 * 
	 * @author tencho
	 */
	public class TFPSecurityErrorEvent extends SecurityErrorEvent implements ITFPFileErrorEvent 
	{
		private var _loader:URLLoader;
		private var _actualUrl:String;
		private var _status:int;
		private var _reloadPathList:Vector.<String>;
		private var _bytesLoaded:uint;
		private var _bytesTotal:uint;
		
		public function TFPSecurityErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="", id:int=0) 
		{
			super(type, bubbles, cancelable, text, id);
			_bytesLoaded = 0;
			_bytesTotal = 0;
			_reloadPathList = new Vector.<String>;
		}
		
		override public function clone():Event 
		{
			var event:TFPIOErrorEvent = new TFPIOErrorEvent(type, bubbles, cancelable, text, errorID);
			event.loader = loader;
			event.status = status;
			event.bytesLoaded = bytesLoaded;
			event.bytesTotal = bytesTotal;
			event.reloadPathList = reloadPathList.concat();
			return event;
		}
		
		public override function toString():String
		{
			return formatToString("TFPSecurityErrorEvent", "type", "actualUrl", "status", "bubbles", "cancelable", "eventPhase", "text", "id");
		}
		
		/* INTERFACE net.morocoshi.loaders.tfp.events.ITFPFileErrorEvent */
		
		public function get bytesLoaded():uint 
		{
			return _bytesLoaded;
		}
		
		public function set bytesLoaded(value:uint):void 
		{
			_bytesLoaded = value;
		}
		
		public function get bytesTotal():uint 
		{
			return _bytesTotal;
		}
		
		public function set bytesTotal(value:uint):void 
		{
			_bytesTotal = value;
		}
		
		public function get loader():URLLoader 
		{
			return _loader;
		}
		
		public function set loader(value:URLLoader):void 
		{
			_loader = value;
		}
		
		public function get actualUrl():String 
		{
			return _actualUrl;
		}
		
		public function set actualUrl(value:String):void 
		{
			_actualUrl = value;
		}
		
		public function get status():int 
		{
			return _status;
		}
		
		public function set status(value:int):void 
		{
			_status = value;
		}
		
		public function get reloadPathList():Vector.<String> 
		{
			return _reloadPathList;
		}
		
		public function set reloadPathList(value:Vector.<String>):void 
		{
			_reloadPathList = value;
		}
		
	}

}