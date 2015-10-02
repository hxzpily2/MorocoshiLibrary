package net.morocoshi.moja3d.stats 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import net.morocoshi.common.graphics.Create;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class StatsCheckBox extends Sprite 
	{
		private var baseBox:Sprite;
		private var checkedMark:Sprite;
		private var _selected:Boolean;
		private var _textField:TextField;
		private var _label:String;
		
		public function StatsCheckBox(label:String, selected:Boolean = false) 
		{
			baseBox = Create.box(0, 0, 10, 10, 0x0, 1);
			checkedMark = Create.box(0, 0, 6, 6, 0xffffff, 1, 2, 2);
			checkedMark.mouseEnabled = false;
			addEventListener(MouseEvent.CLICK, clickHandler);
			this.mouseChildren = false;
			buttonMode = true;
			
			_textField = new TextField();
			_textField.defaultTextFormat = new TextFormat("Arial", 12, 0x0, false);
			_textField.x = 12;
			_textField.y = -4;
			_textField.selectable = false;
			_textField.autoSize = TextFieldAutoSize.LEFT;
			
			addChild(baseBox);
			addChild(checkedMark);
			addChild(_textField);
			
			_selected = selected;
			this.label = label;
			update();
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			selected = !_selected;
		}
		
		private function update():void 
		{
			checkedMark.visible = _selected;
		}
		
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void 
		{
			_selected = value;
			update();
			dispatchEvent(new Event(Event.SELECT));
		}
		
		public function get label():String 
		{
			return _label;
		}
		
		public function set label(value:String):void 
		{
			_textField.text = _label = value;
		}
		
	}

}