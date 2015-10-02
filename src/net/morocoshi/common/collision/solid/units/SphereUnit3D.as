package net.morocoshi.common.collision.solid.units 
{
	import flash.geom.Vector3D;
	
	/**
	 * 球形移動コリジョン
	 * 
	 * @author tencho
	 */
	public class SphereUnit3D extends Unit3D
	{
		/**半径*/
		public var radius:Number = 1;
		
		public function SphereUnit3D() 
		{
		}
		
		/**
		 * 加速度による移動量も含めたAABBを計算する
		 */
		override public function updateAABB():void 
		{
			aabb.xMin = position.x - radius;
			aabb.yMin = position.y - radius;
			aabb.zMin = position.z - radius;
			aabb.xMax = position.x + radius;
			aabb.yMax = position.y + radius;
			aabb.zMax = position.z + radius;
			if (displace.x < 0) aabb.xMin += displace.x;
			if (displace.y < 0) aabb.yMin += displace.y;
			if (displace.z < 0) aabb.zMin += displace.z;
			if (displace.x > 0) aabb.xMax += displace.x;
			if (displace.y > 0) aabb.yMax += displace.y;
			if (displace.z > 0) aabb.zMax += displace.z;
			
			super.updateAABB();
		}
		
		/**
		 * 
		 * @param	unit
		 * @param	count
		 */
		override public function hit(unit:Unit3D, count:int):void 
		{
			var sphere:SphereUnit3D = unit as SphereUnit3D;
			if (!sphere) return;
			if (!aabb.hitTest(sphere.aabb)) return;
			
			var length:Number = radius + sphere.radius;
			var length2:Number = length * length;
			var dx:Number = position.x - unit.position.x;
			var dy:Number = position.y - unit.position.y;
			var dz:Number = position.z - unit.position.z;
			var vector:Vector3D = new Vector3D(dx, dy, dz);
			vector.normalize();
			var distance2:Number = dx * dx + dy * dy + dz * dz;
			if (distance2 >= length2) return;
			
			var power:Number = 0.4 * count;
			if (power > 1) power = 1;
			var diff:Number = (length - Math.sqrt(distance2)) * power;
			var rate1:Number = 0.5;
			var rate2:Number = 1 - rate1;
			displace.x += vector.x * diff * rate1;
			displace.y += vector.y * diff * rate1;
			displace.z += vector.z * diff * rate1;
			sphere.displace.x -= vector.x * diff * rate2;
			sphere.displace.y -= vector.y * diff * rate2;
			sphere.displace.z -= vector.z * diff * rate2;
		}
		
	}

}