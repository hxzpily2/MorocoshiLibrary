package net.morocoshi.moja3d.loader.geometries 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.math.geom.TangentUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DMeshGeometry extends M3DGeometry
	{
		//Geometryにそのまま渡せる展開済みデータ
		public var vertexIndices:Vector.<uint>;
		public var vertices:Vector.<Number>;
		public var normals:Vector.<Number>;
		public var uvs:Vector.<Number>;
		public var tangents:Vector.<Number>;
		public var colors:Vector.<Number>;
		
		public function M3DMeshGeometry() 
		{
		}
		
		override public function getKey():String
		{
			var key:Array = [];
			if (vertexIndices)	key.push("1:" + vertexIndices.join(","));
			if (vertices)		key.push("2:" + vertices.join(","));
			if (normals)		key.push("3:" + normals.join(","));
			if (uvs)			key.push("4:" + uvs.join(","));
			if (tangents)		key.push("5:" + tangents.join(","));
			if (colors)			key.push("6:" + colors.join(","));
			return "mesh_" + key.join("|");
		}
		
		/**
		 * FBXからTANGENT4情報が取れなかった時に計算する用
		 */
		public function calculateTangents():void 
		{
			TangentUtil.calcMeshTangentM3DGeometry(this);
		}
		
		/**
		 * 全頂点のTangent4を0.0.1.1にしたものを返す
		 * @param	numVertices
		 * @return
		 */
		public function getDummyTangent4(numVertices:int):Vector.<Number>
		{
			var result:Vector.<Number> = new Vector.<Number>;
			for (var i:int = 0; i < numVertices; i++) 
			{
				result.push(0, 0, 1, 1);
			}
			return result;
		}
		
		public function fixBasePoint():Vector3D 
		{
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var minZ:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var maxZ:Number = -Number.MAX_VALUE;
			
			var i:int;
			var n:int = vertices.length;
			for (i = 0; i < n; i += 3)
			{
				if (minX > vertices[i + 0]) minX = vertices[i + 0];
				if (maxX < vertices[i + 0]) maxX = vertices[i + 0];
				if (minY > vertices[i + 1]) minY = vertices[i + 1];
				if (maxY < vertices[i + 1]) maxY = vertices[i + 1];
				if (minZ > vertices[i + 2]) minZ = vertices[i + 2];
				if (maxZ < vertices[i + 2]) maxZ = vertices[i + 2];
			}
			
			var center:Vector3D = new Vector3D();
			center.x = (minX + maxX) * 0.5;
			center.y = (minY + maxY) * 0.5;
			center.z = (minZ + maxZ) * 0.5;
			
			for (i = 0; i < n; i += 3)
			{
				vertices[i + 0] -= center.x;
				vertices[i + 1] -= center.y;
				vertices[i + 2] -= center.z;
			}
			
			return center;
		}
		
	}

}