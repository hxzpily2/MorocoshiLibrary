package net.morocoshi.moja3d.collision 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.resources.CombinedGeometry;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	
	use namespace moja3d;
	
	/**
	 * メッシュコリジョン
	 * 
	 * @author tencho
	 */
	public class CollisionMesh 
	{
		private var faceList:Vector.<CollisionFace>;
		private var hit:Vector3D;
		private const SMALL:Number = 0.000000001;
		
		public function CollisionMesh() 
		{
			hit = new Vector3D();
			faceList = new Vector.<CollisionFace>;
		}
		
		public function parse(geom:Geometry):void
		{
			faceList.length = 0;
			if (geom is CombinedGeometry)
			{
				for each(var g:Geometry in CombinedGeometry(geom).geometries)
				{
					parseGeometry(g);
				}
			}
			else
			{
				parseGeometry(geom);
			}
		}
		
		private function parseGeometry(geom:Geometry):void
		{
			if (geom.hasAttribute(VertexAttribute.POSITION) == false) return;
			
			var points:Vector.<Number> = geom.getVertices(VertexAttribute.POSITION);
			var indices:Vector.<uint> = geom.vertexIndices;
			var n:int = indices.length;
			for (var i:int = 0; i < n; i += 3)
			{
				var face:CollisionFace = new CollisionFace();
				face.a = new Vector3D(points[indices[i + 0] * 3], points[indices[i + 0] * 3 + 1], points[indices[i + 0] * 3 + 2]);
				face.b = new Vector3D(points[indices[i + 1] * 3], points[indices[i + 1] * 3 + 1], points[indices[i + 1] * 3 + 2]);
				face.c = new Vector3D(points[indices[i + 2] * 3], points[indices[i + 2] * 3 + 1], points[indices[i + 2] * 3 + 2]);
				face.calculate();
				faceList.push(face);
			}
		}
		
		public function finaly():void 
		{
			DataUtil.deleteVector(faceList);
			faceList = null;
			hit = null;
		}
		
		/**
		 * レイと三角形との衝突判定
		 * @param	ray			レイ
		 * @param	doubleSided	裏向きのポリゴンも衝突判定する
		 */
		public function getHitData(ray:CollisionRay, doubleSided:Boolean, mesh:Mesh):void 
		{
			for each(var face:CollisionFace in faceList)
			{
				//法線ベクトルとレイで傾きチェック
				var vn:Number = (ray.normal2.x * face.normal.x) + (ray.normal2.y * face.normal.y) + (ray.normal2.z * face.normal.z);
				
				//1.平面と平行なら衝突なし(計算誤差を考慮)
				//2.片面チェック時に視線と法線が同じ向き（裏側を見ている）なら衝突なし
				if ((vn < SMALL && vn > -SMALL) || (vn > 0 && doubleSided == false)) continue;
				
				var distance:Number = -((ray.start2.x - face.a.x) * face.normal.x + (ray.start2.y - face.a.y) * face.normal.y + (ray.start2.z - face.a.z) * face.normal.z) / vn;
				
				//衝突位置が視線と逆方向なら交差なし
				if (distance < 0) continue;
				if (ray.distance2 > 0 && distance > ray.distance2) continue;
				
				//視線と平面との衝突点
				hit.x = ray.normal2.x * distance + ray.start2.x;
				hit.y = ray.normal2.y * distance + ray.start2.y;
				hit.z = ray.normal2.z * distance + ray.start2.z;
				
				//衝突点が三角形内にあるかチェック(計算誤差を考慮)
				if (check(hit, face.a, face.ab, face.normal) > SMALL) continue;
				if (check(hit, face.b, face.bc, face.normal) > SMALL) continue;
				if (check(hit, face.c, face.ca, face.normal) > SMALL) continue;
				
				//衝突情報
				var data:CollisionResult = new CollisionResult();
				data.localPosition = hit.clone();
				data.worldPosition = mesh.worldMatrix.transformVector(data.localPosition);
				data.face = face;
				data.target = mesh;
				ray.results.push(data);
			}
		}
		
		public function clone():CollisionMesh 
		{
			var result:CollisionMesh = new CollisionMesh();
			result.faceList = faceList.concat();
			return result;
		}
		
		private function check(h:Vector3D, p:Vector3D, v:Vector3D, n:Vector3D):Number 
		{
			var x:Number = h.x - p.x;
			var y:Number = h.y - p.y;
			var z:Number = h.z - p.z;
			var tx:Number = y * v.z - z * v.y;
			var ty:Number = z * v.x - x * v.z;
			var tz:Number = x * v.y - y * v.x;
			return (tx * n.x) + (ty * n.y) + (tz * n.z);
		}
		
	}

}