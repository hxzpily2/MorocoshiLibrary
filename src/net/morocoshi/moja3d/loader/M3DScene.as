package net.morocoshi.moja3d.loader 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.loader.geometries.M3DGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	import net.morocoshi.moja3d.loader.objects.M3DBone;
	import net.morocoshi.moja3d.loader.objects.M3DCamera;
	import net.morocoshi.moja3d.loader.objects.M3DLayer;
	import net.morocoshi.moja3d.loader.objects.M3DLight;
	import net.morocoshi.moja3d.loader.objects.M3DLine;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;
	import net.morocoshi.moja3d.loader.objects.M3DObject;
	import net.morocoshi.moja3d.loader.optimize.OptimizedGeometry;
	
	/**
	 * M3Dシーンデータ
	 * 
	 * @author tencho
	 */
	public class M3DScene 
	{
		/**このM3Dがアニメーションだけを保存したデータかどうか*/
		public var isAnimation:Boolean;
		/**バージョン*/
		public var version:Number;
		/**Object3Dリスト*/
		public var objectList:Vector.<M3DObject>;
		/**Meshジオメトリリスト*/
		public var geometryList:Vector.<M3DGeometry>;
		/**マテリアルリスト*/
		public var materialList:Vector.<M3DMaterial>;
		/**レイヤーリスト*/
		public var layerList:Vector.<M3DLayer>;
		/**モーションデータの場合、オブジェクト名をkeyに持つ*/
		public var animation:Object;
		
		public function M3DScene() 
		{
		}
		
		/**
		 * アニメーションの数を取得する。毎回全オブジェクトとanimationを走査するので注意。
		 */
		public function get numAnimation():int
		{
			var result:int = 0;
			
			var n:int = objectList.length;
			for (var i:int = 0; i < n; i++) 
			{
				result += int(objectList[i].animation);
			}
			
			if (animation)
			{
				for (var key:String in animation)
				{
					result++;
				}
			}
			
			return result;
		}
		
		/**
		 * マテリアルファイル名（フォルダ無し＆拡張子付）のリストを取得
		 * @return
		 */
		public function getAllMaterialFileName():Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>;
			
			var n:int = materialList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var material:M3DMaterial = materialList[i];
				if (material.diffusePath) result.push(fixFilePath(material.diffusePath));
				if (material.opacityPath) result.push(fixFilePath(material.opacityPath));
				if (material.normalPath) result.push(fixFilePath(material.normalPath));
				if (material.reflectionPath) result.push(fixFilePath(material.reflectionPath));
			}
			
			return result;
		}
		
		/**
		 * 
		 * @param	path
		 * @return
		 */
		private function fixFilePath(path:String):String
		{
			return path.split("\\").join("/");
		}
		
		public function getMaterialByKey(key:String):M3DMaterial 
		{
			var n:int = materialList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var material:M3DMaterial = materialList[i];
				if (material.getKey() == key) return material;
			}
			return null;
		}
		
		public function getAnimationID(object:M3DObject):String 
		{
			var target:M3DObject = object;
			var list:Array = [];
			while (target)
			{
				var name:String = target.animationID || target.name;
				list.push(name);
				target = (target.parent >= 0)? objectList[target.parent] : null;
			}
			list.reverse();
			return list.join("/");
		}
		
		/**
		 * 空のオブジェクトを削除する
		 */
		public function removeEmptyObject(lockUserPropertyObject:Boolean):void
		{
			var i:int;
			var n:int;
			
			var existLink:Dictionary = new Dictionary();
			var objectLink:Object = getObjectLink();
			var obj:M3DObject;
			
			n = objectList.length;
			for (i = 0; i < n; i++) 
			{
				obj = objectList[i];
				var lock:Boolean = obj.userData.lock || (obj.hasUserData && lockUserPropertyObject);
				if (lock || obj is M3DLight || obj is M3DMesh || obj is M3DCamera || obj is M3DLine || obj is M3DBone)
				{
					var current:M3DObject = obj;
					while (current)
					{
						existLink[current] = true;
						current = objectLink[current.parent];
					}
				}
			}
			
			for (i = 0; i < n; i++) 
			{
				obj = objectList[i];
				if (!existLink[obj])
				{
					VectorUtil.deleteItem(objectList, obj);
					i--;
					n--;
				}
			}
		}
		
		/**
		 * 同じマテリアルのサーフェイスを統合して最適化する
		 */
		public function optimize():void 
		{
			var i:int;
			var n:int;
			
			//使用しているジオメトリリスト（最適化スキップしたもの+最適化した新しいジオメトリになる）
			var usedGeomList:Vector.<M3DGeometry> = new Vector.<M3DGeometry>;
			var deleteGeomList:Vector.<M3DGeometry> = new Vector.<M3DGeometry>;
			var deleteObjectList:Vector.<M3DGeometry> = new Vector.<M3DGeometry>;
			var geometryLink:Object = getGeometryLink();
			var materialLink:Object = getMaterialLink();
			var objectLink:Object = getObjectLink();
			var optimizedGeometryLink:Dictionary = new Dictionary();
			
			var geomCount:int = geometryList.length + 1;
			var objectCount:int = objectList.length + 1;
			
			n = objectList.length;
			for (i = 0; i < n; i++) 
			{
				var obj:M3DObject = objectList[i];
				var mesh:M3DMesh = obj as M3DMesh;
				
				//メッシュでない場合スキップ
				if (mesh == null) continue;
				
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
				
				VectorUtil.deleteItem(objectList, obj);
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
				
				objectList.push(mesh3d);
			}
			
			//geometryListを使ったものだけにする
			geometryList.length = 0;
			VectorUtil.attachList(geometryList, usedGeomList);
		}
		
		/**
		 * M3DMaterialをIDで取得するための検索用オブジェクトを生成。
		 * @param	id
		 * @return
		 */
		public function getMaterialLink():Object 
		{
			var materialLink:Object = { };
			
			var n:int = materialList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:M3DMaterial = materialList[i];
				materialLink[item.id] = item;
			}
			
			return materialLink;
		}
		
		/**
		 * M3DGeometryをIDで取得するための検索用オブジェクトを生成。
		 * @return
		 */
		public function getGeometryLink():Object
		{
			var geometryLink:Object = { };
			for each (var item:M3DGeometry in geometryList) 
			{
				geometryLink[item.id] = item;
			}
			return geometryLink;
		}
		
		/**
		 * M3dObjectをIDで取得するための検索用オブジェクトを生成。
		 * @return
		 */
		public function getObjectLink():Object 
		{
			var objectLink:Object = { };
			
			var n:int = objectList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:M3DObject = objectList[i];
				objectLink[item.id] = item;
			}
			
			return objectLink;
		}
		
		/**
		 * 全オブジェクトのアニメーション情報をanimation変数に集約し、アニメーション以外のデータを全削除する。
		 */
		public function setOnlyAnimation():void 
		{
			animation = { };
			for each(var object:M3DObject in objectList)
			{
				if (object.animation)
				{
					var key:String = object.animationID || object.name;
					animation[key] = object.animation;
				}
			}
			objectList.length = 0;
			geometryList.length = 0;
			materialList.length = 0;
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