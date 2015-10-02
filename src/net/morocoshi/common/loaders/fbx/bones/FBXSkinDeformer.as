package net.morocoshi.common.loaders.fbx.bones 
{
	import net.morocoshi.common.loaders.fbx.FBXElement;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXSkinDeformer extends FBXElement
	{
		public var boneList:Vector.<FBXBoneDeformer>;
		
		public function FBXSkinDeformer(node:FBXNode = null) 
		{
			boneList = new Vector.<FBXBoneDeformer>;
			super(node);
		}
		
	}

}