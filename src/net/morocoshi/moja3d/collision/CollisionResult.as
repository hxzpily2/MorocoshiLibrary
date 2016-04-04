package net.morocoshi.moja3d.collision 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * 衝突情報
	 * 
	 * @author tencho
	 */
	public class CollisionResult 
	{
		/**衝突オブジェクト*/
		public var target:Object3D;
		/**衝突した三角ポリゴンの情報*/
		public var face:CollisionFace;
		/**オブジェクトのローカル空間での衝突点*/
		public var localPosition:Vector3D;
		/**ワールド空間での衝突点*/
		public var worldPosition:Vector3D;
		/**衝突点のカメラの視点からの距離*/
		public var distance:Number;
		
		public function CollisionResult() 
		{
		}
		
	}

}