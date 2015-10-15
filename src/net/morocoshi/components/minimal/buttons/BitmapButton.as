package net.morocoshi.components.minimal.buttons 
{
	import com.bit101.components.Component;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.components.minimal.BitmapClip;
	
	/**
	 * 画像ボタン
	 * 
	 * @author tencho
	 */
	public class BitmapButton extends Component
	{
		private var _imageClip:BitmapClip;
		private var _overClip:BitmapClip;
		private var _downClip:BitmapClip;
		private var _rollOver:Boolean = false;
		private var _mouseDown:Boolean = false;
		private var _bitmapAlpha:Number = 1;
		public var onClick:Function;
		public var downColor:ColorTransform;
		public var overColor:ColorTransform;
		public var normalColor:ColorTransform;
		
		/**
		 * 
		 * @param	parent
		 * @param	xpos
		 * @param	ypos
		 * @param	image
		 * @param	over
		 * @param	down
		 * @param	click
		 * @param	smoothing
		 * @param	scaleMode	[ScaleMode:fit]
		 */
		public function BitmapButton(parent:DisplayObjectContainer, xpos:Number, ypos:Number, image:*, over:* = null, down:* = null, clickHandler:Function = null, smoothing:Boolean = true, scaleMode:String = "fit")
		{
			super(parent, xpos, ypos);
			
			if (image is Bitmap) image = Bitmap(image).bitmapData;
			if (over is Bitmap) over = Bitmap(over).bitmapData;
			if (down is Bitmap) down = Bitmap(down).bitmapData;
			
			buttonMode = true;
			mouseChildren = false;
			_imageClip = new BitmapClip(this, 0, 0, image, smoothing, scaleMode);
			_overClip = new BitmapClip(this, 0, 0, over, smoothing, scaleMode);
			_downClip = new BitmapClip(this, 0, 0, down, smoothing, scaleMode);
			setDefaultButton();
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			setSize(image.width, image.height);
			this.onClick = clickHandler;
			addEventListener(MouseEvent.CLICK, button_clickHandler);
			updateColorTransform();
		}
		
		override public function set enabled(value:Boolean):void 
		{
			super.enabled = value;
			updateColorTransform();
		}
		
		/**
		 * 指定のDisplayObjectContainer内に存在する全てのBitmapButtonをリストアップする
		 * @param	target
		 * @return
		 */
		static public function getAllBitmapButton(target:DisplayObjectContainer):Vector.<BitmapButton>
		{
			var list:Vector.<BitmapButton> = new Vector.<BitmapButton>;
			
			if (target is BitmapButton)
			{
				list.push(target);
				target = null;
			}
			
			var containerList:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>;
			while (target)
			{
				for (var i:int = 0; i < target.numChildren; i++)
				{
					var obj:DisplayObjectContainer = target.getChildAt(i) as DisplayObjectContainer;
					if (!obj) continue;
					if (obj is BitmapButton)
					{
						list.push(obj);
						continue;
					}
					containerList.push(obj);
				}
				if (!containerList.length) break;
				target = containerList.pop();
			}
			
			return list;
		}
		
		private function button_clickHandler(e:Event):void 
		{
			if (onClick != null) onClick(e);
		}
		
		public function setDownOffsetColor(r:int, g:int, b:int):void 
		{
			downColor = Palette.getOffsetColor(r, g, b, alpha);
		}
		
		public function setDownFillColor(color:uint, density:Number, alpha:Number = 1):void
		{
			downColor = Palette.getFillColor(color, density, alpha);
		}
		
		public function setOverOffsetColor(r:int, g:int, b:int, alpha:Number = 1):void
		{
			overColor = Palette.getOffsetColor(r, g, b, alpha);
		}
		
		public function setOverFillColor(color:uint, density:Number, alpha:Number = 1):void
		{
			overColor = Palette.getFillColor(color, density, alpha);
		}
		
		private function mouseDownHandler(e:Event):void 
		{
			_mouseDown = true;
			updateColorTransform();
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			updateStatus();
		}
		
		private function mouseUpHandler(e:Event):void 
		{
			_mouseDown = false;
			updateColorTransform();
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			updateStatus();
		}
		
		private function rollOutHandler(e:Event):void 
		{
			_rollOver = false;
			updateColorTransform();
			updateStatus();
		}
		
		private function rollOverHandler(e:Event):void 
		{
			_rollOver = true;
			updateColorTransform();
			updateStatus();
		}
		
		public function updateColorTransform():void
		{
			if(_mouseDown)
			{
				if(downColor) transform.colorTransform = downColor;
			}
			else if (_rollOver)
			{
				if(overColor) transform.colorTransform = overColor;
			}
			else
			{
				if(normalColor) transform.colorTransform = normalColor;
			}
			alpha = (_enabled? 1 : 0.3) * _bitmapAlpha;
		}
		
		private function updateStatus():void 
		{
			if (_mouseDown)
			{
				setDownButton();
			}
			else
			{
				if (_rollOver && _overClip.bitmapData)
				{
					setOverButton();
				}
				else
				{
					setDefaultButton();
				}
			}
		}
		
		private function setDefaultButton():void 
		{
			_imageClip.visible = true;
			_overClip.visible = false;
			_downClip.visible = false;
		}
		
		private function setDownButton():void 
		{
			if (!_downClip.bitmapData) return;
			_imageClip.visible = false;
			_overClip.visible = false;
			_downClip.visible = true;
		}
		
		private function setOverButton():void 
		{
			if (!_overClip.bitmapData) return;
			_imageClip.visible = false;
			_overClip.visible = true;
			_downClip.visible = false;
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			updateSize();
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			updateSize();
		}
		
		public function get imageClip():BitmapClip 
		{
			return _imageClip;
		}
		
		public function get overClip():BitmapClip 
		{
			return _overClip;
		}
		
		public function get downClip():BitmapClip 
		{
			return _downClip;
		}
		
		public function get bitmapAlpha():Number 
		{
			return _bitmapAlpha;
		}
		
		public function set bitmapAlpha(value:Number):void 
		{
			_bitmapAlpha = value;
			updateColorTransform();
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			updateSize();
		}
		
		private function updateSize():void 
		{
			_imageClip.setSize(_width, _height);
			_overClip.setSize(_width, _height);
			_downClip.setSize(_width, _height);
		}
		
	}

}