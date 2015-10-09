package net.morocoshi.moja3d.loader.optimize 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.loader.geometries.M3DCombinedGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.M3DScene;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	import net.morocoshi.moja3d.loader.objects.M3DLine;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;
	import net.morocoshi.moja3d.loader.objects.M3DObject;
	import net.morocoshi.moja3d.loader.objects.M3DSkin;
	
	/**
	 * 同一マテリアルのサーフェイスを統合する
	 * 
	 * @author tencho
	 */
	public class SurfaceOptimizer 
	{
		
		public function SurfaceOptimizer() 
		{
			
		}
		
		public function optimize(scene:M3DScene):void 
		{
			var i:int;
			var n:int;
			
			//使用しているジオメトリリスト（最適化スキップしたもの+最適化した新しいジオメトリになる）
			var usedGeomList:Vector.<M3DGeometry> = new Vector.<M3DGeometry>;
			var deleteGeomList:Vector.<M3DGeometry> = new Vector.<M3DGeometry>;
			var deleteObjectList:Vector.<M3DGeometry> = new Vector.<M3DGeometry>;
			var geometryLink:Object = scene.getGeometryLink();
			var materialLink:Object = scene.getMaterialLink();
			var objectLink:Object = scene.getObjectLink();
			var optimizedGeometryLink:Dictionary = new Dictionary();
			
			var geomCount:int = scene.getGeometryLastID() + 1;
			var objectCount:int = scene.getObjectLastID() + 1;
			
			n = scene.objectList.length;
			for (i = 0; i < n; i++) 
			{
				var obj:M3DObject = scene.objectList[i];
				var mesh:M3DMesh = obj as M3DMesh;
				
				//メッシュでない場合スキップ
				if (mesh == null && !(obj is M3DLine)) continue;
				
				//アニメーションがある場合スキップ
				var skip:Boolean = false;
				var current:M3DObject = obj;
				while (current)
				{
					if (current.animation || current.userData.lock || current.userData.billboard)
					{
						skip = true;
						break;
					}
					current = objectLink[current.parent];
				}
				
				if (obj as M3DLine)
				{
					var lineGeom:M3DGeometry = geometryLink[M3DLine(obj).geometryID];
					VectorUtil.attachItemDiff(usedGeomList, lineGeom);
					continue;
				}
				
				if (mesh as M3DSkin)
				{
					var skinGeom:M3DGeometry = geometryLink[mesh.geometryID];
					VectorUtil.attachItemDiff(usedGeomList, skinGeom);
					if (skinGeom is M3DCombinedGeometry)
					{
						for each(var id:int in M3DCombinedGeometry(skinGeom).geometryIDList)
						{
							VectorUtil.attachItemDiff(usedGeomList, geometryLink[id]);
						}
					}
					continue;
				}
				
				var geom:M3DMeshGeometry = geometryLink[mesh.geometryID] as M3DMeshGeometry;
				if (skip)
				{
					//スキップしたジオメトリはリストに入れておく
					VectorUtil.attachItemDiff(usedGeomList, geom);
					continue;
				}
				
				//メッシュを統合していく
				var matrix:Matrix3D = getWorldMatrix(obj, objectLink);
				obj.matrix = matrix.rawData;
				obj.parent = -1;
				
				VectorUtil.deleteItem(scene.objectList, obj);
				i--;
				n--;
				
				var numSurface:int = mesh.surfaceList.length;
				for (var s:int = 0; s < numSurface; s++) 
				{
					var surface:M3DSurface = mesh.surfaceList[s];
					var material:M3DMaterial = materialLink[surface.material];
					var optimizedGeom:OptimizedGeometry = getOptimizedGeometry(optimizedGeometryLink, material, mesh, surface);
					optimizedGeom.attach(geom, matrix, surface.indexBegin, surface.numTriangle);
				}
			}
			
			for each(var item:OptimizedGeometry in optimizedGeometryLink) 
			{
				geomCount++;
				objectCount++;
				
				var meshGeom:M3DMeshGeometry = item.toGeometry();
				meshGeom.id = geomCount;
				var position:Vector3D = meshGeom.fixBasePoint();
				usedGeomList.push(meshGeom);
				var mesh3d:M3DMesh = new M3DMesh();
				mesh3d.geometryID = meshGeom.id;
				mesh3d.id = objectCount;
				mesh3d.matrix = new <Number>[1,0,0,0,0,1,0,0,0,0,1,0,position.x,position.y,position.z,1];
				mesh3d.name = item.baseMesh.name;
				mesh3d.visible = item.baseMesh.visible;
				mesh3d.userData = item.baseMesh.userData;
				mesh3d.parent = -1;
				mesh3d.animationID = mesh3d.name;
				mesh3d.userData = item.userData;
				mesh3d.surfaceList = new Vector.<M3DSurface>;
				
				var meshSurface:M3DSurface = new M3DSurface();
				meshSurface.indexBegin = 0;
				meshSurface.numTriangle = item.numTriangle;
				meshSurface.material = item.material.id;
				meshSurface.hasTransparentVertex = item.surface.hasTransparentVertex;
				mesh3d.surfaceList.push(meshSurface);
				
				scene.objectList.push(mesh3d);
			}
			
			//geometryListを使ったものだけにする
			scene.geometryList.length = 0;
			VectorUtil.attachList(scene.geometryList, usedGeomList);
		}
		
		/**
		 * 
		 * @param	material
		 * @return
		 */
		private function getOptimizedGeometry(link:Dictionary, material:M3DMaterial, mesh:M3DMesh, surface:M3DSurface):OptimizedGeometry 
		{
			var key:String = material.getKey() + "/" + mesh.getKey() + "/" + surface.getKey();
			if (link[key] == undefined)
			{
				var geom:OptimizedGeometry = link[key] = new OptimizedGeometry();
				geom.material = material;
				geom.baseMesh = mesh;
				geom.surface = surface;
				geom.userData = mesh.userData;
			}
			return link[key];
		}
		
		private function getWorldMatrix(obj:M3DObject, objectLink:Object):Matrix3D 
		{
			var current:M3DObject = obj;
			var matrix:Matrix3D = new Matrix3D();
			while (current)
			{
				matrix.append(new Matrix3D(current.matrix));
				if (current.parent == -1)
				{
					break;
				}
				current = objectLink[current.parent];
			}
			return matrix;
		}
		
	}

}