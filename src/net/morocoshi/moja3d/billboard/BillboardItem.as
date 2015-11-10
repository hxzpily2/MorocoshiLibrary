package net.morocoshi.moja3d.billboard 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.transform.TransformUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class BillboardItem 
	{
		private var tempLook:Vector3D;
		private var tempUp:Vector3D;
		
		public var enabled:Boolean;
		
		public var object:Object3D;
		public var pivot:Boolean;
		public var frontAxis:String;
		public var topAxis:String;
		public var plane:Boolean;
		
		/**
		 * 
		 * @param	object	ビルボード化するオブジェクト。
		 * @param	pivot	軸回転するかどうか。
		 * @param	plane	カメラ平面に向くかどうか。falseでカメラ視点を向く。
		 * @param	frontAxis	前方のローカル軸。
		 * @param	topAxis	上方のローカル軸。pivot=true時は回転軸。
		 */
		public function BillboardItem(object:Object3D, pivot:Boolean, plane:Boolean, frontAxis:String, topAxis:String) 
		{
			enabled = true;
			tempLook = new Vector3D();
			tempUp = new Vector3D();
			this.object = object;
			this.pivot = pivot;
			this.plane = plane;
			this.frontAxis = frontAxis;
			this.topAxis = topAxis;
		}
		
		public function lookAt(look:Vector3D, upAxis:Vector3D):void
		{
			//tempLookはローカル空間に変換した注視ベクトルになる
			var matrix:Matrix3D = (object.parent)? object.parent.worldMatrix.clone() : new Matrix3D();
			matrix.invert();
			tempLook.copyFrom(look);
			TransformUtil.deltaTransformVector(tempLook, matrix);
			var x:Number = object.x + tempLook.x;
			var y:Number = object.y + tempLook.y;
			var z:Number = object.z + tempLook.z;
			if (pivot)
			{
				TransformUtil.lookAtPivotXYZ(object.matrix, x, y, z, frontAxis, topAxis, true);
			}
			else
			{
				tempUp.copyFrom(upAxis);
				TransformUtil.deltaTransformVector(tempUp, matrix);
				TransformUtil.lookAtXYZ(object.matrix, x, y, z, frontAxis, topAxis, tempUp, true);
			}
			object.matrix = object._matrix;
		}
		
	}

}