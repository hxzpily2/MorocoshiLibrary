package net.morocoshi.moja3d.overlay.mouse 
{
	import flash.events.EventDispatcher;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import net.morocoshi.common.data.Temp;
	import net.morocoshi.moja3d.overlay.objects.Object2D;
	import net.morocoshi.moja3d.utils.TransformUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MultiTouchFinger extends EventDispatcher 
	{
		private var touch:TouchEvent;
		private var movementList:Vector.<Point>;
		private var _mouseDownPoint:Point;
		private var _currentPoint:Point;
		private var prevPoint:Point;
		private var _movementLocal:Point;
		private var targetObject:Object2D;
		//private var lastKey:String;
		
		public function MultiTouchFinger(touch:TouchEvent) 
		{
			super();
			
			this.touch = touch;
			targetObject = touch.currentTarget as Object2D;
			movementList = new Vector.<Point>;
			_currentPoint = new Point();
			prevPoint = new Point();
			_movementLocal = new Point();
			_mouseDownPoint = new Point(touch.localX, touch.localY);
			_currentPoint.copyFrom(_mouseDownPoint);
			prevPoint.copyFrom(_mouseDownPoint);
		}
		
		/**
		 * 初回タッチ後のイベントを設定する。タッチが終了した場合はtrueを返す
		 * @param	touch
		 * @return
		 */
		public function addTouchEvent(touch:TouchEvent):Boolean 
		{
			if (touch.type == TouchEvent.TOUCH_END)
			{
				dispatchEvent(TouchEventUtil.cloneEvent(touch));
				return true;
			}
			
			Temp.matrix3D.copyFrom(targetObject.worldMatrix);
			Temp.matrix3D.invert();
			Temp.position.setTo(touch.localX, touch.localY, 0);
			TransformUtil.transformVector(Temp.position, Temp.matrix3D);
			
			_currentPoint.setTo(Temp.position.x, Temp.position.y);
			var movement:Point = new Point(_currentPoint.x- prevPoint.x, _currentPoint.y - prevPoint.y);
			if (touch.type == TouchEvent.TOUCH_MOVE)
			{
				if (movement.x == 0 && movement.y == 0)
				{
					return false;
				}
				
				movementList.push(movement);
				if (movementList.length > 20)
				{
					movementList.shift();
				}
				
				//diff
				_movementLocal.x = _currentPoint.x - _mouseDownPoint.x;
				_movementLocal.y = _currentPoint.y - _mouseDownPoint.y;
				
				dispatchEvent(TouchEventUtil.cloneEvent(touch));
				prevPoint.copyFrom(_currentPoint);
			}
			
			return false;
		}
		
		public function localToTarget(point:Point, target:Object2D):Point
		{
			Temp.position.setTo(point.x, point.y, 0);
			TransformUtil.transformVector(Temp.position, targetObject.worldMatrix);
			
			Temp.matrix3D.copyFrom(target.worldMatrix);
			Temp.matrix3D.invert();
			TransformUtil.transformVector(Temp.position, Temp.matrix3D);
			return new Point(Temp.position.x, Temp.position.y);
		}
		
		public function getFlickSpeed(frame:int = 5, target:Object2D = null):Point 
		{
			var speed:Point = new Point();
			var n:int = Math.min(frame, movementList.length);
			for (var i:int = 0; i < n; i++) 
			{
				var m:Point = movementList[movementList.length - 1 - i];
				speed.x += m.x;
				speed.y += m.y;
			}
			if (n > 0)
			{
				speed.x /= n;
				speed.y /= n;
			}
			
			if (target == null || target == targetObject) return speed;
			
			return localToTarget(speed, target);
		}
		
		/**
		 * タッチした座標
		 * @param	target
		 * @return
		 */
		public function mouseDownPoint(target:Object2D = null):Point 
		{
			if (target == null || target == targetObject) return _mouseDownPoint;
			
			return localToTarget(_mouseDownPoint, target);
		}
		
		/**
		 * 現在の座標
		 * @param	target
		 * @return
		 */
		public function currentPoint(target:Object2D = null):Point 
		{
			if (target == null || target == targetObject) return _currentPoint;
			
			return localToTarget(_currentPoint, target);
		}
		
		/**
		 * タッチ座標からの現在の座標までのオフセット
		 * @param	target
		 * @return
		 */
		public function movementLocal(target:Object2D = null):Point 
		{
			if (target == null || target == targetObject) return _movementLocal;
			
			return localToTarget(_movementLocal, target);
		}
		
	}

}