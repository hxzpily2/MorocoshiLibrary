package net.morocoshi.components.minimal.buttons 
{
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class BothButton extends PushButton 
	{
		private var rightClickHandler:Function;
		
		public function BothButton(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", clickHandler:Function = null, rightClickHandler:Function = null)
		{
			super(parent, xpos, ypos, label, clickHandler);
			
			this.rightClickHandler = rightClickHandler;
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightMouseDownHandler);
			addEventListener(MouseEvent.RIGHT_CLICK, rightClickDownHandler);
		}
		
		private function rightClickDownHandler(e:MouseEvent):void 
		{
			if (rightClickHandler == null) return;
			
			rightClickHandler(e);
		}
		
		private function rightMouseDownHandler(e:MouseEvent):void 
		{
			_down = true;
			draw();
			
			addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler);
		}
		
		private function rightMouseUpHandler(e:MouseEvent):void 
		{
			_down = false;
			draw();
			
			removeEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler);
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler);
		}
		
	}

}