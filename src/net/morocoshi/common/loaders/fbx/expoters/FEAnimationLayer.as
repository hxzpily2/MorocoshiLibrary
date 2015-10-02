package net.morocoshi.common.loaders.fbx.expoters 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FEAnimationLayer 
	{
		public var layerName:String;
		public var takeName:String;
		public var stackID:Number;
		public var layerID:Number;
		
		public function FEAnimationLayer() 
		{
			layerName = "BaseLayer";
			takeName = "Take 001";
		}
		
		public function toStackNode():FBXNode
		{
			//AnimationStack: 603429264, "AnimStack::Take 001", "" {
			var node:FBXNode = new FBXNode(null, [stackID, "AnimStack::" + takeName]);
			var p70:Array = [
				["LocalStop", "KTime", "Time", "", 153953860000],
				["ReferenceStop", "KTime", "Time", "",153953860000]
			];
			FBXParser.addPropertyNode(node, p70);
			return node;
		}
		
		public function toLayerNode():FBXNode
		{
			//AnimationLayer: 603434016, "AnimLayer::BaseLayer", "" { }
			var node:FBXNode = new FBXNode(null, [layerID, "AnimLayer::" + layerName, ""]);
			return node;
		}
		
		public function toTakeSectionNode():FBXNode
		{
			//take
			var node:FBXNode = new FBXNode(null, [takeName]);
			node.addValue("FileName", ["Take_001.tak"]);
			node.addValue("LocalTime", [0, 153953860000]);
			node.addValue("ReferenceTime", [0, 153953860000]);
			return node;
		}
		
	}

}