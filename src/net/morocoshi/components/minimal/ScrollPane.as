package net.morocoshi.components.minimal 
{
	import com.bit101.components.Component;
	import com.bit101.components.HScrollBar;
	import com.bit101.components.VScrollBar;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ScrollPane extends Component 
	{
		public var content:Sprite;
		public var padding:Number;
		public var wheelStep:Number;
		public var updateInterval:int;
		private var contentContainer:Sprite;
		private var _scrollHEnabled:Boolean;
		private var scrollV:VScrollBar;
		private var scrollH:HScrollBar;
		private var scrollVContainer:Sprite;
		private var scrollHContainer:Sprite;
		private var isReady:Boolean = false;
		private var _scrollSize:Rectangle;
		private var lastSize:Rectangle;
		private var _watchContentResize:Boolean;
		private var wheelArea:InteractiveObject;
		private var count:int;
		private var contentSize:Rectangle;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function ScrollPane(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
			
			padding = 10;
			wheelStep = 30;
			updateInterval = 7;
			_watchContentResize = false;
			lastSize = new Rectangle();
			contentSize = new Rectangle();
			contentContainer = new Sprite();
			content = new Sprite();
			addChild(contentContainer);
			contentContainer.addChild(content);
			scrollVContainer = new Sprite();
			scrollHContainer = new Sprite();
			addChild(scrollHContainer);
			addChild(scrollVContainer);
			scrollV = new VScrollBar(scrollVContainer, 0, 0, scroll_scrollHandler);
			scrollH = new HScrollBar(scrollHContainer, 0, 0, scroll_scrollHandler);
			scrollV.setSliderParams(0, 1, 0);
			scrollH.setSliderParams(0, 1, 0);
			_scrollSize = new Rectangle(0, 0, 1, 1);
			_scrollHEnabled = true;
			watchContentResize = true;
			isReady = true;
			updateScroll();
		}
		
		public function setWheelArea(target:InteractiveObject):void
		{
			wheelArea = target;
			if (wheelArea.stage)
			{
				setWheelEvent(wheelArea.stage);
			}
			else
			{
				target.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		
		private function addedToStageHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			setWheelEvent(wheelArea.stage);
		}
		
		private function setWheelEvent(stage:Stage):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_wheelHandler);
		}
		
		private function stage_wheelHandler(e:MouseEvent):void 
		{
			var stage:Stage = e.currentTarget as Stage;
			if (!wheelArea.getRect(stage).contains(stage.mouseX, stage.mouseY)) return;
			var d:int = e.delta > 0 ? 1 : -1;
			moveScrollValueV(d * wheelStep);
		}
		
		public function moveScrollValueV(value:Number):void
		{
			moveScrollRateV(value / (_scrollSize.height - contentSize.bottom));
		}
		
		public function moveScrollRateV(rate:Number):void
		{
			scrollV.value += rate;
			scrollV.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function setScrollValueV(value:Number):void
		{
			setScrollRateV(value / (_scrollSize.height - contentSize.bottom));
		}
		
		public function setScrollRateV(rate:Number):void
		{
			scrollV.value = rate;
			scrollV.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function updateScroll():void 
		{
			lastSize.width = contentSize.right;
			lastSize.height = contentSize.bottom;
			var pw:Number = _scrollSize.width / Math.max(1, contentSize.right);
			var ph:Number = _scrollSize.height / Math.max(1, contentSize.bottom);
			scrollV.setThumbPercent(Math.max(0.1, ph));
			scrollH.setThumbPercent(Math.max(0.1, pw));
			scrollV.enabled = (_scrollSize.height < contentSize.bottom);
			scrollH.enabled = (_scrollSize.width < contentSize.right);
		}
		
		public function get watchContentResize():Boolean
		{
			return _watchContentResize;
		}
		
		public function set watchContentResize(value:Boolean):void 
		{
			_watchContentResize = value;
			if (value)
			{
				content.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
			else
			{
				content.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		public function get scrollSize():Rectangle 
		{
			return _scrollSize;
		}
		
		public function get scrollHEnabled():Boolean 
		{
			return _scrollHEnabled;
		}
		
		public function set scrollHEnabled(value:Boolean):void 
		{
			_scrollHEnabled = value;
			scrollHContainer.visible = _scrollHEnabled;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			if (!isReady) return;
			
			super.setSize(w, h);
			scrollV.y = 0;
			scrollV.x = w - scrollV.width;
			scrollH.x = 0;
			scrollH.y = h - scrollH.height;
			scrollV.height = h - scrollV.width * int(_scrollHEnabled);
			scrollH.width = w - scrollH.height;
			
			_scrollSize.width = w - scrollV.width - padding * 2;
			_scrollSize.height = h - scrollH.height - padding * 2;
			contentContainer.scrollRect = _scrollSize;
			contentContainer.x = padding;
			contentContainer.y = padding;
			
			updateScroll();
			scroll_scrollHandler(null);
		}
		
		private function scroll_scrollHandler(e:Event):void 
		{
			content.x = (_scrollSize.width >= contentSize.right)? 0 : (_scrollSize.width - contentSize.right) * scrollH.value;
			content.y = (_scrollSize.height >= contentSize.bottom)? 0 : (_scrollSize.height - contentSize.bottom) * scrollV.value;
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			if (count++ % updateInterval != 0) return;
			var img:BitmapData = new BitmapData(content.width, content.height, true, 0x00000000);
			img.draw(content);
			contentSize = img.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (contentSize.right != lastSize.width || contentSize.bottom != lastSize.height)
			{
				updateScroll();
			}
		}
		
	}

}