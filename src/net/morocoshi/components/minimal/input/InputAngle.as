package net.morocoshi.components.minimal.input 
{
	import com.bit101.components.Component;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import net.morocoshi.components.events.ComponentEvent;
	import net.morocoshi.geom.AngleUtil;
	import net.morocoshi.graphics.Draw;
	
	/**
	 * 角度入力
	 * 
	 * @author tencho
	 */
	public class InputAngle extends Component 
	{
		private var _minValue:Number = NaN;
		private var _maxValue:Number = NaN;
		private var _wrapMode:Boolean = true;
		private var mouseMove:Boolean = false;
		private var _defaultValue:Number;
		
		private var _wheelEnabled:Boolean;
		private var radius:Number;
		private var _knob:Sprite;
		private var _value:Number;
		private var _input:InputNumber;
		private var _spacing:Number;
		private var startMouseAngle:Number;
		private var startKnobRotation:Number;
		private var _knobPoint:Sprite;
		private var stageLocal:Stage;
		private var shiftKey:Boolean;
		
		private var updateHandler:Function;
		private var completeHandler:Function;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function InputAngle(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, value:Number = 0, updateHandler:Function = null, completeHandler:Function = null)
		{
			super(parent, xpos, ypos);
			this.completeHandler = completeHandler;
			this.updateHandler = updateHandler;
			
			shiftKey = false;
			_wheelEnabled = false;
			mouseMove = false;
			_defaultValue = _value = value;
			_spacing = 5;
			_input = new InputNumber(this, 0, 0, _value, input_updateHandler, input_completeHandler);
			_knob = new Sprite();
			_knobPoint = new Sprite();
			_knobPoint.mouseEnabled = _knobPoint.mouseChildren = false;
			_knob.doubleClickEnabled = true;
			_knob.addEventListener(MouseEvent.MOUSE_DOWN, knob_mouseDownHandler);
			_knob.addEventListener(MouseEvent.DOUBLE_CLICK, knob_wclickHandler);
			_knob.buttonMode = true;
			setSize(100, 30);
			addChild(_knob);
			addChild(_knobPoint);
			setValue(_value, false, false);
			
			if (stage) addedToStageHandler(null);
			else addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function knob_wclickHandler(e:MouseEvent):void 
		{
			if (mouseMove) return;
			
			value = _defaultValue;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		public function get defaultValue():Number 
		{
			return _defaultValue;
		}
		
		public function set defaultValue(value:Number):void 
		{
			_defaultValue = value;
		}
		
		public function get value():Number 
		{
			return _value;
		}
		
		public function set value(degree:Number):void 
		{
			setValue(degree, true, true);
		}
		
		public function get maxValue():Number 
		{
			return _maxValue;
		}
		
		public function set maxValue(value:Number):void 
		{
			_maxValue = _input.maxValue = value;
		}
		
		public function get minValue():Number 
		{
			return _minValue;
		}
		
		public function set minValue(value:Number):void 
		{
			_minValue = _input.minValue = value;
		}
		
		public function get wheelEnabled():Boolean 
		{
			return _wheelEnabled;
		}
		
		public function set wheelEnabled(value:Boolean):void 
		{
			_wheelEnabled = value;
		}
		
		public function get wrapMode():Boolean 
		{
			return _wrapMode;
		}
		
		public function set wrapMode(value:Boolean):void 
		{
			_wrapMode = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	value
		 * @param	boolean
		 */
		public function setValue(degree:Number, notifyUpdateEvent:Boolean, notifyCompleteEvent:Boolean):void 
		{
			_value = degree;
			_knobPoint.rotation = _value;
			var fixValue:Number = Number(degree.toFixed(2)) || 0;
			_input.setValue(fixValue, false, false);
			draw();
			
			if (notifyUpdateEvent) notifyUpdate();
			if (notifyCompleteEvent) notifyComplete();
		}
		
		//--------------------------------------------------------------------------
		//
		//  通知
		//
		//--------------------------------------------------------------------------
		
		public function notifyComplete():void
		{
			var e:Event = new Event(Event.COMPLETE);
			if (completeHandler != null)
			{
				completeHandler(e);
			}
			dispatchEvent(e);
		}
		
		public function notifyUpdate():void
		{
			var e:Event = new Event(ComponentEvent.UPDATE);
			if (updateHandler != null)
			{
				updateHandler(e);
			}
			dispatchEvent(e);
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function addedToStageHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			stageLocal = stage;
			stageLocal.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyHandler);
			stageLocal.addEventListener(KeyboardEvent.KEY_UP, stage_keyHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
		}
		
		private function removeHandler(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
			
			stageLocal.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyHandler);
			stageLocal.removeEventListener(KeyboardEvent.KEY_UP, stage_keyHandler);
		}
		
		private function stage_keyHandler(e:KeyboardEvent):void 
		{
			shiftKey = e.shiftKey;
		}
		
		private function input_completeHandler(e:Event):void 
		{
			setValue(_input.value, false, true);
		}
		
		private function input_updateHandler(e:Event):void 
		{
			setValue(_input.value, true, false);
		}
		
		private function knob_mouseDownHandler(e:MouseEvent):void 
		{
			mouseMove = false;
			startKnobRotation = _value;
			startMouseAngle = Math.atan2(_knob.mouseY, _knob.mouseX) / Math.PI * 180;
			_knob.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			_knob.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
			_knob.stage.addEventListener(MouseEvent.MOUSE_MOVE, knob_mouseMoveHandler);
		}
		
		private function stage_mouseUpHandler(e:Event):void 
		{
			_knob.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
			_knob.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			_knob.stage.removeEventListener(MouseEvent.MOUSE_MOVE, knob_mouseMoveHandler);
			
			notifyComplete();
		}
		
		private function knob_mouseMoveHandler(e:MouseEvent):void 
		{
			mouseMove = true;
			var degree:Number = Math.atan2(_knob.mouseY, _knob.mouseX) / Math.PI * 180;
			degree = AngleUtil.toNearDegree(degree, startMouseAngle);
			var diff:Number = degree - startMouseAngle;
			
			var angle:Number = startKnobRotation + diff;
			if (shiftKey)
			{
				angle = Math.round(angle / 15) * 15 | 0;
			}
			
			var useMin:Boolean = !isNaN(_minValue);
			var useMax:Boolean = !isNaN(_maxValue);
			var fixValue:Boolean = true;
			var wrapValue:Number;
			if (useMin && angle < _minValue)
			{
				var enabled:Boolean = false;
				if (_wrapMode && useMax)
				{
					wrapValue = toNearDegree(angle);
					if (_minValue <= wrapValue && wrapValue <= _maxValue)
					{
						angle = wrapValue;
						fixValue = false;
					}
				}
				if (fixValue) angle = _minValue;
			}
			if (useMax && angle > _maxValue)
			{
				if (_wrapMode && useMin)
				{
					wrapValue = toNearDegree(angle);
					if (_minValue <= wrapValue && wrapValue <= _maxValue)
					{
						angle = wrapValue;
						fixValue = false;
					}
				}
				if (fixValue) angle = _maxValue;
			}
			setValue(angle, true, false);
			
			startKnobRotation = startKnobRotation + diff;
			startMouseAngle = degree;
		}
		
		private function toNearDegree(degree:Number):Number 
		{
			var min:Number = AngleUtil.toNearDegree(degree, _minValue);
			var max:Number = AngleUtil.toNearDegree(degree, _maxValue);
			if (_minValue <= min && min <= _maxValue) return min;
			return max;
		}
		
		//--------------------------------------------------------------------------
		//
		//  描画
		//
		//--------------------------------------------------------------------------
		
		override public function draw():void 
		{
			super.draw();
			
			var g:Graphics = _knob.graphics;
			g.clear();
			Draw.gradientCircle(g, 0, 0, radius, radius, true, 90, [0x888888, 0x595959], [1, 1]);
			g.drawCircle(0, 0, radius);
			Draw.gradientCircle(g, 0, 0, radius - 2, radius - 2, true, 90, [0xF1F1F1, 0xe0e0e0], [1, 1]);
			g.drawCircle(0, 0, radius - 1);
			
			g = _knobPoint.graphics;
			g.clear();
			g.beginFill(0x666666);
			g.drawCircle(0, -radius + 6, 2);
			
			_knob.x = _knobPoint.x = radius;
			_knob.y = _knobPoint.y = radius;
			_input.x = radius * 2 + _spacing;
			_input.y = int((_height - _input.height) / 2);
		}
		
		override public function get height():Number 
		{
			return super.height;
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			radius = _height / 2;
			_input.setSize(getInputWidth(), getInputHeight());
		}
		
		override public function get width():Number 
		{
			return super.width;
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			_input.width = getInputWidth();
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			radius = _height / 2;
			_input.setSize(getInputWidth(), getInputHeight());
		}
		
		private function getInputWidth():Number
		{
			return Math.max(1, _width - radius * 2 - _spacing);
		}
		
		private function getInputHeight():Number 
		{
			return Math.min(20, _height);
		}
		
	}

}