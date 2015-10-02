package net.morocoshi.common.loaders.fbx.expoters 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用のアニメーションデータ
	 * 
	 * @author tencho
	 */
	public class FEAnimationNode 
	{
		public var id:Number;
		public var type:String;
		public var x:FEAnimationCurve;
		public var y:FEAnimationCurve;
		public var z:FEAnimationCurve;
		public var layer:FEAnimationLayer;
		static public const TYPE_TRANSLATION:String = "Lcl Translation";
		static public const TYPE_ROTATION:String = "Lcl Rotation";
		static public const TYPE_SCALING:String = "Lcl Scaling";
		
		/**
		 * @param	type	[T/R/S]
		 */
		public function FEAnimationNode(type:String) 
		{
			this.type = type;
		}
		
		public function toFBXNode():FBXNode
		{
			var def:Number = (type == TYPE_SCALING)? 1 : 0;
			var TRS:String = "";
			if (type == TYPE_TRANSLATION) TRS = "T";
			if (type == TYPE_ROTATION) TRS = "R";
			if (type == TYPE_SCALING) TRS = "S";
			var node:FBXNode = new FBXNode(null, [id, "AnimCurveNode::" + TRS, ""]);
			var p70:Array = [
				["d", "Compound", "", ""],
				["d|X", "Number", "", "A", def],
				["d|Y", "Number", "", "A", def],
				["d|Z", "Number", "", "A", def]
			];
			FBXParser.addPropertyNode(node, p70);
			return node;
		}
		
	}

}