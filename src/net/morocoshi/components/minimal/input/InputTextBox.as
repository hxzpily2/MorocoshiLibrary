package net.morocoshi.components.minimal.input
{
	import com.bit101.components.InputText;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * ENTERキーやフォーカスの移動で決定イベント（Event.COMPLETE）を通知するInputText
	 *
	 * @author tencho
	 */
	public class InputTextBox extends InputText
	{
		private var _stage:Stage;
		private var enterHandler:Function;
		
		/**
		 * コンストラクタ
		 * @param	parent
		 * @param	xpos
		 * @param	ypos
		 * @param	text
		 * @param	defaultHandler
		 */
		public function InputTextBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, text:String = "", defaultHandler:Function = null, enterHandler:Function = null)
		{
			this.enterHandler = enterHandler;
			super(parent, xpos, ypos, text, defaultHandler);
			
			addEventListener(Event.ADDED_TO_STAGE, addedHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
			addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			
			if (stage)
			{
				addedHandler(null);
			}
		}
		
		private function focusInHandler(e:FocusEvent):void 
		{
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function focusOutHandler(e:FocusEvent):void 
		{
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			notifyComplete();
		}
		
		private function removedHandler(e:Event):void
		{
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			_stage = null;
		}
		
		private function addedHandler(e:Event):void
		{
			_stage = stage;
		}
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				notifyComplete();
			}
		}
		
		private function notifyComplete():void 
		{
			var e:Event = new Event(Event.COMPLETE);
			dispatchEvent(e);
			if (enterHandler != null) enterHandler(e);
		}
	
	}

}