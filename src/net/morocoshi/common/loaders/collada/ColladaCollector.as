package net.morocoshi.common.loaders.collada 
{
	import net.morocoshi.common.loaders.collada.nodes.ColladaAnimationNode;
	/**
	 * パース時の各種情報を集めるクラス
	 * 
	 * @author tencho
	 */
	public class ColladaCollector 
	{
		public var log:String;
		
		private var miscLog:Object;
		private var jointCount:int = -1;
		public var jointIndexMap:Object = { };
		public var jointMatrixMap:Object = { };
		public var animation:ColladaAnimationNode;
		public var option:ColladaParseOption;
		
		public function ColladaCollector() 
		{
			clearLog();
			animation = new ColladaAnimationNode();
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
		
		public function mapJointID(jointID:String, jointIndex:int):void 
		{
			jointIndexMap[jointID] = jointIndex;
		}
		
	}

}