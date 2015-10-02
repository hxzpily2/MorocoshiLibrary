package net.morocoshi.common.loaders.fbx.objects 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.loaders.fbx.attributes.FBXCameraAttribute;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class FBXCamera extends FBXObject 
	{
		public var attribute:FBXCameraAttribute;
		public function FBXCamera(node:FBXNode = null)
		{
			super(node);
		}
		
		override public function getMatrix():Matrix3D 
		{
			var matrix:Matrix3D = super.getMatrix();
			var data:Vector.<Number> = matrix.rawData;
			var axis:Vector3D = new Vector3D(data[4], data[5], data[6]);
			matrix.appendRotation(-90, axis, matrix.position);
			return matrix;
		}
		
	}

}