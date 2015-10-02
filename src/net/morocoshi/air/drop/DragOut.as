package net.morocoshi.air.drop 
{
	import flash.desktop.Clipboard;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragOptions;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.geom.Point;
	
	/**
	 * ドラッグアウト管理
	 * 
	 * @author tencho
	 */
	public class DragOut 
	{
		
		private var _enabled:Boolean = true;
		private var _eventObj:Sprite = new Sprite();
		private var _clickObj:InteractiveObject;
		private var _overObj:InteractiveObject;
		private var _clipboard:Clipboard;
		private var _stage:Stage;
		private var _dragImage:BitmapData = null;
		private var _dragOffset:Point = new Point();
		/**ドラッグ開始時に呼ばれるので、引数のDragOutオブジェクトのsetClipboard()を呼び出す*/
		public var onDragStart:Function = null;
		public var onDragComplete:Function = null;
		
		public function DragOut() 
		{
		}
		
		public function get enabled():Boolean {	return _enabled; }
		public function set enabled(value:Boolean):void { _enabled = value; }		
		
		public function init(click:InteractiveObject, over:InteractiveObject = null):void
		{
			_clickObj = click;
			_overObj = over;
			if (!_overObj) _overObj = _clickObj;
			_clickObj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_eventObj.addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE, onComplete);
		}
		
		public function setDragImage(image:BitmapData = null, center:Boolean = true, offsetX:Number = 0, offsetY:Number = 0):void
		{
			_dragImage = image;
			_dragOffset.x = (center)? (image)? -image.width / 2 : 0 : offsetX;
			_dragOffset.y = (center)? (image)? -image.height / 2 : 0 : offsetY;
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			_stage = _clickObj.stage;
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if (_overObj is Stage)
			{
				_overObj.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				return;
			}
			_overObj.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			removeEvent();
		}
		
		public function setClipboard(clip:Clipboard):void
		{
			_clipboard = clip;
		}
		
		private function onMouseOut(e:Event):void 
		{
			var s:Stage = _overObj as Stage;
			if (s && s.mouseX > 0 && s.mouseY > 0 && s.mouseX < s.stageWidth && s.mouseY < s.stageHeight) return;
			
			removeEvent();
			
			if (onDragStart != null) onDragStart(this);
			if (!_clipboard || !_enabled) return;
			
			var opt:NativeDragOptions = new NativeDragOptions();
			opt.allowCopy = true;
			opt.allowLink = true;
			opt.allowMove = true;
			NativeDragManager.doDrag(_eventObj, _clipboard, _dragImage, _dragOffset, opt);

		}
		
		private function removeEvent():void 
		{
			if(_stage) _stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_overObj.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut)
			_overObj.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		private function onComplete(e:NativeDragEvent):void 
		{
			_clipboard = null;
			if (onDragComplete != null) onDragComplete();
		}
		
	}

}