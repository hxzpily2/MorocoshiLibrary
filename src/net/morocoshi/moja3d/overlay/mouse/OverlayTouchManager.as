package net.morocoshi.moja3d.overlay.mouse 
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.overlay.objects.Object2D;
	import net.morocoshi.moja3d.overlay.objects.Screen2D;
	
	use namespace moja3d;
	
	/**
	 * Moja3D内での2Dレイヤーにおけるタッチイベントを実現する
	 * 
	 * @author tencho
	 */
	public class OverlayTouchManager 
	{
		public var screen:Screen2D;
		public var background:Screen2D;
		private var stage:Stage;
		private var root:Object2D;
		private var mouseTouchID:int;
		public var touchPoint:Point;
		public var touchEvent:TouchEvent;
		
		public function OverlayTouchManager(stage:Stage, root:Object2D) 
		{
			this.stage = stage;
			this.root = root;
			mouseTouchID = int.MAX_VALUE / 2;
			
			screen = new Screen2D();
			screen._screen = screen;
			background = new Screen2D();
			background._screen = screen;
			root._screen = screen;
			
			touchPoint = new Point();
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchHandler);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, touchHandler);
			stage.addEventListener(TouchEvent.TOUCH_END, touchHandler);
			if (Multitouch.inputMode == MultitouchInputMode.NONE)
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			mouseTouchID++;
			touchHandler(createTouchEvent(TouchEvent.TOUCH_BEGIN, mouseTouchID));
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseUpHandler(e:MouseEvent):void 
		{
			touchHandler(createTouchEvent(TouchEvent.TOUCH_END, mouseTouchID));
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			touchHandler(createTouchEvent(TouchEvent.TOUCH_MOVE, mouseTouchID));
		}
		
		private function createTouchEvent(type:String, id:int):TouchEvent 
		{
			var event:TouchEvent = new TouchEvent(type);
			event.localX = stage.mouseX;
			event.localY = stage.mouseY;
			event.touchPointID = id;
			return event;
		}
		
		private function touchHandler(e:TouchEvent):void 
		{
			touchEvent = e;
			touchPoint.setTo(e.localX, e.localY);
			
			if (root.hitTestTouchEvent(this, false) == false)
			{
				background.dispatchEvent(TouchEventUtil.cloneEvent(e));
			}
			
			screen.dispatchEvent(TouchEventUtil.cloneEvent(e));
		}
		
		public function dispatchTouchEvent(current:Object2D, baseEvent:TouchEvent, px:Number, py:Number):void 
		{
			if (baseEvent.type == TouchEvent.TOUCH_BEGIN)
			{
				current.touchID = baseEvent.touchPointID;
			}
			
			current.dispatchEvent(TouchEventUtil.cloneEvent(baseEvent, baseEvent.type, px, py));
			
			if (baseEvent.type == TouchEvent.TOUCH_END && current.touchID == baseEvent.touchPointID)
			{
				current.dispatchEvent(TouchEventUtil.cloneEvent(baseEvent, TouchEvent.TOUCH_TAP, px, py));
			}
		}
		
	}

}