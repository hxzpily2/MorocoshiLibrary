package net.morocoshi.common.loaders.fbx.geometries 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.common.loaders.fbx.FBXElement;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.objects.FBXObject;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXGeometry extends FBXElement
	{
		public var ownerList:Vector.<FBXObject>;
		
		public function FBXGeometry(node:FBXNode = null)
		{
			ownerList = new Vector.<FBXObject>;
			
			super(node);
		}
		
		override public function parse(node:FBXNode):void
		{
			super.parse(node);
		}
		
		public function rescale(x:int, y:int, z:int):void
		{
		}
		
		public function setGeomMatrix(matrix:Matrix3D):void 
		{
		}
		
		public function clone():FBXGeometry 
		{
			var geom:FBXGeometry = new FBXGeometry();
			geom.id = id;
			geom.ownerList = ownerList.concat();
			return geom;
		}
		
		public function addOwnerObject(fbx:FBXObject):void 
		{
			ownerList.push(fbx);
		}
		
	}

}