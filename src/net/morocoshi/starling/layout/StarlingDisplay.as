package net.morocoshi.starling.layout
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import net.morocoshi.common.math.geom.RectUtil;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;

	public class StarlingDisplay extends Sprite
	{
		/***/
		public var resizedRect:Rectangle;
		/***/
		public var viewSize:Rectangle;
		/***/
		public var frameRect:Rectangle;
		private var horizontalSize:Rectangle;
		private var verticalSize:Rectangle;
		private var resizeMode:String;
		private var alignX:Number;
		private var alignY:Number;
		private var lastSize:Rectangle;
		private var _isVertical:Boolean
		private var starlingStage:Stage;
		
		public function StarlingDisplay()
		{
			frameRect = new Rectangle();
		}
		
		public function get isVertical():Boolean
		{
			return _isVertical;
		}
		
		public function init(stage:Stage, horizontalSize:Rectangle, verticalSize:Rectangle, resizeMode:String = "auto", alignX:Number = 0.5, alignY:Number = 0.5):void
		{
			starlingStage = stage;
			_isVertical = true;
			lastSize = new Rectangle(0, 0, -1, -1);
			this.horizontalSize = horizontalSize.clone();
			this.verticalSize = verticalSize.clone();
			this.resizeMode = resizeMode;
			viewSize = horizontalSize.clone();
			this.alignX = alignX;
			this.alignY = alignY;
			starlingStage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler(null);
		}
		
		private function stage_resizeHandler(e:Event):void
		{
			var frame:Rectangle = new Rectangle(0, 0, starlingStage.stageWidth, starlingStage.stageHeight);
			if(lastSize.equals(frame))
			{
				return;
			}
			lastSize.copyFrom(frame);
			
			_isVertical = frame.width < frame.height;
			if(_isVertical)
			{
				//縦長
				viewSize.copyFrom(verticalSize);
			}
			else
			{
				//横長
				viewSize.copyFrom(horizontalSize);
			}
			resizedRect = RectUtil.adjust(viewSize, frame, resizeMode, pivotX, pivotY);
			scaleX = int(resizedRect.width) / viewSize.width;
			scaleY = int(resizedRect.height) / viewSize.height;
			x = int(resizedRect.x);
			y = int(resizedRect.y);
			frameRect.x = -resizedRect.x / scaleX;
			frameRect.y = -resizedRect.y / scaleY;
			frameRect.width = frame.width / scaleX;
			frameRect.height = frame.height / scaleY;
			
			dispatchEvent(new Event(Event.RESIZE));
		}
	}
}