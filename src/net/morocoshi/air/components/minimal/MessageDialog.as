package net.morocoshi.air.components.minimal 
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.common.ui.keyboard.KeyInput;
	import net.morocoshi.components.minimal.Bit101Util;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MessageDialog 
	{
		
		public var padding:Number;
		private var _background:uint;
		public var key:KeyInput;
		public var autoClose:Boolean;
		public var window:NativeWindow;
		public var keyEnabled:Boolean;
		
		public var okCallback:Function;
		public var cancelCallback:Function;
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function MessageDialog() 
		{
			padding = 20;
			keyEnabled = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function get background():uint 
		{
			return _background;
		}
		
		public function set background(value:uint):void 
		{
			_background = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function open(text:String = "", option:NativeWindowInitOptions = null, ok:Function = null, cancel:Function = null, autoClose:Boolean = true, addHeight:int = 0, minWidth:int = 150, okLabel:String = "OK", activate:Boolean = true):NativeWindow
		{
			okCallback = ok;
			cancelCallback = cancel;
			this.autoClose = autoClose;
			window = new NativeWindow(option || WindowUtil.createOption(null, false, false, false));
			
			var stage:Stage = window.stage;
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			key = new KeyInput();
			key.init(stage);
			key.blockTextField = true;
			key.addEventListener(KeyboardEvent.KEY_DOWN, message_keyDownHandler);
			
			window.addEventListener(Event.CLOSING, win_closeHandler);
			window.title = new ApplicationData().name;
			var label:Label = new Label(stage, padding, padding, text);
			Bit101Util.setLabelSelectable(label, true);
			
			var okButton:PushButton = new PushButton(stage, 0, 0, okLabel, message_clickHandler);
			okButton.width = 80;
			
			//label.textField.addEventListener(Event.CHANGE, 
			var lastWidth:int = label.textField.textWidth;
			var lastHeight:int = label.textField.textHeight;
			var check:Function = function(e:Event):void
			{
				if (lastWidth == window.stage.stageWidth && lastHeight == window.stage.stageHeight) return;
				update();
			}
			
			var update:Function = function():void
			{
				window.stage.stageWidth = Math.max(minWidth, label.width + padding * 2);
				window.stage.stageHeight = label.textField.textHeight + 40 + padding * 2 + addHeight;
				okButton.x = (stage.stageWidth - okButton.width) / 2;
				okButton.y = window.stage.stageHeight - okButton.height - padding;
				lastWidth = label.textField.textWidth;
				lastHeight = label.textField.textHeight;
			}
			
			update();
			label.textField.addEventListener(Event.EXIT_FRAME, check);
			
			WindowUtil.moveCenter(window);
			if (activate)
			{
				window.activate();
			}
			
			return window;
		}
		
		public function openHTML(text:String = "", option:NativeWindowInitOptions = null, ok:Function = null, cancel:Function = null, autoClose:Boolean = true, addHeight:int = 0, minWidth:int = 150, okLabel:String = "OK", activate:Boolean = true):void 
		{
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		private function win_closeHandler(e:Event):void 
		{
			if (cancelCallback != null) FrameTimer.setTimer(5, cancelCallback);
		}
		
		private function message_clickHandler(e:Event):void 
		{
			ok();
		}
		
		private function ok():void 
		{
			if (autoClose) window.close();
			if (okCallback != null) FrameTimer.setTimer(5, okCallback);
		}
		
		private function message_keyDownHandler(e:KeyboardEvent):void 
		{
			if (!keyEnabled) return;
			if (e.keyCode == Keyboard.ENTER) ok();
		}
		
	}

}