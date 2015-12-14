package net.morocoshi.moja3d.view 
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import net.morocoshi.moja3d.moja3d;
	
	/**
	 * シーンを描画するビューポート
	 * 
	 * @author tencho
	 */
	public class Viewport 
	{
		private var _stage:Stage;
		private var _stage3D:Stage3D;
		
		private var _backgroundColor:uint;
		private var _backgroundAlpha:Number;
		private var _backgroundData:Vector.<Number>;
		
		private var _visible:Boolean;
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var _antiAlias:int;
		
		private var _updateBackBuffer:Boolean;
		
		/**レンダリング範囲をビューポート左上からのクリッピング矩形で指定する*/
		public var clipping:Rectangle;
		
		/**
		 * コンストラクタ
		 */
		public function Viewport() 
		{
			super();
			
			_x = 0;
			_y = 0;
			_width = 640;
			_height = 480;
			_visible = true;
			
			_updateBackBuffer = true;
			_backgroundData = new Vector.<Number>;
			_backgroundAlpha = 1;
			_antiAlias = 2;
			backgroundColor = 0x000000;
		}
		
		/**
		 * stageがリサイズされた時にビューポートのサイズをstageに合わせるようにします。
		 * @param	stage
		 */
		public function startAutoResize(stage:Stage):void 
		{
			stopAutoResize();
			_stage = stage;
			_stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler(null);
		}
		
		/**
		 * ビューポートの自動リサイズを停止します。
		 */
		public function stopAutoResize():void
		{
			if (_stage)
			{
				_stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			}
		}
		
		/**
		 * ビューポートのサイズを設定します
		 * @param	w
		 * @param	h
		 */
		public function setSize(w:int, h:int):void 
		{
			width = w;
			height = h;
		}
		
		private function stage_resizeHandler(e:Event):void 
		{
			setSize(_stage.stageWidth, _stage.stageHeight);
		}
		
		moja3d function setStage3D(stage3D:Stage3D):void 
		{
			_stage3D = stage3D;
			_stage3D.x = _x;
			_stage3D.y = _y;
			_stage3D.visible = _visible;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ビューポートの表示状態
		 */
		public function get visible():Boolean 
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void 
		{
			_visible = value;
			
			if (_stage3D) _stage3D.visible = _visible;
		}
		
		/**
		 * ビューポートの左端位置
		 */
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
			if (_stage3D) _stage3D.x = _x;
		}
		
		/**
		 * ビューポートの上端位置
		 */
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
			if (_stage3D) _stage3D.y = _y;
		}
		
		/**
		 * ビューポートの幅。この値はレンダリング時に反映されます。
		 */
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			if (value < 100) value = 100;
			if (_width == value) return;
			
			_width = value;
			_updateBackBuffer = true;
		}
		
		/**
		 * ビューポートの高さ。この値はレンダリング時に反映されます。
		 */
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			if (value < 100) value = 100;
			if (_height == value) return;
			
			_height = value;
			_updateBackBuffer = true;
		}
		
		/**
		 * アンチエイリアス設定。この値はレンダリング時に反映されます。
		 */
		public function get antiAlias():int 
		{
			return _antiAlias;
		}
		
		public function set antiAlias(value:int):void 
		{
			if (_antiAlias == value) return;
			
			_antiAlias = value;
			_updateBackBuffer = true;
		}
		
		/**
		 * ビューポートの背景色。この値はレンダリング時に反映されます。
		 */
		public function get backgroundColor():uint 
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void 
		{
			_backgroundColor = value;
			_backgroundData[0] = (_backgroundColor >>> 16 & 0xFF) / 0xFF;
			_backgroundData[1] = (_backgroundColor >>> 8 & 0xFF) / 0xFF;
			_backgroundData[2] = (_backgroundColor & 0xFF) / 0xFF;
		}
		
		/**
		 * ビューポートの背景の不透明度。この値はレンダリング時に反映されます。
		 */
		public function get backgroundAlpha():Number 
		{
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void 
		{
			_backgroundAlpha = value;
		}
		
		moja3d function get backgroundData():Vector.<Number> 
		{
			return _backgroundData;
		}
		
		moja3d function get updateBackBuffer():Boolean 
		{
			return _updateBackBuffer;
		}
		
		moja3d function set updateBackBuffer(value:Boolean):void 
		{
			_updateBackBuffer = value;
		}
		
	}

}