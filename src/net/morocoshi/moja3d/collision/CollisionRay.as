package net.morocoshi.moja3d.collision 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	/**
	 * ...
	 * @author tencho
	 */
	public class CollisionRay 
	{
		public var start:Vector3D;
		public var start2:Vector3D;
		public var normal:Vector3D;
		public var normal2:Vector3D;
		public var distance:Number;
		public var distance2:Number;
		public var results:Vector.<CollisionResult>;
		
		public function CollisionRay() 
		{
			start = new Vector3D();
			start2 = new Vector3D();
			normal = new Vector3D();
			normal2 = new Vector3D();
			results = new Vector.<CollisionResult>;
		}
		
		/**
		 * バウンディング球とレイが交差するか
		 * @param	bb
		 * @return
		 */
		public function hitToBall(bb:BoundingBox):Boolean
		{
			var px:Number = bb.worldX - start.x;
			var py:Number = bb.worldY - start.y;
			var pz:Number = bb.worldZ - start.z;
			
			var dotA:Number = normal.x * normal.x + normal.y * normal.y + normal.z * normal.z;
			var dotB:Number = normal.x * px + normal.y * py + normal.z * pz;
			var dotC:Number = px * px + py * py + pz * pz - bb.radius2;
			
			//法線が不正
			if (dotA == 0) return false;
			
			var s:Number = dotB * dotB - dotA * dotC;
			//交差していない
			if (s < 0) return false;
			
			s = Math.sqrt(s);
			//交点までの距離
			var d1:Number = (dotB - s) / dotA;
			var d2:Number = (dotB + s) / dotA;
			
			// レイの反対で衝突
			if (d1 < 0 && d2 < 0) return false;
			if (d1 > distance && d2 > distance) return false;
			
			/*
			q1x = start.x + d1 * vector.x;
			q1y = start.y + d1 * vector.y;
			q1z = start.z + d1 * vector.z;
			q2x = start.x + d2 * vector.x;
			q2y = start.y + d2 * vector.y;
			q2z = start.z + d2 * vector.z;
			*/
			return true;
		}
		
		public function sortResult():void 
		{
			for each(var result:CollisionResult in results)
			{
				result.distance = Vector3D.distance(start, result.worldPosition);
			}
			results.sort(sortFunc);
		}
		
		private function sortFunc(a:CollisionResult, b:CollisionResult):int 
		{
			return int(a.distance > b.distance) - int(a.distance < b.distance);
		}
		
	}

}