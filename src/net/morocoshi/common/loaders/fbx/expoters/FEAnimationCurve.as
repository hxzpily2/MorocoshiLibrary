package net.morocoshi.common.loaders.fbx.expoters 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * FBX生成用のアニメーションデータ
	 * 
	 * @author tencho
	 */
	public class FEAnimationCurve 
	{
		public var id:Number;
		public var name:String;
		public var type:String;
		public var keyList:Vector.<FEKeyFrame>;
		//public var timeList:Vector.<int>;
		//public var valueList:Vector.<Number>;
		
		public function FEAnimationCurve() 
		{
			name = "";
			type = "";
			keyList = new Vector.<FEKeyFrame>;
			//timeList = new Vector.<int>;
			//valueList = new Vector.<Number>;
		}
		
		public function toFBXNode():FBXNode
		{
			var def:Number = (type == "S")? 1 : 0;
			var node:FBXNode = new FBXNode(null, [id, "AnimCurve::", ""]);
			node.addValue("Default", [0]);
			node.addValue("KeyVer", [4008]);
			var times:Array = [];
			var flags:Array = [];
			var values:Array = [];
			var floats:Array = [];
			var refs:Array = [];
			for (var i:int = 0; i < keyList.length; i++) 
			{
				var key:FEKeyFrame = keyList[i];
				times.push(key.time * FEScene.timeScale);
				values.push(key.value);
				flags.push(8452);
				floats.push(0, 0, 0, 0);
				refs.push(1);
			}
			node.addListValue("KeyTime", times);
			node.addListValue("KeyValueFloat", values);
			//;KeyAttrFlags: Liner:8452, //Cubic|TangeantUser|WeightedRight|WeightedNextLeft, Cubic|TangeantUser|WeightedRight
			node.addListValue("KeyAttrFlags", flags);
			//;KeyAttrDataFloat: RightSlope:0, NextLeftSlope:-0, RightWeight:0.333233, NextLeftWeight:0.333233, RightVelocity:0, NextLeftVelocity:0; RightSlope:-0, NextLeftSlope:0, RightWeight:0.333233, NextLeftWeight:0.333333, RightVelocity:0, NextLeftVelocity:0
			node.addListValue("KeyAttrDataFloat", floats);
			node.addListValue("KeyAttrRefCount", refs);
			return node;
		}
		
	}

}