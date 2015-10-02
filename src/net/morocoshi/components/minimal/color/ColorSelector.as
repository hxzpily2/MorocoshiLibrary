package net.morocoshi.components.minimal.color 
{
	import com.bit101.components.ColorChooser;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * カラーセレクタ
	 * 
	 * @author tencho
	 */
	public class ColorSelector extends ColorChooser 
	{
		private var colorBox:Sprite;
		private var myStage:Stage;
		static private var pallet:ColorPalette;
		
		public function ColorSelector(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, color:uint = 0xFFFFFF, defaultHandler:Function = null) 
		{
			super(parent, xpos, ypos, color, defaultHandler);
			
			colorBox = getChildAt(1) as Sprite;
			colorBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			width = 80;
		}
		
		public function setColor(rgb:uint, dispatch:Boolean = true):void
		{
			value = rgb;
			if (dispatch) dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function checkBuild():void
		{
			if (pallet) return;
			pallet = new ColorPalette();
		}
		
		private function mouseDownHandler(e:MouseEvent):void 
		{
			checkBuild();
			myStage = stage;
			myStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			myStage.addEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
		}
		
		private function mouseUpHandler(e:Event):void 
		{
			myStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			myStage.removeEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
			
			var p:Point = colorBox.localToGlobal(new Point(20, 0));
			pallet.linkFrom(this);
			pallet.showTo(myStage, p);
		}
		
		override public function get width():Number 
		{
			return super.width;
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			_input.width = _width - 20 - 2;
			colorBox.x = value - 20;
		}
		
	}

}