package net.morocoshi.air.components.minimal 
{
	import com.bit101.components.Label;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.common.ui.keyboard.KeyInput;
	import net.morocoshi.components.minimal.Bit101Util;
	import net.morocoshi.components.minimal.buttons.ButtonHList;
	import net.morocoshi.components.minimal.buttons.ButtonListEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DetailDialog 
	{
		public var win:NativeWindow;
		public var buttons:ButtonHList;
		public var key:KeyInput;
		public var keyCodes:Array;
		public var autoClose:Boolean;
		
		public var okCallback:Function;
		public var cancelCallback:Function;
		public var padding:Number = 20;
		
		public function DetailDialog() 
		{
		}
		
		/**
		 * 
		 * @param	text
		 * @param	buttonList	ボタンラベルリスト
		 * @param	keyCodes	ショートカットキーコード
		 * @param	click	引数にIN
		 * @param	cancel
		 * @param	autoClose
		 * @param	buttonWidth
		 * @param	addHeight
		 * @param	minWidth
		 * @return
		 */
		public function open(text:String, option:NativeWindowInitOptions, labelList:Array, keyCodes:Array, click:Function = null, cancel:Function = null, autoClose:Boolean = true, buttonWidth:int = 60, addHeight:Number = 0, minWidth:Number = 200, activate:Boolean = true):NativeWindow
		{
			this.autoClose = autoClose;
			this.keyCodes = keyCodes || [];
			okCallback = click;
			cancelCallback = cancel;
			
			win = new NativeWindow(option || WindowUtil.createOption(null, false, false, false));
			var stage:Stage = win.stage;
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			key = new KeyInput();
			key.init(win.stage);
			key.blockTextField = true;
			key.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			
			win.title = new ApplicationData().name;
			win.addEventListener(Event.CLOSING, dialog_closingHandler);
			var label:Label = new Label(win.stage, padding, padding, text);
			Bit101Util.setLabelSelectable(label, true);
			var buttonHeight:Number = 20;
			
			win.stage.stageWidth = Math.max(minWidth, label.width + padding * 2);
			win.stage.stageHeight = label.textField.textHeight + buttonHeight + 20 + padding * 2 + addHeight;
			
			var ids:Array = labelList.map(function(...args):int { return args[1] } );
			buttons = new ButtonHList(win.stage, labelList, ids, 0, 0, dialogDetail_clickHandler);
			buttons.setButtonSize(buttonWidth, buttonHeight);
			buttons.spacing = 15;
			buttons.update();
			buttons.x = (win.stage.stageWidth - buttons.width) / 2;
			buttons.y = win.stage.stageHeight - buttons.height - padding;
			
			WindowUtil.moveCenter(win);
			if (activate) win.activate();
			
			return win;
		}
		
		private function keyDownHandler(e:KeyboardEvent):void 
		{
			if (!keyCodes) return;
			var i:int = keyCodes.indexOf(e.keyCode);
			if (i == -1) return;
			select(i);
		}
		
		private function dialog_closingHandler(e:Event):void 
		{
			if (cancelCallback != null) FrameTimer.setTimer(5, cancelCallback);
		}
		
		private function dialogDetail_clickHandler(e:ButtonListEvent):void 
		{
			select(int(e.id));
		}
		
		private function select(index:int):void 
		{
			if (okCallback.length)
			{
				okCallback(index);
			}
			else
			{
				okCallback();
			}
			if (autoClose) win.close();
		}
		
	}

}