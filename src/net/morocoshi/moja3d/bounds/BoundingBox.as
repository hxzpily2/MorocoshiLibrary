package net.morocoshi.moja3d.bounds 
{
	import flash.geom.Matrix3D;
	import flash.utils.getQualifiedClassName;
	import net.morocoshi.common.collision.solid.bounds.AABB3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Object3D;
	
	use namespace moja3d;
	
	/**
	 * バウンディング情報。バウンディングボックスから求めた球の情報とか。
	 * 
	 * @author tencho
	 */
	public class BoundingBox 
	{
		public var minX:Number;
		public var minY:Number;
		public var minZ:Number;
		public var maxX:Number;
		public var maxY:Number;
		public var maxZ:Number;
		//中心座標
		public var worldX:Number;
		public var worldY:Number;
		public var worldZ:Number;
		public var localX:Number;
		public var localY:Number;
		public var localZ:Number;
		/**半径の二乗*/
		public var radius2:Number;
		
		public function BoundingBox() 
		{
			localX = 0;
			localY = 0;
			localZ = 0;
			worldX = 0;
			worldY = 0;
			worldZ = 0;
			radius2 = 0;
		}
		
		/**
		 * 指定座標がmin～max範囲内に収まっているか
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		moja3d function contains(x:Number, y:Number, z:Number):Boolean
		{
			if (minX <= x && x <= maxX &&
				minY <= y && y <= maxY &&
				minZ <= z && z <= maxZ
			)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * バウンディングボックスの中心ワールド座標をObject3Dのワールド姿勢から求める。必要ならバウンディング球の半径を再計算する。
		 * @param	object	対象のObject3D
		 * @param	calculateRadius	バウンディング球の半径を再計算するか。対象Object3Dとその親が回転、スケーリングしていたら実行する。
		 */
		moja3d function transformByMatrix(matrix:Matrix3D, calculateRadius:Boolean):void
		{
			var data:Vector.<Number> = matrix.rawData;
			worldX = data[0] * localX + data[4] * localY + data[8]  * localZ + data[12];
			worldY = data[1] * localX + data[5] * localY + data[9]  * localZ + data[13];
			worldZ = data[2] * localX + data[6] * localY + data[10] * localZ + data[14];
			
			//半径を境界ボックスのサイズからアバウトに計算
			if (calculateRadius)
			{
				var px:Number;
				var py:Number;
				var pz:Number;
				var dx:Number;
				var dy:Number;
				var dz:Number;
				
				var xyzList:Array = [
					{ x:maxX, y:maxY, z:maxZ },
					{ x:minX, y:maxY, z:maxZ },
					{ x:maxX, y:minY, z:maxZ },
					{ x:maxX, y:maxY, z:minZ }
				];
				
				var maxR:Number = -Number.MAX_VALUE;
				for (var i:int = 0; i < 4; i++) 
				{
					var xyz:Object = xyzList[i];
					px = data[0] * xyz.x + data[4] * xyz.y + data[8]  * xyz.z + data[12];
					py = data[1] * xyz.x + data[5] * xyz.y + data[9]  * xyz.z + data[13];
					pz = data[2] * xyz.x + data[6] * xyz.y + data[10] * xyz.z + data[14];
					dx = (px - worldX);
					dy = (py - worldY);
					dz = (pz - worldZ);
					var rr:Number = dx * dx + dy * dy + dz * dz;
					if (maxR < rr) maxR = rr;
				}
				radius2 = maxR;
			}
		}
		
		public function clone():BoundingBox 
		{
			var bb:BoundingBox = new BoundingBox();
			bb.minX = minX;
			bb.minY = minY;
			bb.minZ = minZ;
			bb.maxX = maxX;
			bb.maxY = maxY;
			bb.maxZ = maxZ;
			bb.localX = localX;
			bb.localY = localY;
			bb.localZ = localZ;
			bb.worldX = worldX;
			bb.worldY = worldY;
			bb.worldZ = worldZ;
			bb.radius2 = radius2;
			return bb;
		}
		
		static public function getUniondBoundingBox(items:Vector.<BoundingBox>):BoundingBox
		{
			var n:int = items.length;
			if (n == 0)
			{
				return null;
			}
			
			var result:BoundingBox = new BoundingBox();
			result.minX = Number.MAX_VALUE;
			result.minY = Number.MAX_VALUE;
			result.minZ = Number.MAX_VALUE;
			result.maxX = -Number.MAX_VALUE;
			result.maxY = -Number.MAX_VALUE;
			result.maxZ = -Number.MAX_VALUE;
			
			for (var i:int = 0; i < n; i++) 
			{
				var b:BoundingBox = items[i];
				if (b.minX < result.minX) result.minX = b.minX;
				if (b.minY < result.minY) result.minY = b.minY;
				if (b.minZ < result.minZ) result.minZ = b.minZ;
				if (b.maxX > result.maxX) result.maxX = b.maxX;
				if (b.maxY > result.maxY) result.maxY = b.maxY;
				if (b.maxZ > result.maxZ) result.maxZ = b.maxZ;
			}
			
			return result;
		}
		
		/**
		 * 複数のBoundingBoxの境界球を全て包む境界ボックスサイズを求める。
		 * @param	items
		 * @return
		 */
		static public function getUniondSphereBox(items:Vector.<BoundingBox>):BoundingBox
		{
			var n:int = items.length;
			if (n == 0)
			{
				return null;
			}
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var minZ:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var maxZ:Number = -Number.MAX_VALUE;
			for (var i:int = 0; i < n; i++) 
			{
				var b:BoundingBox = items[i];
				var r:Number = Math.sqrt(b.radius2);
				if (b.worldX - r < minX) minX = b.worldX - r;
				if (b.worldY - r < minY) minY = b.worldY - r;
				if (b.worldZ - r < minZ) minZ = b.worldZ - r;
				if (b.worldX + r > maxX) maxX = b.worldX + r;
				if (b.worldY + r > maxY) maxY = b.worldY + r;
				if (b.worldZ + r > maxZ) maxZ = b.worldZ + r;
			}
			
			var result:BoundingBox = new BoundingBox();
			result.minX = minX;
			result.minY = minY;
			result.minZ = minZ;
			result.maxX = maxX;
			result.maxY = maxY;
			result.maxZ = maxZ;
			return result;
		}
		
		/**
		 * 指定のObject3Dが内包している自分を含めた全てのメッシュを包む境界球のBoundingBoxを取得
		 * @param	object
		 * @return
		 */
		static public function getBoundingBox(object:Object3D):BoundingBox
		{
			var objectList:Vector.<Object3D> = object.getChildren(true, true, Mesh);
			var boundsList:Vector.<BoundingBox> = new Vector.<BoundingBox>;
			
			var n:int = objectList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var mesh:Mesh = objectList[i] as Mesh;
				//mesh.updateBounds();
				boundsList.push(mesh.boundingBox);
			}
			
			return BoundingBox.getUniondSphereBox(boundsList);
		}
		
		public function toAABB3D():AABB3D 
		{
			var aabb:AABB3D = new AABB3D();
			aabb.xMin = minX;
			aabb.yMin = minY;
			aabb.zMin = minZ;
			aabb.xMax = maxX;
			aabb.yMax = maxY;
			aabb.zMax = maxZ;
			return aabb;
		}
		
		public function setSphere(radius:Number):void 
		{
			localX = 0;
			localY = 0;
			localZ = 0;
			minX = -radius;
			minY = -radius;
			minZ = -radius;
			maxX = radius;
			maxY = radius;
			maxZ = radius;
			radius2 = radius * radius;
		}
		
		public function copyFrom(from:BoundingBox):void 
		{
			minX = from.minX;
			minY = from.minY;
			minZ = from.minZ;
			maxX = from.maxX;
			maxY = from.maxY;
			maxZ = from.maxZ;
			localX = from.localX;
			localY = from.localY;
			localZ = from.localZ;
			worldX = from.worldX;
			worldY = from.worldY;
			worldZ = from.worldZ;
			radius2 = from.radius2;
		}
		
		public function toString():String 
		{
			return "[" + getQualifiedClassName(this).split("::")[1] + " min(" + minX + "," + minY + "," + minZ + ") max(" + maxX + "," + maxY + "," + maxZ + ")]";
		}
		
	}

}