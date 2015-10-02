package net.morocoshi.common.ui.keyboard 
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	
	/**
	 * キーボード入力管理
	 * 
	 * @author tencho
	 */
	public class KeyInput extends EventDispatcher
	{
		//static public const KEY_INPUT:String = "keyInput";
		//static public const KEY_PUSH:String = "keyPush";
		
		protected var stage:Stage;
		protected var target:InteractiveObject;
		protected var _blockTextField:Boolean;
		protected var _keyEnabled:Boolean;
		protected var _shiftKey:Boolean;
		protected var _ctrlKey:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function KeyInput() 
		{
			_keyEnabled = true;
			_shiftKey = false;
			_ctrlKey = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**
		 * SHIFTキーを押しているか
		 */
		public function get shiftKey():Boolean 
		{
			return _shiftKey;
		}
		
		/**
		 * CTRLキーを押しているか
		 */
		public function get ctrlKey():Boolean 
		{
			return _ctrlKey;
		}
		
		/**
		 * TextFieldフォーカス中はキー入力イベントを発光しないか
		 */
		public function get blockTextField():Boolean 
		{
			return _blockTextField;
		}
		
		public function set blockTextField(value:Boolean):void 
		{
			_blockTextField = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  初期化
		//
		//--------------------------------------------------------------------------
		
		/**
		 * キー入力を判定するInteractiveObjectを渡して初期化
		 * @param	target
		 */
		public function init(target:InteractiveObject):void
		{
			this.target = target;
			target.addEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
			target.addEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
			
			if (target.stage) initStage();
			else target.addEventListener(Event.ADDED_TO_STAGE, initStage);;
		}
		
		//--------------------------------------------------------------------------
		//
		//  メイン処理
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		protected function initStage(e:Event = null):void
		{
			stage = target.stage;
			stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
			stage.addEventListener(FocusEvent.FOCUS_IN, stage_focusHandler);
			stage.addEventListener(FocusEvent.FOCUS_OUT, stage_focusHandler);
		}
		
		protected function deactivateHandler(e:Event):void 
		{
			_shiftKey = _ctrlKey = false;
		}
		
		private function stage_focusHandler(e:FocusEvent):void 
		{
			if (e.target is TextField)
			{
				_keyEnabled = (e.type == FocusEvent.FOCUS_OUT);
			}
		}
		
		private function keyUpDownHandler(e:KeyboardEvent):void 
		{
			_shiftKey = e.shiftKey;
			_ctrlKey = e.ctrlKey;
			if (!_keyEnabled && _blockTextField) return;
			dispatchEvent(e);
		}
		
	}

}