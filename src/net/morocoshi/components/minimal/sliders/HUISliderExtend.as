package net.morocoshi.components.minimal.sliders 
{
	import com.bit101.components.HUISlider;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class HUISliderExtend extends HUISlider 
	{
		public var changeHandler:Function;
		private var _defaultValue:Number;
		private var _useDoubleClickReset:Boolean;
		private var lastValue:Number;
		private var lastStage:Stage;
		
		public function HUISliderExtend(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null, changeHandler:Function = null)
		{
			_useDoubleClickReset = true;
			_defaultValue = 0;
			super(parent, xpos, ypos, label, defaultHandler);
			this.changeHandler = changeHandler;
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			var point:Sprite = this._slider.getChildAt(1) as Sprite;
			point.doubleClickEnabled = true;
			point.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
		}
		
		private function doubleClickHandler(e:MouseEvent):void 
		{
			if (!_useDoubleClickReset) return;
			value = _defaultValue || 0;
			notifyComplete();
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			notifyComplete();
			lastValue = value;
			lastStage = stage;
			lastStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			lastStage.addEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			//alphaSlider.stage.nativeWindow.addEventListener(Event.DEACTIVATE, slider_mouseUpHandler);
		}
		
		private function mouseUpHandler(e:Event):void 
		{
			lastStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			lastStage.removeEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			//alphaSlider.stage.nativeWindow.removeEventListener(Event.DEACTIVATE, slider_mouseUpHandler);
			notifyComplete();
		}
		
		private function notifyComplete():void 
		{
			if (lastValue == value) return;
			lastValue = value;
			var e:Event = new Event(Event.COMPLETE);
			dispatchEvent(e);
			if (changeHandler != null)
			{
				changeHandler(e);
			}
		}
		
		public function get defaultValue():Number 
		{
			return _defaultValue;
		}
		
		public function set defaultValue(value:Number):void 
		{
			_defaultValue = value;
		}
		
		public function get useDoubleClickReset():Boolean 
		{
			return _useDoubleClickReset;
		}
		
		public function set useDoubleClickReset(value:Boolean):void 
		{
			_useDoubleClickReset = value;
		}
		
	}

}