package net.morocoshi.air.components.minimal 
{
	import com.bit101.components.TextArea;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import net.morocoshi.air.windows.ModalManager;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Modal 
	{
		
		public function Modal() 
		{
		}
		
		static public var logWindow:NativeWindow;
		static private var logTextArea:TextArea;
		
		static public function addLog(text:*, show:Boolean = true):void
		{
			if (logWindow == null)
			{
				logWindow = new MessageDialog().open("", null, log_okHandler, null, false, 400, 600);
				logWindow.addEventListener(Event.CLOSING, log_closingHandler);
				logTextArea = new TextArea(null, 10, 10);
				logTextArea.width = 580;
				logTextArea.height = 400;
				logWindow.stage.addChild(logTextArea);
			}
			var str:String = String(text);
			var newline:String = (str.charAt(str.length - 1) == "\n")? "" : "\n";
			logTextArea.text += str + newline;
			ModalManager.activate(logWindow);
		}
		
		static private function log_okHandler():void 
		{
			logWindow.visible = false;
			ModalManager.remove(logWindow);
		}
		
		static private function log_closingHandler(e:Event):void 
		{
			e.preventDefault();
			logWindow.visible = false;
			ModalManager.remove(logWindow);
		}
		
		static public function alert(text:*, ok:Function = null, cancel:Function = null, autoClose:Boolean = true, addHeight:Number = 0, minWidth:Number = 150, okLabel:String = "OK"):NativeWindow
		{
			var win:NativeWindow = new MessageDialog().open(String(text), null, ok, cancel, autoClose, addHeight, minWidth, okLabel);
			ModalManager.activate(win);
			return win;
		}
		
		static public function confirm(text:String, ok:Function, cancel:Function = null, autoClose:Boolean = true, addHeight:Number = 0, minWidth:Number = 200):NativeWindow 
		{
			var win:NativeWindow = new ConfirmDialog().open(text, null, ok, cancel, autoClose, addHeight, minWidth);
			ModalManager.activate(win);
			return win;
		}
		
		static public function detail(text:String, labelList:Array, keyCodes:Array, click:Function = null, cancel:Function = null, autoClose:Boolean = true, buttonWidth:int = 60, addHeight:Number = 0, minWidth:Number = 200):NativeWindow 
		{
			var win:NativeWindow = new DetailDialog().open(text, null, labelList, keyCodes, click, cancel, autoClose, buttonWidth, addHeight, minWidth);
			ModalManager.activate(win);
			return win;
		}
		
		static public function askSave(save:Function, done:Function, cancel:Function, text:String = "現在の変更を保存しますか？"):NativeWindow
		{
			var askSave_selectHandler:Function = function(id:int):void 
			{
				switch (id)
				{
					case 0:
						if (save != null)
						{
							if (save() !== false)
							{
								if (done != null) done();
							}
							else
							{
								if (cancel != null) cancel();
							}
						}
						break;
					case 1: 
						if (done != null) done();
						break;
					case 2:
						if (cancel != null) cancel();
						break;
				}
			};
			var win:NativeWindow = Modal.detail(text, ["はい", "いいえ", "キャンセル"], [Keyboard.ENTER, -1, Keyboard.ESCAPE], askSave_selectHandler, null, true, 65, 0, 300);
			ModalManager.activate(win);
			return win;
		}
		
	}

}