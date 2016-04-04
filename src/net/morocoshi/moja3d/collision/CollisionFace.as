package net.morocoshi.moja3d.collision 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.moja3d;
	
	use namespace moja3d;
	
	/**
	 * 三角ポリゴン
	 * 
	 * @author tencho
	 */
	public class CollisionFace 
	{
		public var a:Vector3D;
		public var b:Vector3D;
		public var c:Vector3D;
		public var normal:Vector3D;
		moja3d var ab:Vector3D;
		moja3d var bc:Vector3D;
		moja3d var ca:Vector3D;
		moja3d var valid:Boolean;
		
		public function CollisionFace() 
		{
			ab = new Vector3D();
			bc = new Vector3D();
			ca = new Vector3D();
			normal = new Vector3D();
		}
		
		/**
		 * 事前計算
		 */
		public function calculate():void
		{
			/*
			aabb.xMin = min(a.x, b.x, c.x);
			aabb.yMin = min(a.y, b.y, c.y);
			aabb.zMin = min(a.z, b.z, c.z);
			aabb.xMax = max(a.x, b.x, c.x);
			aabb.yMax = max(a.y, b.y, c.y);
			aabb.zMax = max(a.z, b.z, c.z);
			*/
			ab.x = b.x - a.x;
			ab.y = b.y - a.y;
			ab.z = b.z - a.z;
			bc.x = c.x - b.x;
			bc.y = c.y - b.y;
			bc.z = c.z - b.z;
			ca.x = a.x - c.x;
			ca.y = a.y - c.y;
			ca.z = a.z - c.z;
			normal.x = (ab.y * -ca.z) - (ab.z * -ca.y);
			normal.y = (ab.z * -ca.x) - (ab.x * -ca.z);
			normal.z = (ab.x * -ca.y) - (ab.y * -ca.x);
			if (normal.x == 0 && normal.y == 0 && normal.z == 0)
			{
				valid = false;
				return;
			}
			valid = true;
			ab.normalize();
			bc.normalize();
			ca.normalize();
			normal.normalize();
		}
		
	}

}