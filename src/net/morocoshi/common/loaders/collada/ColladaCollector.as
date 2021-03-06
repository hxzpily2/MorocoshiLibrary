package net.morocoshi.common.loaders.collada 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.loaders.collada.nodes.ColladaAnimationNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaEffectNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaObjectNode;
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
		//public var animation:ColladaAnimationNode;
		public var option:ColladaParseOption;
		public var unitScale:Number = 1;
		
		public function ColladaCollector() 
		{
			clearLog();
			//animation = new ColladaAnimationNode();
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
		
		public function getMiscLogList():Array
		{
			var result:Array = [];
			for (var key:* in miscLog) 
			{
				result.push(miscLog[key].text + " (" + miscLog[key].count + "箇所)");
			}
			return result;
		}
		
		public function getLog():String 
		{
			var result:String = getMiscLogList().join("\n");
			if (result != "") result += "\n";
			return result;
		}
		
		public function mapJointID(jointID:String, jointIndex:int):void 
		{
			jointIndexMap[jointID] = jointIndex;
		}
		
		private var allAnimationData:Object = { };
		
		public function collectAnimation(animation:ColladaAnimationNode):void 
		{
			for (var key:String in animation.animationData)
			{
				allAnimationData[key] = animation.animationData[key];
			}
		}
		
		public function linkObjectAnimation(object:ColladaNode):void 
		{
			var animationData:Object = allAnimationData[object.id];
			if (animationData)
			{
				for (var key:String in animationData)
				{
					object.addAnimationData(animationData[key]);
				}
			}
		}
		
		public function fixMatrixScale(matrix:Matrix3D):void 
		{
			var p:Vector3D = matrix.position;
			p.scaleBy(unitScale);
			matrix.position = p;
		}
		
	}

}