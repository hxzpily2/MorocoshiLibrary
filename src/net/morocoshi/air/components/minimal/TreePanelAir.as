package net.morocoshi.air.components.minimal 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.components.minimal.TreePanel;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class TreePanelAir extends TreePanel 
	{
		private var dd:DragDrop;
		private var _isDropping:Boolean;
		private var _droppingScrollSpeed:Number = 20;
		
		public function TreePanelAir(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
			
			dd = new DragDrop();
			dd.onDragRoll = dragRollHandler;
			dd.addDropTarget(this);
		}
		
		private function dragRollHandler(over:Boolean):void 
		{
			_isDropping = over;
			if (_isDropping)
			{
				addEventListener(Event.ENTER_FRAME, dropping_enterHandler);
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, dropping_enterHandler);
			}
		}
		
		private function dropping_enterHandler(e:Event):void 
		{
			if (vscroll.enabled == false) return;
			var power:Number;
			if (dd.stageY < 70)
			{
				power = Math.min(1, (70 - dd.stageY) / 30);
				vscroll.value = Math.min(vscroll.value - _droppingScrollSpeed * power, vscroll.maximum);
			}
			if (dd.stageY > height - 30)
			{
				power = Math.min(1, (dd.stageY - height + 30) / 30);
				vscroll.value = Math.max(vscroll.value + _droppingScrollSpeed * power, vscroll.minimum);;
			}
			updateContentsPos();
		}
		
		public function get isDropping():Boolean 
		{
			return _isDropping;
		}
		
	}

}