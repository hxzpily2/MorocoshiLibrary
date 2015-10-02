package net.morocoshi.moja3d.view 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class Viewport extends Sprite 
	{
		private var _stage:Stage;
		private var _stage3D:Stage3D;
		private var _backgroundColor:uint;
		private var _backgroundAlpha:Number;
		private var _backgroundData:Vector.<Number>;
		private var _width:Number;
		private var _height:Number;
		private var _antiAlias:int;
		private var _updateBackBuffer:Boolean;
		private var isOnStage:Boolean;
		private var point:Point;
		
		public function Viewport() 
		{
			super();
			
			isOnStage = false;
			_updateBackBuffer = true;
			_backgroundData = new Vector.<Number>;
			_backgroundAlpha = 1;
			_antiAlias = 2;
			backgroundColor = 0x000000;
			point = new Point();
			
			enterFrameHandler(null);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedStageHandler);
		}
		
		public function stopAutoResize():void
		{
			if (_stage)
			{
				_stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			}
		}
		
		public function startAutoResize(stage:Stage):void 
		{
			stopAutoResize();
			_stage = stage;
			_stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler(null);
		}
		
		private function stage_resizeHandler(e:Event):void 
		{
			setSize(_stage.stageWidth, _stage.stageHeight);
		}
		
		public function setSize(w:int, h:int):void 
		{
			width = w;
			height = h;
		}
		
		public function setStage3D(stage3D:Stage3D):void 
		{
			_stage3D = stage3D;
			_stage3D.visible = isOnStage;
		}
		
		private function removedStageHandler(e:Event):void 
		{
			isOnStage = false;
			
			if (_stage3D == null) return;
			
			_stage3D.visible = false;
		}
		
		private function addedStageHandler(e:Event):void 
		{
			isOnStage = true;
			
			if (_stage3D == null) return;
			
			_stage3D.visible = true;
		}
		
		override public function get x():Number 
		{
			return super.x;
		}
		
		override public function set x(value:Number):void 
		{
			super.x = value;
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			if (_stage3D == null) return;
			
			point.x = x;
			point.y = y;
			var worldPoint:Point = localToGlobal(point);
			
			if (_stage3D.x != worldPoint.x) _stage3D.x = worldPoint.x;
			if (_stage3D.y != worldPoint.y) _stage3D.y = worldPoint.y;
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
		override public function get width():Number 
		{
			return _width;
		}
		
		override public function set width(value:Number):void 
		{
			if (value < 100) value = 100;
			if (_width == value) return;
			
			_width = value;
			_updateBackBuffer = true;
		}
		
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function set height(value:Number):void 
		{
			if (value < 100) value = 100;
			if (_height == value) return;
			
			_height = value;
			_updateBackBuffer = true;
		}
		
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
		
		public function get backgroundAlpha():Number 
		{
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void 
		{
			_backgroundAlpha = value;
		}
		
		public function get backgroundData():Vector.<Number> 
		{
			return _backgroundData;
		}
		
		public function get updateBackBuffer():Boolean 
		{
			return _updateBackBuffer;
		}
		
		public function set updateBackBuffer(value:Boolean):void 
		{
			_updateBackBuffer = value;
		}
		
	}

}