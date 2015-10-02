package net.morocoshi.starling.mouse
{
	import flash.geom.Point;
	import net.morocoshi.common.data.Temp;
	
	import net.morocoshi.starling.events.MouseTouchEvent;
	
	import starling.display.DisplayObject;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class MouseTouch extends EventDispatcher
	{
		private var _sprite:DisplayObject;
		private var _isMouseDown:Boolean;
		private var _isRollOver:Boolean;
		private var _isDragging:Boolean;
		private var _dragEnabled:Boolean;
		
		public function MouseTouch(sprite:DisplayObject)
		{
			super();
			_isMouseDown = false;
			_isRollOver = false;
			_isDragging = false;
			_dragEnabled = false;
			_sprite = sprite;
			_sprite.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		public function get dragEnabled():Boolean
		{
			return _dragEnabled;
		}

		public function set dragEnabled(value:Boolean):void
		{
			_dragEnabled = value;
		}

		public function get isDragging():Boolean
		{
			return _isDragging;
		}

		public function get isRollOver():Boolean
		{
			return _isRollOver;
		}

		public function get isMouseDown():Boolean
		{
			return _isMouseDown;
		}
		
		public function get sprite():DisplayObject 
		{
			return _sprite;
		}

		private function touchHandler(e:TouchEvent):void 
		{
			var t:Touch = e.getTouch(_sprite);
			if (t == null)
			{
				_isMouseDown = false;
				_isRollOver = false;
				_isDragging = false;
			}
			else
			{
				switch(t.phase)
				{
					case TouchPhase.BEGAN:
						_isMouseDown = true;
						dispatchEvent(new MouseTouchEvent(MouseTouchEvent.MOUSE_DOWN));
						break;
					case TouchPhase.MOVED:
						if (_dragEnabled == false) break;
						t.getMovement(_sprite.parent, Temp.point);
						if (Temp.point.x == 0 && Temp.point.y == 0) break;
						
						_sprite.x += Temp.point.x;
						_sprite.y += Temp.point.y;
						_isDragging = true;
						break;
					case TouchPhase.ENDED:
						_isMouseDown = false;
						_isDragging = false;
						var p:Point = t.getLocation(_sprite);
						if (p.x < 0 || p.y < 0 || p.x > _sprite.width || p.y > _sprite.height)
						{
							_isRollOver = false;
						}
						else
						{
							dispatchEvent(new MouseTouchEvent(MouseTouchEvent.CLICK));
						}
						dispatchEvent(new MouseTouchEvent(MouseTouchEvent.ROLL_OUT));
						dispatchEvent(new MouseTouchEvent(MouseTouchEvent.MOUSE_UP));
						break;
					case TouchPhase.HOVER:
						_isRollOver = true;
						dispatchEvent(new MouseTouchEvent(MouseTouchEvent.ROLL_OVER));
						break;
				}
				dispatchEvent(new MouseTouchEvent(MouseTouchEvent.CHANGE));
			}
			//alpha = isRollOver? 1 : 0.2;
			//scale = isMouseDown? 0.8 : 1;
		}
	}
}