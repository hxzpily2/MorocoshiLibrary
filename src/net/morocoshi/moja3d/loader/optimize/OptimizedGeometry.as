package net.morocoshi.moja3d.loader.optimize 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;

	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class OptimizedGeometry 
	{
		public var material:M3DMaterial;
		public var baseMesh:M3DMesh;
		public var surface:M3DSurface;
		public var userData:Object;
		
		public var hasUV:Boolean;
		public var hasNormal:Boolean;
		public var hasColor:Boolean;
		public var hasTangent:Boolean;
		
		private var pointList:Vector.<Vector3D>;
		private var uvList:Vector.<Vector3D>;
		private var normalList:Vector.<Vector3D>;
		private var colorList:Vector.<Vector3D>;
		private var tangentList:Vector.<Vector3D>;
		private var indices:Vector.<uint>;
		
		private var vertexKeyCache:Object;
		private var lastIndex:int;
		//private var lastCount:int = -1;
		//private var count:int;
		
		public function OptimizedGeometry() 
		{
			vertexKeyCache = { };
			lastIndex = -1;
			
			hasColor = false;
			hasUV = false;
			hasNormal = false;
			hasTangent = false;
			
			pointList = new Vector.<Vector3D>;
			uvList = new Vector.<Vector3D>;
			normalList = new Vector.<Vector3D>;
			colorList = new Vector.<Vector3D>;
			tangentList = new Vector.<Vector3D>;
			
			indices = new Vector.<uint>;
		}
		
		public function attach(geom:M3DMeshGeometry, matrix:Matrix3D, indexBegin:int, numTriangle:int):void 
		{
			var scale:Vector3D = matrix.decompose()[2];
			var reverse:Boolean = (scale.x * scale.y * scale.z < 0);
			
			var tempIndices:Vector.<uint> = new Vector.<uint>;
			
			var n:int = indexBegin + numTriangle * 3;// geom.vertexIndices.length;
			for (var i:int = indexBegin; i < n; i++) 
			{
				var index:int = geom.vertexIndices[i];
				
				var u1:int = index * 2;
				var u2:int = index * 2 + 1;
				var i1:int = index * 3;
				var i2:int = index * 3 + 1;
				var i3:int = index * 3 + 2;
				var t1:int = index * 4;
				var t2:int = index * 4 + 1;
				var t3:int = index * 4 + 2;
				var t4:int = index * 4 + 3;
				
				var point:Vector3D = new Vector3D(geom.vertices[i1], geom.vertices[i2], geom.vertices[i3]);
				var uv:Vector3D = geom.uvs? new Vector3D(geom.uvs[u1], geom.uvs[u2]) : new Vector3D(0, 0);
				var normal:Vector3D = geom.normals? new Vector3D(geom.normals[i1], geom.normals[i2], geom.normals[i3]) : new Vector3D(1, 0, 0);;
				var color:Vector3D = geom.colors? new Vector3D(geom.colors[t1], geom.colors[t2], geom.colors[t3], geom.colors[t4]) : new Vector3D(1, 1, 1, 1);
				var tangent:Vector3D = geom.tangents? new Vector3D(geom.tangents[t1], geom.tangents[t2], geom.tangents[t3], geom.tangents[t4]) : new Vector3D(1, 0, 0, 1);
				
				if (geom.uvs) hasUV = true;
				if (geom.normals) hasNormal = true;
				if (geom.colors) hasColor = true;
				if (geom.tangents) hasTangent = true;
				
				point = matrix.transformVector(point);
				tangent = matrix.deltaTransformVector(tangent);
				normal = matrix.deltaTransformVector(normal);
				normal.normalize();
				
				var key:String = point.x + "," + point.y + "," + point.z + "_";
				key += uv.x + "," + uv.y + "_";
				key += normal.x + "," + normal.y + "," + normal.z + "_";
				key += color.x + "," + color.y + "," + color.z + "," + color.w + "_";
				key += tangent.x + "," + tangent.y + "," + tangent.z + "," + tangent.w + "_";
				
				if (vertexKeyCache.hasOwnProperty(key) == false)
				{
					vertexKeyCache[key] = ++lastIndex;
					pointList.push(point);
					uvList.push(uv);
					colorList.push(color);
					tangentList.push(tangent);
					normalList.push(normal);
				}
				tempIndices.push(vertexKeyCache[key]);
			}
			
			if (reverse) tempIndices.reverse();
			
			indices = indices.concat(tempIndices);
		}
		
		public function toGeometry():M3DMeshGeometry 
		{
			var geom:M3DMeshGeometry = new M3DMeshGeometry();
			geom.vertexIndices = indices.concat();
			geom.vertices = openList(pointList, 3);
			geom.normals = hasNormal? openList(normalList, 3) : null;
			geom.tangents = hasTangent? openList(tangentList, 4) : null;
			geom.uvs = hasUV? openList(uvList, 2) : null;
			geom.colors = hasColor? openList(colorList, 4) : null;
			return geom;
		}
		
		private function openList(vector:Vector.<Vector3D>, num:Number):Vector.<Number> 
		{
			if (vector == null) return null;
			var result:Vector.<Number> = new Vector.<Number>;
			var n:int = vector.length;
			for (var i:int = 0; i < n; i++) 
			{
				var v:Vector3D = vector[i];
				if (num >= 1) result.push(v.x);
				if (num >= 2) result.push(v.y);
				if (num >= 3) result.push(v.z);
				if (num >= 4) result.push(v.w);
			}
			return result;
		}
		
		public function get numTriangle():int 
		{
			return indices.length / 3;
		}
		
	}

}