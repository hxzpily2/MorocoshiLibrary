package net.morocoshi.components.minimal.input 
{
	import com.bit101.components.Component;
	import com.bit101.components.InputText;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	import net.morocoshi.components.events.ComponentEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class InputNumber extends Component 
	{
		public var input:InputText;
		public var minValue:Number = NaN;
		public var maxValue:Number = NaN;
		public var dragRange:Number = 2;
		public var intMode:Boolean = false;
		
		private var _value:Number = 0;
		private var _step:Number = 1;
		private var mouseDownPoint:Point;
		private var mouseDownValue:Number;
		
		private var updateHandler:Function;
		private var completeHandler:Function;
		private var dragged:Boolean = false;
		private var isRollOver:Boolean = false;
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function InputNumber(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, value:Number = 0, updateHandler:Function = null, completeHandler:Function = null) 
		{
			super(parent, xpos, ypos);
			this.updateHandler = updateHandler;
			this.completeHandler = completeHandler;
			mouseDownPoint = new Point();
			input = new InputText(null, 0, 0, String(value));
			input.textField.restrict = "0-9.\\-";
			input.textField.addEventListener(FocusEvent.FOCUS_OUT, input_focusOutHandler);
			input.textField.addEventListener(KeyboardEvent.KEY_DOWN, input_keyDownHandler);
			input.addEventListener(MouseEvent.ROLL_OVER, input_rollHandler);
			input.addEventListener(MouseEvent.ROLL_OUT, input_rollHandler);
			addChild(input);
			setSize(100, 20);
			
			setMouseClick(true);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function get value():Number 
		{
			return Number(input.text);
		}
		
		public function set value(value:Number):void 
		{
			setValue(value, true, true);
		}
		
		public function get step():Number 
		{
			return _step;
		}
		
		public function set step(value:Number):void 
		{
			_step = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function setValue(value:Number, notifyChangeEvent:Boolean, notifyCompleteEvent:Boolean):void 
		{
			_value = value;
			if (!isNaN(minValue) && _value < minValue) _value = minValue;
			if (!isNaN(maxValue) && _value > maxValue) _value = maxValue;
			input.text = String(_value);
			
			if (notifyChangeEvent) notifyChange();
			if (notifyCompleteEvent) notifyComplete();
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		private function input_keyDownHandler(e:KeyboardEvent):void 
		{
			if (e.keyCode != Keyboard.ENTER) return;
			
			stage.focus = null;
			completeInput();
		}
		
		private function completeInput():void 
		{
			if (intMode)
			{
				_value = Math.round(_value);
			}
			input.textField.text = String(value);
			setMouseClick(true);
			notifyChange();
			notifyComplete();
		}
		
		private function notifyComplete():void 
		{
			if (completeHandler != null)
			{
				completeHandler(new Event(Event.COMPLETE));
			}
		}
		
		private function notifyChange():void 
		{
			if (updateHandler != null)
			{
				updateHandler(new Event(ComponentEvent.UPDATE));
			}
		}
		
		private function setMouseClick(enabled:Boolean):void 
		{
			inputMode = !enabled;
			input.mouseChildren = !enabled;
			if (enabled)
			{
				input.mouseChildren = false;
				input.buttonMode = true;
				input.addEventListener(MouseEvent.MOUSE_DOWN, input_mouseDownHandler);
			}
			else
			{
				input.mouseChildren = true;
				input.buttonMode = false;
				input.removeEventListener(MouseEvent.MOUSE_DOWN, input_mouseDownHandler);
				input.removeEventListener(MouseEvent.MOUSE_UP, input_mouseUpHandler);
			}
			updateCursor();
		}
		
		static public var CURSOR_DRAG:String = "input_number_drag";
		static private var cursorID:String = MouseCursor.AUTO;
		
		static public function resetDragCursor():void
		{
			Mouse.unregisterCursor(CURSOR_DRAG);
			cursorID = MouseCursor.AUTO;
		}
		
		static public function setDragCursorID(id:String):void
		{
			cursorID = id;
		}
		
		static public function setDragCursorImage(image:BitmapData, x:Number, y:Number):void
		{
			var cursor:MouseCursorData = new MouseCursorData();
			cursor.data = new <BitmapData>[image];
			cursor.hotSpot = new Point(x, y);
			cursorID = CURSOR_DRAG;
			Mouse.registerCursor(CURSOR_DRAG, cursor);
		}
		
		private function updateCursor():void 
		{
			Mouse.cursor = ((isRollOver || dragged) && !inputMode)? cursorID : MouseCursor.AUTO;
		}
		
		private function input_rollHandler(e:MouseEvent):void 
		{
			isRollOver = (e.type == MouseEvent.ROLL_OVER);
			updateCursor();
		}
		
		private var dragEnabled:Boolean = false;
		private var inputMode:Boolean = false;
		private function input_mouseDownHandler(e:MouseEvent):void
		{
			dragged = false;
			dragEnabled = false;
			mouseDownValue = value;
			mouseDownPoint.x = input.stage.mouseX;
			mouseDownPoint.y = input.stage.mouseY;
			input.addEventListener(MouseEvent.MOUSE_UP, input_mouseUpHandler);
			input.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			input.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			input.stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
		}
		
		private function stage_mouseMoveHandler(e:MouseEvent):void 
		{
			if (!dragEnabled)
			{
				if (Math.abs(mouseDownPoint.x - input.stage.mouseX) > dragRange || Math.abs(mouseDownPoint.y - input.stage.mouseY) > dragRange)
				{
					dragEnabled = true;
					mouseDownPoint.x = input.stage.mouseX;
					mouseDownPoint.y = input.stage.mouseY;
				}
				return;
			}
			
			var dx:Number = +(input.stage.mouseX - mouseDownPoint.x);
			var dy:Number = -(input.stage.mouseY - mouseDownPoint.y);
			var delta:Number = (Math.abs(dx) > Math.abs(dy))? dx : dy;
			var offset:Number = Math.round(delta / 2) * _step;
			
			if (!offset) return;
			
			var num:Number = mouseDownValue + offset;
			num = Math.round(num * 10000) / 10000;
			mouseDownPoint.x = input.stage.mouseX;
			mouseDownPoint.y = input.stage.mouseY;
			mouseDownValue = num;
			
			if (!isNaN(minValue) && num < minValue) num = minValue;
			if (!isNaN(maxValue) && num > maxValue) num = maxValue;
			
			if (intMode)
			{
				num = Math.round(num);
			}
			
			if (_value != num)
			{
				dragged = true;
				setValue(num, true, false);
			}
		}
		
		private function stage_mouseUpHandler(e:Event):void
		{
			dragEnabled = false;
			input.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			input.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			input.stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
			
			if (dragged)
			{
				notifyComplete();
			}
			dragged = false;
			updateCursor();
		}
		
		private function input_mouseUpHandler(e:MouseEvent):void 
		{
			if (dragged) return;
			
			setMouseClick(false);
			stage.focus = input.textField;
			input.textField.setSelection(0, input.text.length);
		}
		
		private function input_focusOutHandler(e:FocusEvent):void 
		{
			completeInput();
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		override public function draw():void 
		{
			super.draw();
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			input.setSize(w, h);
		}
		
	}

}