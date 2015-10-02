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
	 * @author tencho
	 */
	public class OptimizedGeometry 
	{
		public var material:M3DMaterial;
		public var baseMesh:M3DMesh;
		public var surface:M3DSurface;
		public var userData:Object;
		public var hasColor:Boolean;
		public var hasUV:Boolean;
		public var hasNormal:Boolean;
		public var hasTangent:Boolean;
		private var pointList:Vector.<Vector3D> = new Vector.<Vector3D>;
		private var normalList:Vector.<Vector3D>;
		private var tangentList:Vector.<Vector3D>;
		private var colorList:Vector.<Vector3D>;
		private var uvList:Vector.<Vector3D>;
		private var indices:Vector.<uint> = new Vector.<uint>;;
		private var lastCount:int = -1;
		private var count:int;
		
		public function OptimizedGeometry() 
		{
			hasColor = false;
			hasUV = false;
			hasNormal = false;
			hasTangent = false;
		}
		
		public function attach(geom:M3DMeshGeometry, matrix:Matrix3D, indexBegin:int, numTriangle:int):void 
		{
			var i:int;
			var n:int;
			
			var scale:Vector3D = matrix.decompose()[2];
			var reverse:Boolean = (scale.x * scale.y * scale.z < 0);
			
			var tempIndices:Vector.<uint> = new Vector.<uint>;
			var indexCache:Object = { };
			count = 0;
			n = indexBegin + numTriangle * 3;// geom.vertexIndices.length;
			for (i = indexBegin; i < n; i++) 
			{
				var index:int = geom.vertexIndices[i];
				if (indexCache[index] != undefined)
				{
					tempIndices.push(indexCache[index]);
					continue;
				}
				count++;
				indexCache[index] = lastCount + count;
				tempIndices.push(indexCache[index]);
				
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
				point = matrix.transformVector(point);
				pointList.push(point);
				
				if (geom.colors)
				{
					hasColor = true;
					colorList = initVector(colorList);
					var color:Vector3D = new Vector3D(geom.colors[t1], geom.colors[t2], geom.colors[t3], geom.colors[t4]);
					colorList.push(color);
				}
				else
				{
					colorList = initVector(colorList);
					colorList.push(new Vector3D(1, 1, 1, 1));
				}
				
				if (geom.uvs)
				{
					hasUV = true;
					uvList = initVector(uvList);
					var uv:Vector3D = new Vector3D(geom.uvs[u1], geom.uvs[u2]);
					uvList.push(uv);
				}
				else
				{
					uvList = initVector(uvList);
					uvList.push(new Vector3D(0, 0));
				}
				
				if(geom.tangents)
				{
					hasTangent = true;
					tangentList = initVector(tangentList);
					var tangent:Vector3D = new Vector3D(geom.tangents[t1], geom.tangents[t2], geom.tangents[t3], geom.tangents[t4]);
					tangent = matrix.deltaTransformVector(tangent);
					tangentList.push(tangent);
				}
				else
				{
					tangentList = initVector(tangentList);
					tangentList.push(new Vector3D(1, 0, 0, 1));
				}
				
				if (geom.normals)
				{
					hasNormal = true;
					normalList = initVector(normalList);
					var normal:Vector3D = new Vector3D(geom.normals[i1], geom.normals[i2], geom.normals[i3]);
					normal = matrix.deltaTransformVector(normal);
					normal.normalize();
					normalList.push(normal);
				}
				else
				{
					normalList = initVector(normalList);
					normalList.push(new Vector3D(1, 0, 0));
				}
			}
			lastCount += count;
			
			if (reverse)
			{
				tempIndices.reverse();
			}
			indices = indices.concat(tempIndices);
		}
		
		private function initVector(list:Vector.<Vector3D>):Vector.<Vector3D> 
		{
			if (list) return list;
			
			list = new Vector.<Vector3D>;
			return list;
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