package net.morocoshi.common.loaders.fbx.objects 
{
	import net.morocoshi.common.loaders.fbx.bones.FBXBoneDeformer;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class FBXBone extends FBXObject 
	{
		public var deformer:FBXBoneDeformer;
		
		public function FBXBone(node:FBXNode = null)
		{
			super(node);
		}
		
	}

}