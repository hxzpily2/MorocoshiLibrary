package net.morocoshi.components.minimal 
{
	import com.bit101.components.Component;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import net.morocoshi.common.graphics.Create;
	import net.morocoshi.common.math.geom.RectUtil;
	
	/**
	 * 画像表示コンポーネント
	 * 
	 * @author tencho
	 */
	public class BitmapClip extends Component 
	{
		private var _bitmap:Bitmap;
		private var _image:BitmapData;
		private var _scaleMode:String;
		private var _smoothing:Boolean;
		private var _mask:Sprite;
		private var _useMask:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	parent
		 * @param	xpos
		 * @param	ypos
		 * @param	bmd
		 * @param	smoothing
		 * @param	scaleMode	[ScaleMode:auto]
		 */
		public function BitmapClip(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, bmd:BitmapData = null, smoothing:Boolean = true, scaleMode:String = "auto", useMask:Boolean = false) 
		{
			super(parent, xpos, ypos);
			_smoothing = smoothing;
			_scaleMode = scaleMode;
			_mask = Create.box(0, 0, 10, 10);
			_mask.visible = false;
			_bitmap = new Bitmap(bmd, "auto", smoothing);
			addChild(_bitmap);
			addChild(_mask);
			if (useMask)
			{
				_bitmap.mask = _mask;
			}
			_useMask = useMask;
			resetSize();
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function get scaleMode():String { return _scaleMode; }
		public function set scaleMode(value:String):void { _scaleMode = value; }
		
		public function set bitmapData(value:BitmapData):void
		{
			_bitmap.bitmapData = value;
			_bitmap.smoothing = _smoothing;
			updateSize();
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmap.bitmapData;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function resetSize():void
		{
			if (!_bitmap.bitmapData) return;
			setSize(_bitmap.bitmapData.width, _bitmap.bitmapData.height);
		}
		
		private function updateSize():void 
		{
			if (!_bitmap.bitmapData) return;
			var size:Rectangle = RectUtil.adjust(_bitmap.bitmapData.rect, new Rectangle(0, 0, _width, _height), _scaleMode);
			_bitmap.x = size.x;
			_bitmap.y = size.y;
			_bitmap.width = size.width;
			_bitmap.height = size.height;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			_mask.width = value;
			updateSize();
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			_mask.height = value;
			updateSize();
		}
		
		public function get bitmap():Bitmap 
		{
			return _bitmap;
		}
		
		public function get useMask():Boolean 
		{
			return _useMask;
		}
		
		public function set useMask(value:Boolean):void 
		{
			_useMask = value;
			_bitmap.mask = _useMask? _mask : null;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			_mask.width = w;
			_mask.height = h;
			updateSize();
		}
		
	}

}