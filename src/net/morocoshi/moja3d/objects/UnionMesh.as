package net.morocoshi.moja3d.objects 
{
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.resources.CombinedGeometry;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * このオブジェクトにaddChildしたメッシュを自動でサーフェイス統合する
	 * 
	 * @author tencho
	 */
	public class UnionMesh extends Mesh 
	{
		/**統合する頂点アトリビュートのタイプ*/
		public var requiredAttribute:Vector.<uint>;
		
		public function UnionMesh() 
		{
			super();
			renderChildren = false;
			
			requiredAttribute = new Vector.<uint>;
			requiredAttribute.push(VertexAttribute.POSITION);
			requiredAttribute.push(VertexAttribute.UV);
			requiredAttribute.push(VertexAttribute.NORMAL);
		}
		
		public function update(context3D:ContextProxy = null):void
		{
			var containerMatrix:Matrix3D = getPerfectWorldMatrix().clone();
			containerMatrix.invert();
			var unionMap:Dictionary = new Dictionary();
			for each(var mesh:Mesh in getChildren(false, true, Mesh))
			{
				var geom:Geometry = mesh.geometry;
				var matrix:Matrix3D = mesh.getPerfectWorldMatrix().clone();
				matrix.append(containerMatrix);
				var rawData:Vector.<Number> = matrix.rawData;
				
				var v1:Vector.<Number> = new Vector.<Number>;
				if (hasAttribute(VertexAttribute.NORMAL)) var v2:Vector.<Number> = geom.getVertices(VertexAttribute.NORMAL);
				if (hasAttribute(VertexAttribute.UV)) var v3:Vector.<Number> = geom.getVertices(VertexAttribute.UV);
				if (hasAttribute(VertexAttribute.VERTEXCOLOR)) var v4:Vector.<Number> = geom.getVertices(VertexAttribute.VERTEXCOLOR);
				if (hasAttribute(VertexAttribute.TANGENT4)) var v5:Vector.<Number> = geom.getVertices(VertexAttribute.TANGENT4);
				matrix.transformVectors(geom.getVertices(VertexAttribute.POSITION), v1);
				
				var numSurfaces:int = mesh.surfaces.length;
				for (var i:int = 0; i < numSurfaces; i++) 
				{
					var surface:Surface = mesh.surfaces[i];
					var material:Material = surface._material;
					
					var data:UnionData = unionMap[material];
					if (data == null) data = unionMap[material] = new UnionData(material);
					
					var indexCache:Object = { };
					var indices:Vector.<uint> = geom.vertexIndices.concat().splice(surface.firstIndex, surface.numTriangles * 3);
					var numIndices:int = indices.length;
					for (var iv:int = 0; iv < numIndices; iv++)
					{
						var index:int = indices[iv];
						if (indexCache[index] !== undefined)
						{
							data.vertexIndices.push(indexCache[index]);
							continue;
						}
						indexCache[index] = data.vertexCount;
						data.vertexIndices.push(indexCache[index]);
						data.vertexCount++;
						
						
						if (hasAttribute(VertexAttribute.POSITION))
						{
							data.vertex.push(v1[index * 3], v1[index * 3 + 1], v1[index * 3 + 2]);
						}
						if (hasAttribute(VertexAttribute.NORMAL))
						{
							var nx1:Number = v2[index * 3];
							var ny1:Number = v2[index * 3 + 1];
							var nz1:Number = v2[index * 3 + 2];
							var nx2:Number = rawData[0] * nx1 + rawData[4] * ny1 + rawData[8]  * nz1;
							var ny2:Number = rawData[1] * nx1 + rawData[5] * ny1 + rawData[9]  * nz1;
							var nz2:Number = rawData[2] * nx1 + rawData[6] * ny1 + rawData[10] * nz1;
							data.normal.push(nx2, ny2, nz2);
						}
						if (hasAttribute(VertexAttribute.UV))
						{
							data.uv.push(v3[index * 2], v3[index * 2 + 1]);
						}
						if (hasAttribute(VertexAttribute.VERTEXCOLOR))
						{
							data.color.push(v4[index * 4], v4[index * 4 + 1], v4[index * 4 + 2], v4[index * 4 + 3]);
						}
						if (hasAttribute(VertexAttribute.TANGENT4))
						{
							data.tangent4.push(v5[index * 4], v5[index * 4 + 1], v5[index * 4 + 2], v5[index * 4 + 3]);
						}
					}
				}
			}
			
			var vertexIndices:Vector.<uint> = new Vector.<uint>;
			var vertices:Vector.<Number> = new Vector.<Number>;
			var normals:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>;
			var colors:Vector.<Number> = new Vector.<Number>;
			var tangent4s:Vector.<Number> = new Vector.<Number>;
			
			surfaces.length = 0;
			var firstIndex:int = 0;
			var totalCount:int = 0;
			for (var key:* in unionMap) 
			{
				var union:UnionData = unionMap[key];
				var numVertex:int = union.vertexIndices.length;
				surfaces.push(new Surface(union.material, firstIndex, numVertex / 3));
				firstIndex += numVertex;
				
				union.offsetVertexIndices(totalCount);
				vertexIndices = vertexIndices.concat(union.vertexIndices);
				totalCount += union.vertexCount
				
				if (hasAttribute(VertexAttribute.POSITION)) vertices = vertices.concat(union.vertex);
				if (hasAttribute(VertexAttribute.NORMAL)) normals = normals.concat(union.normal);
				if (hasAttribute(VertexAttribute.UV)) uvs = uvs.concat(union.uv);
				if (hasAttribute(VertexAttribute.VERTEXCOLOR)) colors = colors.concat(union.color);
				if (hasAttribute(VertexAttribute.TANGENT4)) tangent4s = tangent4s.concat(union.tangent4);
			}
			
			geometry.vertexIndices = vertexIndices;
			if (hasAttribute(VertexAttribute.POSITION)) geometry.addVertices(VertexAttribute.POSITION, 3, vertices);
			if (hasAttribute(VertexAttribute.VERTEXCOLOR)) geometry.addVertices(VertexAttribute.VERTEXCOLOR, 4, colors);
			if (hasAttribute(VertexAttribute.UV)) geometry.addVertices(VertexAttribute.UV, 2, uvs);
			if (hasAttribute(VertexAttribute.NORMAL)) geometry.addVertices(VertexAttribute.NORMAL, 3, normals);
			if (hasAttribute(VertexAttribute.TANGENT4)) geometry.addVertices(VertexAttribute.TANGENT4, 4, tangent4s);
			geometry.isUploaded = false;
			
			if (context3D)
			{
				upload(context3D, false, false);
			}
		}
		
		private function hasAttribute(type:int):Boolean 
		{
			return requiredAttribute.indexOf(type) != -1;
		}
		
		override public function getResources(hierarchy:Boolean, filter:Class = null):Vector.<Resource> 
		{
			if (filter == null)
			{
				filter = Resource;
			}
			
			var result:Vector.<Resource> = new Vector.<Resource>;
			if (_geometry)
			{
				if (_geometry is CombinedGeometry)
				{
					for each(var geometryItem:Geometry in CombinedGeometry(_geometry).geometries)
					{
						if (geometryItem is filter) result.push(geometryItem);
					}
				}
				else if (_geometry is filter)
				{
					result.push(_geometry);
				}
			}
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var material:Material = surfaces[i]._material;
				if (material)
				{
					var resourceList:Vector.<Resource> = material.getResources();
					var numResource:int = resourceList.length;
					for (var j:int = 0; j < numResource; j++) 
					{
						var resource:Resource = resourceList[j];
						if (resource is filter)
						{
							result.push(resource);
						}
					}
				}
			}
			return result;
		}
		
		override public function clone():Object3D 
		{
			var result:UnionMesh = new UnionMesh();
			cloneProperties(result);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				result.addChild(current.clone());
			}
			return result;
		}
		
		override public function reference():Object3D 
		{
			var result:UnionMesh = new UnionMesh();
			referenceProperties(result);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				result.addChild(current.reference());
			}
			return result;
		}
		
		static public function create(object:Object3D):UnionMesh 
		{
			var union:UnionMesh = new UnionMesh();
			union.matrix = object.matrix;
			object.parent.addChild(union);
			while(object.children) 
			{
				union.addChild(object.children);
			}
			object.remove();
			
			union.update(null);
			union.calculateBounds();
			
			return union;
		}
		
	}

}