package net.morocoshi.starling.mouse 
{
	import flash.geom.Point;
	import net.morocoshi.common.data.Temp;
	import net.morocoshi.starling.events.MouseTouchEvent;
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchPhase;
	/**
	 * ...
	 * @author tencho
	 */
	public class MultiTouchFinger extends EventDispatcher
	{
		private var movements:Vector.<Point>;
		private var lastKey:String;
		private var target:DisplayObject;
		public var touch:Touch;
		public var mouseDownPoint:Point;
		public var movementLocal:Point;
		public var currentPoint:Point;
		
		public function MultiTouchFinger(touch:Touch, target:DisplayObject) 
		{
			super();
			this.touch = touch;
			this.target = target;
			movements = new Vector.<Point>;
			currentPoint = new Point();
			movementLocal = new Point();
			mouseDownPoint = touch.getLocation(target);
			currentPoint.copyFrom(mouseDownPoint);
		}
		
		/**
		 * 初回タッチ後のイベントを設定する。タッチが終了した場合はtrueを返す
		 * @param	touch
		 * @return
		 */
		public function setTouch(touch:Touch):Boolean 
		{
			var key:String = touch.phase + "," + touch.timestamp;
			if (lastKey == key) return false;
			
			lastKey = key;
			
			if (touch.phase == TouchPhase.ENDED)
			{
				dispatchEvent(new MouseTouchEvent(MouseTouchEvent.MOUSE_UP));
				return true;
			}
			
			if (touch.phase == TouchPhase.MOVED)
			{
				var move:Point = touch.getMovement(target);
				if (move.x == 0 && move.y == 0)
				{
					return false;
				}
				
				movements.push(move);
				if (movements.length > 20)
				{
					movements.shift();
				}
				
				//diff
				touch.getLocation(target, currentPoint);
				movementLocal.x = currentPoint.x - mouseDownPoint.x;
				movementLocal.y = currentPoint.y - mouseDownPoint.y;
				
				dispatchEvent(new MouseTouchEvent(MouseTouchEvent.DRAGGING));
			}
			
			return false;
		}
		
		public function getFlickSpeed(frame:int = 5):Point 
		{
			var speed:Point = new Point();
			var n:int = Math.min(frame, movements.length);
			for (var i:int = 0; i < n; i++) 
			{
				var m:Point = movements[movements.length - 1 - i];
				speed.x += m.x;
				speed.y += m.y;
			}
			return speed;
		}
		
	}

}