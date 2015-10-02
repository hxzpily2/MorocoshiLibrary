package net.morocoshi.common.loaders.tfp.events 
{
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TFPEventUtil 
	{
		/**
		 * ファイル読み込みエラーイベントをTFPIOErrorEvent、SecurityErrorEventに変換する
		 * @param	event
		 * @return
		 */
		static public function toTFPFileErrorEvent(event:ErrorEvent):ITFPFileErrorEvent
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			
			if (event is IOErrorEvent)
			{
				var ioErrorEvent:TFPIOErrorEvent = new TFPIOErrorEvent(event.type, event.bubbles, event.cancelable, event.text, event.errorID);
				if (loader)
				{
					ioErrorEvent.loader = loader;
					ioErrorEvent.bytesLoaded = loader.bytesLoaded;
					ioErrorEvent.bytesTotal = loader.bytesTotal;
				}
				return ioErrorEvent;
			}
			
			if (event is SecurityErrorEvent)
			{
				var securityErrorEvent:TFPSecurityErrorEvent = new TFPSecurityErrorEvent(event.type, event.bubbles, event.cancelable, event.text, event.errorID);
				if (loader)
				{
					securityErrorEvent.loader = loader;
					securityErrorEvent.bytesLoaded = loader.bytesLoaded;
					securityErrorEvent.bytesTotal = loader.bytesTotal;
				}
				return securityErrorEvent;
			}
			
			return null;
		}
		
	}

}