package net.morocoshi.common.graphics 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class BackgroundBox extends Sprite 
	{
		private var box:Sprite = new Sprite();
		private var _stage:Stage;
		public function BackgroundBox(stage:Stage, color:uint = 0xffffff, alpha:Number = 1) 
		{
			_stage = stage;
			box.graphics.beginFill(color, alpha);
			box.graphics.drawRect(0, 0, 10, 10);
			box.graphics.endFill();
			addChild(box);
			_stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler();
		}
		
		private function resizeHandler(e:Event = null):void 
		{
			box.width = _stage.stageWidth;
			box.height = _stage.stageHeight;
		}
		
	}

}