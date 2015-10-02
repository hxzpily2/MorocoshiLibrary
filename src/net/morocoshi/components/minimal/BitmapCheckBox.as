package net.morocoshi.components.minimal 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.morocoshi.components.minimal.buttons.BitmapButton;
	
	/**
	 * 画像チェックボックス
	 * 
	 * @author tencho
	 */
	public class BitmapCheckBox extends BitmapButton
	{
		private var images:Vector.<BitmapData>;
		private var _selected:Boolean;
		private var click:Function;
		
		public function BitmapCheckBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, off:BitmapData = null, on:BitmapData = null, defaultHandler:Function = null, smoothing:Boolean = true, scaleMode:String = "auto")
		{
			this.click = defaultHandler;
			super(parent, xpos, ypos, off, null, null, clickHandler, smoothing, scaleMode);
			_selected = false;
			images = Vector.<BitmapData>([off, on]);
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			selected = !_selected;
			if (click != null) click(e);
		}
		
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function setSelectionSilent(value:Boolean):void
		{
			_selected = value;
			updateImage();
		}
		
		public function set selected(value:Boolean):void 
		{
			_selected = value;
			updateImage();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function updateImage():void 
		{
			imageClip.bitmapData = images[int(_selected)];
		}
		
	}

}