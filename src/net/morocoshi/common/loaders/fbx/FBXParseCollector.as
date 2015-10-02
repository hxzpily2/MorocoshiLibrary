package net.morocoshi.common.loaders.fbx 
{
	/**
	 * パース時の各種情報を集めるクラス
	 * 
	 * @author tencho
	 */
	public class FBXParseCollector 
	{
		private var miscLog:Object;
		public var log:String;
		public var option:FBXParseOption;
		
		public function FBXParseCollector() 
		{
			clearLog();
			option = new FBXParseOption();
		}
		
		private function clearLog():void 
		{
			log = "";
			miscLog = { };
		}
		
		public function addMiscLog(id:String, text:String):void
		{
			if (miscLog.hasOwnProperty(id))
			{
				miscLog[id].count++;
			}
			else
			{
				miscLog[id] = { text:text, count:1 };
			}
		}
		public function addLog(...args):void
		{
			log += args.join("\n") + "\n";
		}
		
		public function alert(...args):void 
		{
			log += "[ERROR] " + args.join("\n[ERROR] ") + "\n";
		}
		
		public function getLog():String 
		{
			var result:String = log;
			for (var key:* in miscLog) 
			{
				result += miscLog[key].text + " (" + miscLog[key].count + "箇所)\n";
			}
			return result;
		}
		
	}

}