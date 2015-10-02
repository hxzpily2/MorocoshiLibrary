package net.morocoshi.common.ui.mouse
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 2Dマウスドラッグ管理
	 * 
	 * @author tencho
	 */
	public class MouseDrag2D extends EventDispatcher
	{
		/**現在位置*/
		public var position:Point = new Point();
		/**ドラッグ速度*/
		public var dragSpeed:Point = new Point(1, 1);
		/**ホイールによるスケール変化率*/
		public var scaleSpeed:Number = 1.2;
		/**現在のスケール*/
		public var scale:Number = 1;
		/**クリック判定になるマウスのぶれ範囲*/
		public var clickRange:Number = 2;
		/**ホイールズームが有効か*/
		public var wheelEnabled:Boolean = false;
		/**マウスドラッグ可能か*/
		public var dragEnabled:Boolean = true;
		/**flaseでドラッグ処理、ホイールズーム処理を一切行わない*/
		public var enabled:Boolean = true;
		/**ホイールズームの方向を逆転させる*/
		public var reverseWheel:Boolean = false;
		/**ドラッグの方向を逆転させる*/
		public var reverseDragScale:Boolean = false;
		/**ドラッグ開始後に毎回指定の座標から始めたい場合は設定する*/
		public var autoResetPoint:Point;
		
		private var _stage:Stage;
		private var _isDragged:Boolean = false;
		private var _isMouseDown:Boolean = false;
		private var _savePosition:Point = new Point();
		private var _saveMousePos:Point;
		private var _scaleMin:Number = -Number.MAX_VALUE;
		private var _scaleMax:Number = Number.MAX_VALUE;
		private var _dragTop:Number = -Number.MAX_VALUE;
		private var _dragBottom:Number = Number.MAX_VALUE;
		private var _dragLeft:Number = -Number.MAX_VALUE;
		private var _dragRight:Number = Number.MAX_VALUE;
		private var _useDragScale:Boolean = true;
		private var eventTarget:InteractiveObject;
		private var positionTarget:InteractiveObject;
		
		/**
		 * コンストラクタ
		 */
		public function MouseDrag2D()
		{
		}
		
		/**
		 * 初期化処理
		 * @param	eventTarget	マウスイベント登録オブジェクト
		 * @param	positionTarget	マウス座標判定用オブジェクト
		 * @param	x	初期X座標
		 * @param	y	初期Y座標
		 * @param	scale	初期スケール
		 */
		public function init(eventTarget:InteractiveObject, positionTarget:InteractiveObject, x:Number = 0, y:Number = 0, scale:Number = 1):void
		{
			this.scale = scale;
			position.x = x;
			position.y = y;
			this.positionTarget = positionTarget || eventTarget;
			this.eventTarget = eventTarget;
			eventTarget.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
			eventTarget.addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
		}
		
		/**
		 * ドラッグ可能な範囲を設定する（※調整中？）
		 * @param	rect
		 * @param	reverse
		 */
		public function setDragArea(rect:Rectangle, reverse:Boolean = false):void
		{
			var t:Number = rect.top;
			var l:Number = rect.left;
			var b:Number = rect.bottom;
			var r:Number = rect.right;
			_dragTop = t;
			_dragLeft = l;
			_dragBottom = b;
			_dragRight = r;
		}
		
		/**
		 * スケールの範囲を設定する
		 * @param	min
		 * @param	max
		 */
		public function setScaleRange(min:Number, max:Number):void 
		{
			_scaleMin = min;
			_scaleMax = max;
		}
		
		// マウスホイール時
		private function onMsWheel(e:MouseEvent):void 
		{
			if (!enabled || !wheelEnabled) return;
			var d:int = e.delta < 0? -1 : 1;
			if (reverseWheel) d *= -1;
			scale *= Math.pow(scaleSpeed, d);
			if (scale < _scaleMin) scale = _scaleMin;
			if (scale > _scaleMax) scale = _scaleMax;
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL));
		}
		
		// マウスダウン時
		private function onMsDown(e:Event = null):void
		{
			_isMouseDown = true;
			_isDragged = false;
			_stage = eventTarget.stage;
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
			_stage.addEventListener(Event.MOUSE_LEAVE, onMsUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
			if (enabled)
			{
				if (autoResetPoint)
				{
					position = autoResetPoint.clone();
				}
				if (dragEnabled)
				{
					_savePosition = position.clone();
					_saveMousePos = new Point(positionTarget.mouseX, positionTarget.mouseY);
				}
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			}
		}
		
		// マウスアップ時
		private function onMsUp(e:Event = null):void
		{
			_isMouseDown = false;
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
			_stage.removeEventListener(Event.MOUSE_LEAVE, onMsUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
			checkDrag();
			if (enabled)
			{
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				if (!_isDragged) dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
		
		// マウス移動時
		private function onMsMove(e:Event = null):void
		{
			checkDrag();
		}
		
		/**
		 * ドラッグ処理
		 */
		private function checkDrag():void
		{
			if (!enabled || !dragEnabled) return;
			var drag:Point = new Point(positionTarget.mouseX, positionTarget.mouseY).subtract(_saveMousePos);
			if (!_isDragged && drag.length > clickRange) _isDragged = true;
			if (_isDragged)
			{
				var s:Number = _useDragScale? reverseDragScale? 1 / scale : scale : 1;
				position.x = _savePosition.x + drag.x * dragSpeed.x / s;
				position.y = _savePosition.y + drag.y * dragSpeed.y / s;
				if (position.x < _dragLeft) position.x = _dragLeft; 
				if (position.x > _dragRight) position.x = _dragRight; 
				if (position.y < _dragTop) position.y = _dragTop; 
				if (position.y > _dragBottom) position.y = _dragBottom; 
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
			}
		}
		
		/**
		 * 座標を指定する
		 * @param	x
		 * @param	y
		 */
		public function setPoint(x:Number, y:Number):void
		{
			_savePosition.x = position.x = x;
			_savePosition.y = position.y = y;
		}
		
		public function get isMouseDown():Boolean { return _isMouseDown; }
		public function get isDragged():Boolean { return _isDragged; }
		public function get dragTop():Number { return _dragTop; }
		public function set dragTop(value:Number):void { _dragTop = value; }
		public function get dragBottom():Number { return _dragBottom; }
		public function set dragBottom(value:Number):void {	_dragBottom = value; }
		public function get dragLeft():Number { return _dragLeft; }
		public function set dragLeft(value:Number):void { _dragLeft = value; }
		public function get dragRight():Number { return _dragRight; }
		public function set dragRight(value:Number):void { _dragRight = value; }
		public function get useDragScale():Boolean { return _useDragScale; }
		public function set useDragScale(value:Boolean):void { _useDragScale = value; }
		
	}

}