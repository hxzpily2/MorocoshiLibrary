package net.morocoshi.moja3d.loader.optimize 
{
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.loader.geometries.M3DSkinGeometry;
	import net.morocoshi.moja3d.loader.M3DScene;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;
	import net.morocoshi.moja3d.loader.objects.M3DObject;
	/**
	 * ...
	 * @author tencho
	 */
	public class SkinSplitter 
	{
		public function SkinSplitter() 
		{
		}
		
		public function getSplittedGeometries(geom:M3DSkinGeometry, mesh:M3DMesh, boneLimit:int):Vector.<M3DFaseSet> 
		{
			var surfaces:Vector.<M3DSurface> = mesh.surfaceList;
			
			var i:int;
			var j:int;
			var n:int;
			var m:int;
			
			//ポリゴンリスト
			var faces:Vector.<M3DFace> = new Vector.<M3DFace>;
			n = geom.vertexIndices.length / 3;
			for (i = 0; i < n; i++)
			{
				faces.push(new M3DFace());
			}
			
			//ポリゴンに頂点情報を渡す
			n = geom.vertexIndices.length;
			for (i = 0; i < n; i++)
			{
				var index:int = geom.vertexIndices[i];
				var v:M3DVertex = new M3DVertex();
				if (geom.uvs)			v.uv		 	= [geom.uvs			[index * 2], geom.uvs			[index * 2 + 1]];
				if (geom.vertices)		v.vertex	 	= [geom.vertices	[index * 3], geom.vertices		[index * 3 + 1], geom.vertices		[index * 3 + 2]];
				if (geom.normals)		v.normal	 	= [geom.normals		[index * 3], geom.normals		[index * 3 + 1], geom.normals		[index * 3 + 2]];
				if (geom.colors)		v.color		 	= [geom.colors		[index * 4], geom.colors		[index * 4 + 1], geom.colors		[index * 4 + 2], geom.colors		[index * 4 + 3]];
				if (geom.tangents)		v.tangent4		= [geom.tangents	[index * 4], geom.tangents		[index * 4 + 1], geom.tangents		[index * 4 + 2], geom.tangents		[index * 4 + 3]];
				if (geom.weights1)		v.weight1		= [geom.weights1	[index * 4], geom.weights1		[index * 4 + 1], geom.weights1		[index * 4 + 2], geom.weights1		[index * 4 + 3]];
				if (geom.weights2)		v.weight2		= [geom.weights2	[index * 4], geom.weights2		[index * 4 + 1], geom.weights2		[index * 4 + 2], geom.weights2		[index * 4 + 3]];
				if (geom.boneIndices1)	v.boneIndex1	= [geom.boneIndices1[index * 4], geom.boneIndices1	[index * 4 + 1], geom.boneIndices1	[index * 4 + 2], geom.boneIndices1	[index * 4 + 3]];
				if (geom.boneIndices2)	v.boneIndex2	= [geom.boneIndices2[index * 4], geom.boneIndices2	[index * 4 + 1], geom.boneIndices2	[index * 4 + 2], geom.boneIndices2	[index * 4 + 3]];
				
				faces[int(i / 3)].addVertex(v);
			}
			
			//サーフェイス情報から各ポリゴンにマテリアルIDを渡す
			n = surfaces.length;
			var count:int = -1;
			for (i = 0; i < n; i++)
			{
				m = surfaces[i].numTriangle;
				for (j = 0; j < m; j++)
				{
					count++;
					faces[count].material = surfaces[i].material;
				}
			}
			
			//三角ポリゴンの一番ジョイントINDEXの小さい値でソート
			//※なぜかソートすると結果が変わってしまう。。。
			//faces.sort(sortFunc)
			
			//ポリゴンが消えるまでメッシュに統合していく
			var faseSetList:Vector.<M3DFaseSet> = new Vector.<M3DFaseSet>;
			while (faces.length)
			{
				var faseSet:M3DFaseSet = new M3DFaseSet();
				faseSetList.push(faseSet);
				n = faces.length;
				for (i = 0; i < n; i++)
				{
					if (faseSet.add(faces[i], boneLimit))
					{
						faces.splice(i, 1);
						i--;
						n--;
					}
				}
			}
			
			for each (var item:M3DFaseSet in faseSetList) 
			{
				item.fix();
			}
			
			return faseSetList;
		}
		
		private function sortFunc(a:M3DFace, b:M3DFace):int 
		{
			return int(a.minIndex > b.minIndex) - int(a.minIndex < b.minIndex);
		}
		
	}

}