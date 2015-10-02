package net.morocoshi.common.loaders.fbx.bones 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXPose
	{
		public var nodeID:Number;
		public var matrix:Vector.<Number>;
		
		public function FBXPose(node:FBXNode = null) 
		{
			if (node != null) parse(node);
		}
		
		public function parse(node:FBXNode):void 
		{
			if (node.Node)
			{
				nodeID = Number(node.Node[0]);
			}
			if (node.Matrix)
			{
				matrix = Vector.<Number>(node.Matrix[0][0].a[0]);
			}
		}
		
	}

}