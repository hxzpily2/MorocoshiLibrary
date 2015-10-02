package net.morocoshi.common.collision.solid.primitives 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Collision3DMesh extends Collision3DObject
	{
		//public var aabb:AABB3D;
		//public var obb:OBB3D;
		public var triangleList:Vector.<Triangle3D>;
		private var pointLink:Object;
		private var rawPointLink:Object;
		
		public function Collision3DMesh() 
		{
			//aabb = new AABB3D();
			//obb = new OBB3D();
			pointLink = { };
			rawPointLink = { };
			triangleList = new Vector.<Triangle3D>;
		}
		
		/**
		 * Meshからコリジョンデータをパースする
		 * @param	mesh
		 */
		override public function parseFromMesh(mesh:Mesh):void
		{
			triangleList.length = 0;
			
			matrix = mesh.matrix;
			var points:Vector.<Number> = mesh.geometry.getVertices(VertexAttribute.POSITION);
			var indices:Vector.<uint> = mesh.geometry.vertexIndices;
			var n:int = indices.length;
			for (var i:int = 0; i < n; i += 3)
			{
				var triangle:Triangle3D = new Triangle3D();
				triangle.a = getPosition(points, indices, i + 0);
				triangle.b = getPosition(points, indices, i + 1);
				triangle.c = getPosition(points, indices, i + 2);
				triangle.instance = this;
				triangleList.push(triangle);
			}
		}
		
		/**
		 * 同一座標の頂点はキャッシュして共有する事で変形時の再計算を軽くする
		 * @param	points
		 * @param	indices
		 * @param	index
		 * @return
		 */
		private function getPosition(points:Vector.<Number>, indices:Vector.<uint>, index:int):Vector3D
		{
			var x:Number = points[indices[index] * 3 + 0];
			var y:Number = points[indices[index] * 3 + 1];
			var z:Number = points[indices[index] * 3 + 2];
			var key:String = x + "," + y + "," + z;
			if (!pointLink[key])
			{
				pointLink[key] = new Vector3D(x, y, z);
				rawPointLink[key] = new Vector3D(x, y, z);
			}
			return pointLink[key];
		}
		
		/**
		 * メッシュの頂点再計算
		 */
		override protected function calculate():void 
		{
			//ワールド姿勢
			var data:Vector.<Number> = _concatenatedMatrix.rawData;
			
			for (var key:String in pointLink)
			{
				var from:Vector3D = rawPointLink[key];
				var to:Vector3D = pointLink[key];
				to.x = data[0] * from.x + data[4] * from.y + data[8]  * from.z + data[12];
				to.y = data[1] * from.x + data[5] * from.y + data[9]  * from.z + data[13];
				to.z = data[2] * from.x + data[6] * from.y + data[10] * from.z + data[14];
			}
			
			var n:int = triangleList.length;
			for (var i:int = 0; i < n; i++) 
			{
				triangleList[i].calculate();
			}
		}
		
	}

}