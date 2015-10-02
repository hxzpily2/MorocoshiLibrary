package net.morocoshi.components.minimal.buttons 
{
	import com.bit101.components.Component;
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author 
	 */
	public class ButtonHList extends HBox
	{
		private var _click:Function;
		private var _data:Dictionary = new Dictionary();
		private var _buttons:Vector.<Component> = new Vector.<Component>();
		
		public var onClick:Function;
		public var newButton:Function;
		
		/**
		 * コンストラクタ
		 * @param	parent	
		 * @param	labels	ラベルテキストのリスト
		 * @param	ids	ボタンの識別IDのリスト
		 * @param	xpos	X座標
		 * @param	ypos	Y座標
		 * @param	click	クリック時のイベント
		 * @param	create	ボタン生成時に実行される関数。Componentオブジェクトを返す関数を指定。
		 */
		public function ButtonHList(parent:DisplayObjectContainer = null, labels:Array = null, ids:Array = null, xpos:Number = 0, ypos:Number = 0, click:Function = null, create:Function = null) 
		{
			super(parent, xpos, ypos);
			if (create != null)
			{
				newButton = create;
			}
			else
			{
				newButton = function(txt:String):Component
				{
					return new PushButton(null, 0, 0, txt);
				}
			}
			if (!labels) labels = [];
			if (!ids) ids = [];
			for (var i:int = 0; i < labels.length; i++) 
			{
				addButton(labels[i], ids[i] || "");
			}
			_click = click;
		}
		
		public function setButtonSize(width:Number, height:Number):void
		{
			setButtonWidth(width);
			setButtonHeight(height);
		}
		
		public function setButtonHeight(height:Number):void
		{
			for each (var btn:Component in _buttons) 
			{
				btn.height = height;
			}
		}
		
		public function setButtonWidth(width:Number):void
		{
			for each (var btn:Component in _buttons) 
			{
				btn.width = width;
			}
		}
		
		public function getButtonAt(n:int):Component
		{
			return _buttons[n];
		}
		
		public function addButton(str:String, id:String = "", extra:* = null):Component
		{
			var btn:Component = newButton(str);
			btn.addEventListener(MouseEvent.CLICK, onClickButton);
			addChild(btn);
			_data[btn] = { index:_buttons.length, id:id, extra:extra };
			_buttons.push(btn);
			return btn;
		}
		
		private function onClickButton(e:MouseEvent):void 
		{
			var evt:ButtonListEvent = new ButtonListEvent(ButtonListEvent.CLICK);
			var d:Object = _data[e.currentTarget];
			evt.index = d.index;
			evt.label = d.label;
			evt.id = d.id;
			if (_click != null) _click(evt);
		}
		
		public function update():void
		{
			var c:Component = new Component(this);
			removeChild(c);
		}
		
	}

}