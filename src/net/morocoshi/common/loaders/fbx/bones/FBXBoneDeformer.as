package net.morocoshi.common.loaders.fbx.bones 
{
	import net.morocoshi.common.loaders.fbx.FBXElement;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXBoneDeformer extends FBXElement
	{
		public var indexes:Vector.<Number>;
		public var weights:Vector.<Number>;
		public var transform:Vector.<Number>;
		public var transformLink:Vector.<Number>;
		
		public function FBXBoneDeformer(node:FBXNode = null) 
		{
			super(node);
		}
		
		override public function parse(node:FBXNode):void 
		{
			super.parse(node);
			
			if (node.Indexes)
			{
				indexes = Vector.<Number>(node.Indexes[0][0].a[0]);
			}
			if (node.Weights)
			{
				weights = Vector.<Number>(node.Weights[0][0].a[0]);
			}
			if (node.Transform)
			{
				transform = Vector.<Number>(node.Transform[0][0].a[0]);
			}
			if (node.TransformLink)
			{
				transformLink = Vector.<Number>(node.TransformLink[0][0].a[0]);
			}
		}
		
	}

}