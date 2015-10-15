package net.morocoshi.common.debug 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author tencho
	 */
	public class DebugTimer 
	{
		static private var time:Object = { };
		
		public function DebugTimer() 
		{
			
		}
		
		static public function show(label:String = "", id:String = ""):void
		{
			var key:String = "_" + id;
			if (time.hasOwnProperty(key) == false)
			{
				trace(label + " DebugTimer.start()が呼び出されていません！");
				return;
			}
			
			var t:int = getTimer() - time[key];
			trace(label + " " + t + "ms");
			start(id);
		}
		
		static public function start(id:String = ""):void
		{
			time["_" + id] = getTimer();
		}
		
	}

}