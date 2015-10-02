package net.morocoshi.common.ui.mouse
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.geom.Vector3DUtil;
	
	/**
	 * 球面ドラッグ
	 * 
	 * @author tencho
	 */
	public class MouseDrag3D extends EventDispatcher
	{
		/**カメラの距離*/
		public var distance:DragParam;
		/**横方向の回転*/
		public var rotation:DragParam;
		/**縦方向の回転*/
		public var angle:DragParam;
		/**ドラッグが可能か*/
		public var dragEnabled:Boolean;
		/**ホイールズームが可能か*/
		public var wheelEnabled:Boolean;
		
		private var _eventObject:InteractiveObject;
		private var _clickPoint:Point;
		private var _position:Vector3D = new Vector3D();
		private var _gazePosition:Vector3D = new Vector3D();
		
		private const toRAD:Number = Math.PI / 180;
		
		/**視点座標が動くと呼び出される(引数が1なら、視点座標のコピーがVector3Dで渡される)*/
		public var onMovePosition:Function;
		
		private var _isMouseDown:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function MouseDrag3D()
		{
			_isMouseDown = false;
			distance = new DragParam();
			rotation = new DragParam();
			angle = new DragParam();
			dragEnabled = true;
			wheelEnabled = true;
			_position = new Vector3D();
			_gazePosition = new Vector3D();
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**現在の球面座標*/
		public function get position():Vector3D { return _position; }
		public function set position(value:Vector3D):void { setPosition(value, true); }
		/**注視点座標*/
		public function get gazePosition():Vector3D { return _gazePosition; }
		public function set gazePosition(value:Vector3D):void { gazeAt(value, true); }
		/**マウスイベント登録オブジェクト*/
		public function get eventObject():InteractiveObject { return _eventObject; }
		
		/**
		 * マウスを押しているか
		 */
		public function get isMouseDown():Boolean 
		{
			return _isMouseDown;
		}
		
		public function set isMouseDown(value:Boolean):void 
		{
			_isMouseDown = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  初期化
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 初期化処理
		 * @param	obj	マウスイベントを登録する場所
		 * @param	rotation	初期の横方向角度
		 * @param	angle	初期の縦方向角度
		 * @param	distance	初期の中心点からの距離
		 */
		public function init(obj:InteractiveObject, rotation:Number = 0, angle:Number = 30, distance:Number = 1000):void
		{
			this.distance.setPosition(distance);
			this.distance.speed = 1.2;
			this.angle.position = angle;
			this.angle.min = -(this.angle.max = 89.5);
			this.rotation.position = rotation;
			_eventObject = obj;
			_eventObject.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_eventObject.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
			_eventObject.addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
			updatePosition();
		}
		
		//--------------------------------------------------------------------------
		//
		//  設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ドラッグモーションのイージング率（0に近いほどゆっくり近づく）
		 * @param	value
		 */
		public function setEasingSpeed(value:Number):void
		{
			angle.easing = rotation.easing = distance.easing = value;
		}
		
		/**
		 * ドラッグ回転速度を設定
		 * @param	rotationSpeed
		 * @param	angleSpeed
		 */
		public function setDragSpeed(rotationSpeed:Number, angleSpeed:Number):void 
		{
			rotation.speed = rotationSpeed;
			angle.speed = angleSpeed;
		}
		
		/**
		 * 視点位置設定
		 * @param	point
		 * @param	notify
		 */
		public function setPosition(point:Vector3D, lockGaze:Boolean, notify:Boolean = true):void
		{
			setPositionXYZ(point.x, point.y, point.z, lockGaze, notify);
		}
		
		/**
		 * 注視点位置設定
		 * @param	point
		 * @param	notify
		 */
		public function gazeAt(point:Vector3D, lockPosition:Boolean, notify:Boolean = true):void 
		{
			gazeAtXYZ(point.x, point.y, point.z, lockPosition, notify);
		}
		
		/**
		 * 注視点位置をXYZで設定
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	notify
		 */
		public function gazeAtXYZ(x:Number, y:Number, z:Number, lockPosition:Boolean, notify:Boolean = true):void
		{
			var moved:Boolean = (_gazePosition.x != x || _gazePosition.y != y || _gazePosition.z != z);
			
			_gazePosition.x = x;
			_gazePosition.y = y;
			_gazePosition.z = z;
			if (lockPosition)
			{
				updateParam();
			}
			else
			{
				updatePosition();
			}
			if (notify && moved) this.notify();
		}
		
		/**
		 * 視点位置をXYZで設定
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	notify
		 */
		public function setPositionXYZ(x:Number, y:Number, z:Number, lockGaze:Boolean, notify:Boolean = true):void
		{
			var moved:Boolean = (_position.x != x || _position.y != y || _position.z != z);
			
			_position.x = x;
			_position.y = y;
			_position.z = z;
			if (lockGaze)
			{
				updateParam();
			}
			else
			{
				updatePosition();
			}
			if (notify && moved) this.notify();
		}
		
		/**
		 * 距離を設定する
		 * @param	value
		 */
		public function setDistance(value:Number):void
		{
			var v:Vector3D = _position.subtract(_gazePosition);
			_position = _gazePosition.add(Vector3DUtil.getResized(v, value));
			updateParam();
		}
		
		//--------------------------------------------------------------------------
		//
		//  破棄
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 内部で生成したイベントを全て削除
		 */
		public function dispose():void
		{
			onMovePosition = null;
			_eventObject.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_eventObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
			_eventObject.removeEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
			if (_eventObject.stage)
			{
				_eventObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
				_eventObject.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
				_eventObject.stage.removeEventListener(Event.MOUSE_LEAVE, onMsUp);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  更新
		//
		//--------------------------------------------------------------------------
		
		/**
		 * angle、rotation、distanceの値から座標を計算して通知
		 */
		public function updatePosition():void
		{
			var per:Number = Math.cos(toRAD * angle.position);
			var px:Number = Math.cos(toRAD * rotation.position) * distance.position * per;
			var py:Number = Math.sin(toRAD * rotation.position) * distance.position * per;
			var pz:Number = Math.sin(toRAD * angle.position) * distance.position;
			_position.x = _gazePosition.x + px;
			_position.y = _gazePosition.y + py;
			_position.z = _gazePosition.z + pz;
			notify();
		}
		
		/**
		 * 座標が変化した事を通知させる
		 */
		public function notify():void
		{
			dispatchEvent(new Event(Event.CHANGE));
			if (onMovePosition != null)
			{
				if (onMovePosition.length == 0) onMovePosition();
				if (onMovePosition.length >= 1) onMovePosition(_position.clone());
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function updateParam():void 
		{
			var tx:Number = _position.x - _gazePosition.x;
			var ty:Number = _position.y - _gazePosition.y;
			var tz:Number = _position.z - _gazePosition.z;
			rotation.position = Math.atan2(ty, tx) / toRAD;
			angle.position = Math.atan2(tz, Math.sqrt(tx * tx + ty * ty)) / toRAD;
			distance.position = Vector3D.distance(_position, _gazePosition);
		}
		
		private function onEnterFrame(e:Event):void
		{
			angle.ease() * rotation.ease() * distance.ease() || updatePosition();
		}
		
		private function onMsWheel(e:MouseEvent):void
		{
			if (!wheelEnabled) return;
			
			distance.setTarget(distance._target * Math.pow(distance.speed, (e.delta < 0)? 1 : -1));
		}
		
		private function onMsDown(e:MouseEvent = null):void
		{
			if (!dragEnabled) return;
			
			_isMouseDown = true;
			_eventObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
			_eventObject.stage.addEventListener(Event.MOUSE_LEAVE, onMsUp);
			_eventObject.stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
			rotation.down = rotation.position;
			angle.down = angle.position;
			_clickPoint = new Point(_eventObject.mouseX, _eventObject.mouseY);
		}
		
		private function onMsMove(e:MouseEvent = null):void
		{
			if (!dragEnabled) return;
			
			var dragOffset:Point = new Point(_eventObject.mouseX, _eventObject.mouseY).subtract(_clickPoint);
			rotation.setTarget(rotation.down - dragOffset.x * rotation.speed);
			angle.setTarget(angle.down + dragOffset.y * angle.speed);
		}
		
		private function onMsUp(e:Event = null):void
		{
			if (!_eventObject.stage) return;
			
			_isMouseDown = false;
			_eventObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
			_eventObject.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
			_eventObject.stage.removeEventListener(Event.MOUSE_LEAVE, onMsUp);
			updatePosition();
		}
		
	}
	
}