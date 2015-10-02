package net.morocoshi.air.components.minimal 
{
	import com.bit101.components.Label;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.common.ui.keyboard.KeyInput;
	import net.morocoshi.components.minimal.Bit101Util;
	import net.morocoshi.components.minimal.buttons.ButtonHList;
	import net.morocoshi.components.minimal.buttons.ButtonListEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ConfirmDialog 
	{
		public var key:KeyInput;
		public var win:NativeWindow;
		public var autoClose:Boolean;
		
		public var okCallback:Function;
		public var cancelCallback:Function;
		public var padding:Number = 20;
		
		public function ConfirmDialog()
		{
		}
		
		public function open(text:String, option:NativeWindowInitOptions = null, ok:Function = null, cancel:Function = null, autoClose:Boolean = true, addHeight:Number = 0, minWidth:Number = 200):NativeWindow
		{
			win = new NativeWindow(option || WindowUtil.createOption(null, false, false, false));
			
			var stage:Stage = win.stage;
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			key = new KeyInput();
			key.init(win.stage);
			key.blockTextField = true;
			key.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			
			this.autoClose = autoClose;
			okCallback = ok;
			cancelCallback = cancel;
			win.title = new ApplicationData().name;
			win.addEventListener(Event.CLOSING, dialog_closingHandler);
			var label:Label = new Label(win.stage, padding, padding, text);
			Bit101Util.setLabelSelectable(label, true);
			var buttonHeight:Number = 20;
			
			win.stage.stageWidth = Math.max(minWidth, label.width + padding * 2);
			win.stage.stageHeight = label.textField.textHeight + buttonHeight + 20 + padding * 2 + addHeight;
			
			var buttons:ButtonHList = new ButtonHList(win.stage, ["OK", "キャンセル"], ["ok", "cancel"], 0, 0, dialog_clickHandler);
			buttons.setButtonSize(65, buttonHeight);
			buttons.spacing = 15;
			buttons.update();
			buttons.x = (win.stage.stageWidth - buttons.width) / 2;
			buttons.y = win.stage.stageHeight - buttons.height - padding;
			
			WindowUtil.moveCenter(win);
			win.activate();
			
			return win;
		}
		
		private function keyDownHandler(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER) ok();
			if (e.keyCode == Keyboard.ESCAPE) cancel();
		}
		
		private function dialog_closingHandler(e:Event):void 
		{
			if (cancelCallback != null) cancelCallback();
		}
		
		private function dialog_clickHandler(e:ButtonListEvent):void 
		{
			if (e.id == "ok") ok();
			if (e.id == "cancel") cancel();
		}
		
		private function ok():void 
		{
			if (okCallback != null) okCallback();
			if (autoClose) win.close();
		}
		
		private function cancel():void 
		{
			if (cancelCallback != null) cancelCallback();
			if (autoClose) win.close();
		}
		
	}

}