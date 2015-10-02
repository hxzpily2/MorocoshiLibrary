package net.morocoshi.common.ui.mouse 
{
	import flash.display.InteractiveObject;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author tencho
	 */
	public class DragParam 
	{
		/**最小値*/
		public var min:Number = NaN;
		/**最大値*/
		public var max:Number = NaN;
		/**速度*/
		public var speed:Number = 1;
		/**イージング速度*/
		public var easing:Number = 0.25;
		/**現在値*/
		internal var _position:Number = 0;
		/***/
		private var _velocity:Number = 0;
		
		private var upKey:int;
		private var downKey:int;
		private var keyBindObject:InteractiveObject;
		
		internal var _target:Number = 0;
		internal var down:Number = NaN;
		
		public function DragParam() 
		{
		}
		
		/**
		 * 現在値
		 */
		public function get position():Number
		{
			return _position;
		}
		
		public function set position(value:Number):void
		{
			setPosition(value);
		}
		
		public function get velocity():Number
		{
			return _velocity;
		}
		
		/**
		 * 目的値
		 */
		public function get target():Number 
		{
			return _target;
		}
		
		public function set target(value:Number):void 
		{
			setTarget(value);
		}
		
		/**
		 * 最小値と最大値を設定（NaNで無制限）
		 * @param	min
		 * @param	max
		 */
		public function setLimit(min:Number = NaN, max:Number = NaN):void
		{
			this.min = min;
			this.max = max;
		}
		
		public function bindKey(object:InteractiveObject, up:uint, down:uint):void 
		{
			upKey = up;
			downKey = down;
			keyBindObject = object;
			object.addEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
			object.addEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
		}
		
		private function keyUpDownHandler(e:KeyboardEvent):void 
		{
			var keyDown:Boolean = e.type == KeyboardEvent.KEY_DOWN;
			if (!keyDown) return;
			if (keyBindObject.stage && keyBindObject.stage.focus is TextField) return;
			
			if (e.keyCode == upKey)
			{
				setTarget(_target * speed);
			}
			if (e.keyCode == downKey)
			{
				setTarget(_target / speed);
			}
		}
		
		/**
		 * 移動先の値を設定
		 * @param	value
		 */
		internal function setTarget(value:Number):void
		{
			_target = value;
			if (!isNaN(min) && _target < min) _target = min;
			else if (!isNaN(max) && _target > max) _target = max;
		}
		
		/**
		 * 現在の値を設定
		 * @param	value
		 */
		internal function setPosition(value:Number):void
		{
			_position = _target = value;
		}
		
		internal function ease():int
		{
			if (_position == _target) return 1;
			_velocity = (_target - _position) * easing;
			_position += _velocity;
			if (Math.abs(_position - _target) < 0.01) _position = _target;
			return 0;
		}
		
	}

}