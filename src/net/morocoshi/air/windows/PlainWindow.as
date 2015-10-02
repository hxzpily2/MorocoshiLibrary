package net.morocoshi.air.windows 
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Stage;
	import flash.events.Event;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.air.windows.WindowUtil;
	
	/**
	 * 何もないウィンドウ
	 * 
	 * @author tencho
	 */
	public class PlainWindow 
	{
		public var cancelCallback:Function;
		
		public function PlainWindow() 
		{
		}
		
		public function open(option:NativeWindowInitOptions = null, width:Number = 600, height:Number = 400, cancel:Function = null, activate:Boolean = true):NativeWindow
		{
			cancelCallback = cancel;
			var window:NativeWindow = new NativeWindow(option || WindowUtil.createOption(null, false, false, false));
			
			var stage:Stage = window.stage;
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			window.addEventListener(Event.CLOSING, win_closeHandler);
			window.title = new ApplicationData().name;
			window.stage.stageWidth = width;
			window.stage.stageHeight = height;
			
			WindowUtil.moveCenter(window);
			if (activate) window.activate();
			
			return window;
		}
		
		private function win_closeHandler(e:Event):void 
		{
			if (cancelCallback != null) cancelCallback();
		}
		
	}

}