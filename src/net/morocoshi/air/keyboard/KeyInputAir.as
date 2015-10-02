package net.morocoshi.air.keyboard 
{
	import flash.events.Event;
	import net.morocoshi.common.ui.keyboard.KeyInput;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class KeyInputAir extends KeyInput 
	{
		
		public function KeyInputAir() 
		{
			super();
		}
		
		override protected function initStage(e:Event = null):void 
		{
			super.initStage(e);
			stage.nativeWindow.addEventListener(Event.DEACTIVATE, deactivateHandler);
		}
		
	}

}