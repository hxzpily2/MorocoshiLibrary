package net.morocoshi.components.minimal
{
	import com.bit101.components.Panel;
	import com.bit101.components.VScrollBar;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.components.tree.TreeLimb;
	import net.morocoshi.components.tree.TreeLimbEvent;
	
	/**
	 * 樹形図を表示するパネル。
	 * 初期状態でTreeLimbオブジェクトが1つ不可視モードで配置されています。
	 * この見えないルートフォルダにTreeLimbオブジェクトを追加してファイルやフォルダを表示します。
	 * 
	 * @author	tencho
	 */
	public class TreePanel extends Panel
	{
		private var _workSpace:Rectangle;
		private var _container:Sprite;
		private var _resizeCorner:Sprite;
		private var _resizeIcon:BitmapData;
		private var _bg:Sprite;
		private var _folder:TreeLimb;
		private var _vscroll:VScrollBar;
		private var _hscroll:VScrollBar;
		private var _padding:Number = 10;
		private var _bgcolor:uint = 0xF9F9F9;
		private var _isFirst:Boolean = true;
		private var _lastMousePos:Point = new Point();
		private var _lastWindowSize:Rectangle = new Rectangle();
		private var _contentsRect:Rectangle = new Rectangle();
		private var _resizable:Boolean = true;
		private var _resizeMinW:Number = 50;
		private var _resizeMinH:Number = 50;
		private var _resizeMaxW:Number = NaN;
		private var _resizeMaxH:Number = NaN;
		private var _isCTRL:Boolean = false;
		private var _isSHIFT:Boolean = false;
		private var _minSize:Rectangle = new Rectangle(0, 0, 30, 20);
		private var _maxLimit:Boolean = false;
		private var _maxSize:Rectangle = new Rectangle(0, 0, -1, -1);
		private var _scrollSpeed:Number = 30;
		private var fileSwitchState:Object = { };
		
		/**
		 * コンストラクタ
		 * @param	parent
		 * @param	xpos
		 * @param	ypos
		 */
		public function TreePanel(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
			_workSpace = new Rectangle();
			_bg = content.addChild(new Sprite()) as Sprite;
			var g:Graphics = _bg.graphics;
			g.clear();
			g.beginFill(_bgcolor);
			g.drawRect(0, 0, 100, 100);
			g.endFill();
			_bg.addEventListener(MouseEvent.MOUSE_DOWN, bg_mouseDownHander);
			_resizeCorner = content.addChild(new Sprite()) as Sprite;
			_resizeIcon = new BitmapData(10, 10, true, 0);
			
			for (var ih:int = 0; ih <= 6; ih += 2)
			for (var iw:int = 0; iw < ih; iw += 2)
			{
					_resizeIcon.setPixel32(_resizeIcon.width - iw - 2, ih + 2, 0xFF000000);
			}
			
			_resizeCorner.addChild(new Bitmap(_resizeIcon));
			_resizeCorner.buttonMode = true;
			_resizeCorner.addEventListener(MouseEvent.MOUSE_DOWN, corner_mouseDownHander);
			
			if (stage) panel_addedHandler(null);
			addEventListener(Event.ADDED_TO_STAGE, panel_addedHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, panel_removedHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, panel_mouseWheelHander);
			
			_container = content.addChild(new Sprite()) as Sprite;
			_folder = _container.addChild(new TreeLimb("")) as TreeLimb;
			_folder.hideRoot = true;
			_folder.addEventListener(TreeLimbEvent.RESIZE, tree_resizeHandler);
			_folder.addEventListener(TreeLimbEvent.SWITCH, tree_switchHandler);
			_vscroll = new VScrollBar(content, 0, 0, updateContentsPos);
			_hscroll = new VScrollBar(content, 0, 0, updateContentsPos);
			_hscroll.rotation = -90;
			_vscroll.lineSize = 16;
			_hscroll.lineSize = 16;
			setSize(width, height);
			
			var rect:Rectangle = _folder.getVisibleRect();
			rect.inflate(_padding, _padding);
			var px:int = int(rect.left), py:int = int(rect.top);
			_hscroll.setSliderParams(px, px + 100, px);
			_vscroll.setSliderParams(py, py + 100, py);
			bgcolor = _bgcolor;
			
			updateScrollStatus();
			_folder.updateAllStyle();
			_folder.setKeyEvent(this);
		}
		
		/**
		 * ファイルの開閉状態を保存するオブジェクトを指定する
		 * @param	state	開閉状態がこのオブジェクトに記録されるようになる
		 * @param	apply	オブジェクトの開閉状態をファイルに適用する
		 */
		public function linkFileSwitchState(state:Object, apply:Boolean):void
		{
			fileSwitchState = state;
			if (apply)
			{
				applyFileSwitchState();
			}
		}
		
		/**
		 * 
		 */
		public function applyFileSwitchState():void 
		{
			if (fileSwitchState == null) return;
			
			for (var key:String in fileSwitchState)
			{
				var limb:TreeLimb = _folder.getResolveLimb(key, "/");
				if (limb)
				{
					limb.setOpen(!fileSwitchState[key]);
				}
			}
		}
		
		private function tree_switchHandler(e:TreeLimbEvent):void 
		{
			if (fileSwitchState && e.targetLimb.isFolder)
			{
				fileSwitchState[e.targetLimb.getPath("/").substr(1)] = !e.targetLimb.isOpen;
			}
		}
		
		/**
		 * ウィンドウのリサイズの上限を設定
		 * @param	width
		 * @param	height
		 */
		public function setMaxSize(width:Number, height:Number):void
		{
			_maxLimit = true;
			_maxSize.width = Math.max(30, width);
			_maxSize.height = Math.max(20, height);
			setSize(width, height);
		}
		
		/**
		 * ウィンドウのリサイズの下限を設定
		 * @param	width
		 * @param	height
		 */
		public function setMinSize(width:Number, height:Number):void
		{
			_minSize.width = Math.max(30, width);
			_minSize.height = Math.max(20, height);
			setSize(width, height);
		}
		
		private function panel_removedHandler(e:Event):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		}
		
		private function panel_addedHandler(e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
		}
		
		private function stage_keyUpHandler(e:KeyboardEvent):void
		{
			_isSHIFT = e.shiftKey;
			_isCTRL = e.ctrlKey;
		}
		
		private function stage_keyDownHandler(e:KeyboardEvent):void
		{
			_isSHIFT = e.shiftKey;
			_isCTRL = e.ctrlKey;
		}
		
		private function corner_mouseDownHander(e:MouseEvent):void
		{
			_lastMousePos.x = stage.mouseX;
			_lastMousePos.y = stage.mouseY;
			_lastWindowSize.width = width;
			_lastWindowSize.height = height;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHander);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHander);
			stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHander);
		}
		
		private function stage_mouseMoveHander(e:Event = null):void
		{
			var w:Number = Math.max(0, _lastWindowSize.width + stage.mouseX - _lastMousePos.x);
			var h:Number = Math.max(50, _lastWindowSize.height + stage.mouseY - _lastMousePos.y);
			setSize(w, h);
		}
		
		private function stage_mouseUpHander(e:Event):void
		{
			stage_mouseMoveHander();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHander);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHander);
			stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHander);
		}
		
		private function panel_mouseWheelHander(e:MouseEvent):void
		{
			if (!_vscroll.enabled) return;
			var vec:int = e.delta / Math.abs(e.delta);
			_vscroll.value += vec * -1 * _scrollSpeed;
			updateContentsPos();
		}
		
		private function bg_mouseDownHander(e:MouseEvent):void
		{
			if(!_isSHIFT && !_isCTRL) _folder.deselectAll();
		}
		
		public function updateContentsPos(...rest):void
		{
			_folder.x = int(_workSpace.x - _hscroll.value);
			_folder.y = int(_workSpace.y - _vscroll.value);
			updateLimbsVisible();
		}
		
		private function tree_resizeHandler(e:TreeLimbEvent):void
		{
			_contentsRect = e.bounds;
			_contentsRect.inflate(_padding, _padding);
			_contentsRect.top = _contentsRect.top;
			_contentsRect.bottom = _contentsRect.bottom;
			_contentsRect.left = _contentsRect.left;
			_contentsRect.right = _contentsRect.right;
			addEventListener(Event.ENTER_FRAME, intervalResize);
		}
		
		private function intervalResize(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, intervalResize);
			updateScrollStatus();
			updateContentsPos();
			if (_contentsRect.width) _isFirst = false;
		}
		
		private function updateScrollStatus():void
		{
			var perV:Number = Math.min(2, _workSpace.height / _contentsRect.height);
			var perH:Number = Math.min(2, _workSpace.width / _contentsRect.width);
			_vscroll.enabled = (perV < 1);
			_hscroll.enabled = (perH < 1);
			if (perV < 0.1 || isNaN(perV)) perV = 0.1;
			if (perH < 0.1 || isNaN(perH)) perH = 0.1;
			_vscroll.setThumbPercent(perV);
			_hscroll.setThumbPercent(perH);
			if (!_vscroll.enabled || _isFirst) _vscroll.value = _contentsRect.top;
			if (!_hscroll.enabled || _isFirst) _hscroll.value = _contentsRect.left;
			_vscroll.setSliderParams(_contentsRect.top, _contentsRect.height - _workSpace.height - _padding, _vscroll.value);
			_hscroll.setSliderParams(_contentsRect.left, _contentsRect.width - _workSpace.width - _padding, _hscroll.value);
		}
		
		
		override public function set width(value:Number):void
		{
			updateSize(value, _height);
		}
		
		override public function set height(value:Number):void
		{
			updateSize(_width, value);
		}
		
		public function get scrollSpeed():Number 
		{
			return _scrollSpeed;
		}
		
		public function set scrollSpeed(value:Number):void 
		{
			_scrollSpeed = value;
		}
		
		public function get vscroll():VScrollBar 
		{
			return _vscroll;
		}
		
		public function get hscroll():VScrollBar 
		{
			return _hscroll;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			updateSize(w, h);
		}
		
		private function updateSize(w:Number, h:Number):void
		{
			if (w < _minSize.width) w = _minSize.width;
			if (h < _minSize.height) h = _minSize.height;
			if (_maxLimit && w > _maxSize.width) w = _maxSize.width;
			if (_maxLimit && h > _maxSize.height) h = _maxSize.height;
			super.setSize(w, h);
			
			if (!_vscroll) return;
			_workSpace = new Rectangle(0, 0, width - _vscroll.width, height - _hscroll.width);
			_hscroll.x = _workSpace.left;
			_hscroll.y = _workSpace.bottom + 10;
			_vscroll.x = _workSpace.right;
			_vscroll.y = _workSpace.top;
			_hscroll.height = _workSpace.width;
			_vscroll.height = _workSpace.height;
			_container.scrollRect = _workSpace;
			_bg.width = _workSpace.width;
			_bg.height = _workSpace.height;
			_resizeCorner.x = _workSpace.right;
			_resizeCorner.y = _workSpace.bottom;
			updateScrollStatus();
			updateContentsPos();
		}
		
		/**
		 * このウィンドウを破棄
		 */
		public function dispose():void
		{
			_folder.dispose();
			_resizeIcon.dispose();
			removeEventListener(MouseEvent.MOUSE_WHEEL, panel_mouseWheelHander);
			_bg.removeEventListener(MouseEvent.MOUSE_DOWN, bg_mouseDownHander);
			_folder.removeEventListener(TreeLimbEvent.RESIZE, tree_resizeHandler);
			_resizeCorner.removeEventListener(MouseEvent.MOUSE_DOWN, bg_mouseDownHander);
			removeEventListener(Event.REMOVED_FROM_STAGE, panel_removedHandler);
			removeEventListener(Event.ADDED_TO_STAGE, panel_addedHandler);
		}
		
		/**
		 * 選択アイテムが見える場所までスクロール
		 */
		public function scrollTo(target:*):void 
		{
			var limb:TreeLimb;
			
			if (target is TreeLimb) target = [target];
			
			//var selected:Vector.<TreeLimb> = _folder.getSelectedLimbs();
			for each(limb in target)
			{
				var current:TreeLimb = limb.parentLimb;
				while (current)
				{
					if (current.isOpen == false)
					{
						current.open();
					}
					current = current.parentLimb;
				}
			}
			
			FrameTimer.setTimer(3, function():void
			{
				var result:Rectangle;
				for each(limb in target)
				{
					var rect:Rectangle = limb.getBounds(_folder);
					if (result == null)
					{
						result = rect;
					}
					else
					{
						result.union(rect);
					}
				}
				
				if (result)
				{
					_vscroll.value = result.y - 10;
					updateContentsPos();
				}
			});
			
		}
		
		/**
		 * ウィンドウ内に収まっているファイルだけを表示して負荷を減らす
		 */
		private function updateLimbsVisible():void
		{
			var rect:Rectangle = new Rectangle(0, 0, _width, _height);
			var limbs:Vector.<TreeLimb> = Vector.<TreeLimb>([_folder]);
			var base:DisplayObject = _folder.parent;
			while (limbs.length > 0)
			{
				var limb:TreeLimb = limbs.pop();
				limb.checkRectVisible(base, rect);
				var n:int = limb.numChildLimb;
				for (var i:int = 0; i < n; i++) 
				{
					limbs.push(limb.getLimbAt(i));
				}
			}
		}
		
		/**ルートフォルダ*/
		public function get folder():TreeLimb
		{
			return _folder;
		}
		
		/**ウィンドウ背景色*/
		public function get bgcolor():uint
		{
			return _bgcolor;
		}
		public function set bgcolor(value:uint):void
		{
			_bgcolor = value;
			var ct:ColorTransform = new ColorTransform();
			ct.color = _bgcolor;
			_bg.transform.colorTransform = ct;
		}
		
		/**ウィンドウがリサイズできるか*/
		public function get resizable():Boolean
		{
			return _resizable;
		}
		public function set resizable(value:Boolean):void
		{
			_resizeCorner.mouseEnabled = value;
			_resizable = value;
		}
		
		/**リサイズ可能最小サイズ*/
		public function get minSize():Rectangle
		{
			return _minSize;
		}
		
		/**リサイズ可能最大サイズ*/
		public function get maxSize():Rectangle
		{
			return _maxSize;
		}
		
		/**リサイズの上限があるかどうか*/
		public function get maxLimit():Boolean
		{
			return _maxLimit;
		}
		public function set maxLimit(value:Boolean):void
		{
			_maxLimit = value;
			setSize(width, height);
		}
		
	}
	
}