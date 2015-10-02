package net.morocoshi.common.debug 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author tencho
	 */
	public class DebugTimer 
	{
		static private var time:int = -1;
		
		public function DebugTimer() 
		{
			
		}
		
		static public function show(label:String = ""):void
		{
			var t:int = (time == -1)? 0 : getTimer() - time;
			trace(label + " " + t + "ms");
			start();
		}
		
		static public function start():void
		{
			time = getTimer();
		}
		
	}

}