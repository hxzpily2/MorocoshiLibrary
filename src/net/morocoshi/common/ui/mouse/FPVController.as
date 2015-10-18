package net.morocoshi.common.ui.mouse 
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	/**
	 * FPV視点でのカメラ操作＆移動を管理する
	 * 
	 * @author tencho
	 */
	public class FPVController extends EventDispatcher
	{
		private var _key:uint = 0x0000;
		private var _angleKey:uint = 0x0000;
		private var _dragger:MouseDrag3D = new MouseDrag3D();
		private var _velocity:Vector3D = new Vector3D();
		private var _tvelocity:Vector3D = new Vector3D();
		private var _front:Vector3D = new Vector3D();
		private var _forward:Vector3D = new Vector3D();
		private var _right:Vector3D = new Vector3D();
		private var _position:Vector3D = new Vector3D();
		private var _keyEventObject:InteractiveObject;
		private var _sprite:Sprite = new Sprite();
		private var _dragged:Boolean = false;
		private var _moveSpeed:Number = 5;
		private var _rotateSpeed:Number = 3;
		private var _enabled:Boolean = true;
		private var _horizontal:Boolean = false;
		private var _moveEasing:Number = 0.25;
		
		/**座標が変わると呼ばれる関数*/
		public var onMove:Function;
		public var speedUpRate:Number = 5;
		private var _upAxis:Vector3D = new Vector3D(0, 0, 1);
		private var _top:Vector3D = new Vector3D();
		private var roll:Number = 0;
		private var rollMatrix:Matrix3D = new Matrix3D();
		private var _rollLimit:Number = 15;
		private var _rollEnabled:Boolean = false;
		private var speedUp:Boolean = false;
		private var speedDown:Boolean = false;
		
		/**
		 * コンストラクタ
		 */
		public function FPVController() 
		{
		}
		
		/**正面ベクトル*/
		public function get front():Vector3D { return _front; }
		
		/**水平面での前方ベクトル*/
		public function get forward():Vector3D { return _forward; }
		
		/**移動速度*/
		public function get moveSpeed():Number { return _moveSpeed; }
		public function set moveSpeed(value:Number):void { _moveSpeed = value; }
		
		/**右手ベクトル*/
		public function get right():Vector3D { return _right; }
		
		/**現在の位置*/
		public function get position():Vector3D { return _position; }
		public function set position(value:Vector3D):void { _position = value; }
		
		/**現在の速度ベクトル*/
		public function get velocity():Vector3D { return _velocity; }
		
		/***/
		public function get tvelocity():Vector3D { return _tvelocity; }
		
		/**球面ドラッグ管理*/
		public function get dragger():MouseDrag3D { return _dragger; }
		
		/**水平移動モード*/
		public function get horizontal():Boolean { return _horizontal; }
		public function set horizontal(value:Boolean):void { _horizontal = value; }
		
		/**FPV操作が有効か*/
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			_dragger.dragEnabled = _enabled;
		}
		
		/***/
		public function get moveEasing():Number { return _moveEasing; }
		public function set moveEasing(value:Number):void { _moveEasing = value; }
		
		public function get upAxis():Vector3D { return _upAxis; }
		
		/***/
		public function get rollLimit():Number { return _rollLimit; }
		public function set rollLimit(value:Number):void { _rollLimit = value; }
		
		public function get rollEnabled():Boolean { return _rollEnabled; }
		public function set rollEnabled(value:Boolean):void
		{
			_rollEnabled = value;
			if (!_rollEnabled)
			{
				roll = 0;
			}
		}
		
		/**
		 * マウス、キー入力イベントを登録するオブジェクトを指定して初期化
		 * @param	obj
		 */
		public function init(obj:InteractiveObject):void
		{
			_dragger.init(obj, -90, 0, 1000);
			_dragger.addEventListener(Event.CHANGE, dragger_moveHandler);
			_dragger.wheelEnabled = false;
			_dragger.setDragSpeed(0.8, -0.8);
			_dragger.setEasingSpeed(0.25);
			_dragger.notify();
			
			if (!obj.stage) obj.addEventListener(Event.ADDED_TO_STAGE, object_addedHandler);
			else addKeyEvent(obj.stage);
			
			_sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * 指定XYZ座標を向く
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		public function lookAtXYZ(x:Number, y:Number, z:Number):void
		{
			_dragger.setPositionXYZ(x - _position.x, y - _position.y, z - _position.z, true);
		}
		
		/**
		 * 指定座標を向く
		 * @param	v
		 */
		public function lookAt3D(v:Vector3D):void 
		{
			_dragger.setPositionXYZ(v.x - _position.x, v.y - _position.y, v.z - _position.z, true);
		}
		
		/**
		 * Ecent.CHANGEをdispatchしてonMoveを呼び出す
		 */
		public function notifyMove():void 
		{
			if (!_enabled) return;
			dispatchEvent(new Event(Event.CHANGE));
			if (onMove != null)
			{
				if (onMove.length == 1) onMove(_position);
				if (onMove.length == 0) onMove();
			}
		}
		
		public function dispose():void 
		{
			onMove = null;
			_dragger.dispose();
			removeKeyEvent();
			removeEventListener(Event.ADDED_TO_STAGE, object_addedHandler);
		}
		
		public function setCameraMatrix(matrix:Matrix3D):void 
		{
			position = matrix.position;
			var data:Vector.<Number> = matrix.rawData;
			lookAt3D(position.add(new Vector3D(data[8], data[9], data[10])));
		}
		
		private function object_addedHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, object_addedHandler);
			addKeyEvent(InteractiveObject(e.currentTarget).stage);
		}
		
		private function removeKeyEvent():void
		{
			if (!_keyEventObject) return;
			//_keyEventObject.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			_keyEventObject.removeEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
			_keyEventObject.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
		}
		
		private function addKeyEvent(obj:InteractiveObject):void
		{
			_keyEventObject = obj;
			//_keyEventObject.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			_keyEventObject.addEventListener(KeyboardEvent.KEY_UP, keyUpDownHandler);
			_keyEventObject.addEventListener(KeyboardEvent.KEY_DOWN, keyUpDownHandler);
		}
		
		private function mouseLeaveHandler(e:Event):void 
		{
			_key = 0x0000;
			_angleKey = 0x0000;
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			if (!_enabled)
			{
				return;
			}
			
			var speedRate:Number = (speedUp? speedUpRate : 1) * (speedDown? 1 / speedUpRate : 1);
			
			var av:Number = ((_angleKey & 0xF000)? 1 : 0) - ((_angleKey & 0x0F00)? 1 : 0);
			var ah:Number = ((_angleKey & 0x000F)? 1 : 0) - ((_angleKey & 0x00F0)? 1 : 0);
			av *= _rotateSpeed * speedRate;
			ah *= _rotateSpeed * speedRate;
			
			_dragger.angle.setTarget(_dragger.angle.target + av);
			_dragger.rotation.setTarget(_dragger.rotation.target + ah);
			
			var v:Number = ((_key & 0xF000)? 1 : 0) - ((_key & 0x0F00)? 1 : 0);
			var h:Number = ((_key & 0x00F0)? 1 : 0) - ((_key & 0x000F)? 1 : 0);
			/*
			if (!v && !h && !_dragged)
			{
				clearVelocity();
				return;
			}
			*/
			v *= _moveSpeed * speedRate;
			h *= _moveSpeed * speedRate;
			
			if (_horizontal)
			{
				//水平移動モード
				_tvelocity.x = _forward.x * v + _right.x * h;
				_tvelocity.y = _forward.y * v + _right.y * h;
				_tvelocity.z = _forward.z * v + _right.z * h;
			}
			else
			{
				//通常移動モード
				_tvelocity.x = _front.x * v + _right.x * h;
				_tvelocity.y = _front.y * v + _right.y * h;
				_tvelocity.z = _front.z * v + _right.z * h;
			}
			
			if (!_tvelocity.equals(_velocity, false))
			{
				_velocity.x += (_tvelocity.x - _velocity.x) * _moveEasing;
				_velocity.y += (_tvelocity.y - _velocity.y) * _moveEasing;
				_velocity.z += (_tvelocity.z - _velocity.z) * _moveEasing;
				
				_position.x += _velocity.x;
				_position.y += _velocity.y;
				_position.z += _velocity.z;
			}
			
			if (rollEnabled)
			{
				var moveRate:Number = _velocity.length / _moveSpeed;
				if (moveRate > 1) moveRate = 1;
				var velocityNormal:Vector3D = _velocity.clone();
				velocityNormal.normalize();
				moveRate *= velocityNormal.dotProduct(_front);
				var rotateRate:Number = _dragger.rotation.velocity / 3;
				if (rotateRate > 1) rotateRate = 1;
				if (rotateRate < -1) rotateRate = -1;
				var hPer:Number = _front.dotProduct(Vector3D.Z_AXIS);
				if (hPer < 0) hPer *= -1;
				
				var troll:Number = _rollLimit * (1 - hPer) * rotateRate * moveRate * -1;
				roll += (troll - roll) * 0.15;
				
				rollMatrix.identity();
				rollMatrix.appendRotation(roll, _front);
				_upAxis = rollMatrix.deltaTransformVector(_top);
			}
			else
			{
				_upAxis.setTo(0, 0, 1);
			}
			
			_dragged = false;
			notifyMove();
		}
		
		public function clearVelocity():void
		{
			_velocity.setTo(0, 0, 0);
			_tvelocity.setTo(0, 0, 0);
		}
		
		private function keyUpDownHandler(e:KeyboardEvent):void 
		{
			speedUp = e.shiftKey;
			speedDown = e.ctrlKey;
			var isDown:Boolean = e.type == KeyboardEvent.KEY_DOWN;
			switch(e.keyCode)
			{
				case Keyboard.UP	: isDown? _angleKey |= 0xF000 : _angleKey &= 0x0FFF; break;
				case Keyboard.DOWN	: isDown? _angleKey |= 0x0F00 : _angleKey &= 0xF0FF; break;
				case Keyboard.RIGHT	: isDown? _angleKey |= 0x00F0 : _angleKey &= 0xFF0F; break;
				case Keyboard.LEFT	: isDown? _angleKey |= 0x000F : _angleKey &= 0xFFF0; break;
				case Keyboard.W: case Keyboard.UP	: isDown? _key |= 0xF000 : _key &= 0x0FFF; break;
				case Keyboard.S: case Keyboard.DOWN	: isDown? _key |= 0x0F00 : _key &= 0xF0FF; break;
				case Keyboard.D: case Keyboard.RIGHT: isDown? _key |= 0x00F0 : _key &= 0xFF0F; break;
				case Keyboard.A: case Keyboard.LEFT	: isDown? _key |= 0x000F : _key &= 0xFFF0; break;
			}
		}
		
		private function dragger_moveHandler(e:Event):void 
		{
			_front = _dragger.position.clone();
			_front.normalize();
			_right = _front.crossProduct(Vector3D.Z_AXIS);
			_right.normalize();
			_top = _right.crossProduct(_front);
			_top.normalize();
			_forward = Vector3D.Z_AXIS.crossProduct(_right);
			_forward.normalize();
			_dragged = true;
		}
		
	}

}