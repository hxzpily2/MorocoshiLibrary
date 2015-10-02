package net.morocoshi.common.ui.mouse 
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MouseDragRect 
	{
		private var stage:Stage;
		private var clickPoint:Point;
		private var target:InteractiveObject;
		
		public var onMouseDown:Function;
		public var onMouseDrag:Function;
		public var onComplete:Function;
		private var _rect:Rectangle;
		private var _isMouseDown:Boolean;
		private var base:InteractiveObject;
		
		public function MouseDragRect() 
		{
			_isMouseDown = false;
		}
		
		public function init(target:InteractiveObject, base:InteractiveObject = null):void
		{
			this.target = target;
			this.base = base? base : target;
			target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
		}
		
		private function target_mouseDownHandler(e:MouseEvent):void 
		{
			stage = target.stage;
			_isMouseDown = true;
			clickPoint = new Point(base.mouseX, base.mouseY);
			_rect = getRect();
			notifyMouseDown();
			notifyMouseDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
		}
		
		public function notifyEvent(func:Function):void
		{
			if (func == null) return;
			if (func.length == 0)
			{
				func();
			}
			else
			{
				func(_rect);
			}
		}
		public function notifyComplete():void
		{
			notifyEvent(onComplete);
		}
		
		public function notifyMouseDown():void 
		{
			notifyEvent(onMouseDown);
		}
		
		public function notifyMouseDrag():void 
		{
			notifyEvent(onMouseDrag);
		}
		
		private function stage_mouseMoveHandler(e:MouseEvent):void 
		{
			_rect = getRect();
			notifyMouseDrag();
		}
		
		private function getRect():Rectangle 
		{
			var tx:Number = base.mouseX;
			var ty:Number = base.mouseY;
			var rect:Rectangle = new Rectangle();
			rect.x = tx < clickPoint.x ? tx : clickPoint.x;
			rect.y = ty < clickPoint.y ? ty : clickPoint.y;
			var w:Number = tx - clickPoint.x;
			var h:Number = ty - clickPoint.y;
			if (w < 0) w *= -1;
			if (h < 0) h *= -1;
			rect.width = w;
			rect.height = h;
			return rect;
		}
		
		private function stage_mouseUpHandler(e:Event):void 
		{
			_isMouseDown = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
			_rect = getRect();
			notifyComplete();
		}
		
		public function get isMouseDown():Boolean 
		{
			return _isMouseDown;
		}
		
		public function get rect():Rectangle 
		{
			return _rect;
		}
		
	}

}