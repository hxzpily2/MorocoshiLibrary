package net.morocoshi.moja3d.loader 
{
	import flash.utils.Dictionary;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.agal.AGALInfo;
	import net.morocoshi.moja3d.loader.animation.M3DAnimation;
	import net.morocoshi.moja3d.loader.geometries.M3DCombinedGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DSkinGeometry;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.loader.objects.M3DBone;
	import net.morocoshi.moja3d.loader.objects.M3DCamera;
	import net.morocoshi.moja3d.loader.objects.M3DLayer;
	import net.morocoshi.moja3d.loader.objects.M3DLight;
	import net.morocoshi.moja3d.loader.objects.M3DLine;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;
	import net.morocoshi.moja3d.loader.objects.M3DObject;
	import net.morocoshi.moja3d.loader.objects.M3DSkin;
	import net.morocoshi.moja3d.loader.optimize.GeometrySplitter;
	import net.morocoshi.moja3d.loader.optimize.M3DFaseSet;
	import net.morocoshi.moja3d.loader.optimize.SurfaceOptimizer;
	
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
		 * 空っぽのオブジェクトを削除する
		 */
		public function removeEmptyObject(lockUserPropertyObject:Boolean, lockSkinEmptyObject:Boolean):void
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
				var lock:Boolean = (obj.animation != null) || obj.userData.lock || (obj.hasUserData && lockUserPropertyObject);
				if (lock || obj is M3DLight || obj is M3DMesh || obj is M3DCamera || obj is M3DLine || obj is M3DBone)
				{
					var current:M3DObject = obj;
					while (current)
					{
						existLink[current] = true;
						current = objectLink[current.parent];
					}
				}
				else if (lockSkinEmptyObject)
				{
					var current2:M3DObject = obj;
					while (current2)
					{
						if (current2 is M3DSkin)
						{
							existLink[obj] = true;
							break;
						}
						current2 = objectLink[current2.parent];
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
			new SurfaceOptimizer().optimize(this);
		}
		
		public function getGeometryLastID():int
		{
			var result:int = -1;
			for each(var item:M3DGeometry in geometryList)
			{
				if (item.id > result) result = item.id;
			}
			return result;
		}
		
		public function getObjectLastID():int 
		{
			var result:int = -1;
			for each(var item:M3DObject in objectList)
			{
				if (item.id > result) result = item.id;
			}
			return result;
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
			var object:M3DObject;
			for each(object in objectList)
			{
				if (object.animation)
				{
					var key:String = object.animationID || object.name;
					animation[key] = object.animation;
				}
			}
			var n:int = objectList.length;
			for (var i:int = 0; i < n; i++) 
			{
				object = objectList[i].toM3DObject3D();
				objectList[i] = object;
				if (object is M3DBone && object.animation == null)
				{
					object.animation = new M3DAnimation();
					object.animation.type = M3DAnimation.TYPE_MOTIONLESS_MATRIX;
					object.animation.defaultMatrix = object.matrix.concat();
					animation[object.animationID] = object.animation;
				}
			}
			geometryList.length = 0;
			materialList.length = 0;
		}
		
		/**
		 * 頂点数が限界突破しているジオメトリを分割する
		 */
		public function splitMeshGeometry():void 
		{
			for each(var obj:M3DObject in objectList)
			{
				if (obj is M3DSkin) continue;
				var mesh:M3DMesh = obj as M3DMesh;
				if (mesh == null) continue;
				
				var rawGeometry:M3DMeshGeometry = getGeometryLink()[mesh.geometryID];
				trace("----", rawGeometry.vertices.length / 3);
				if (rawGeometry.vertices.length / 3 <= AGALInfo.VERTEXDATA_LIMIT) continue;
				
				//メッシュの分割
				var splitted:Vector.<M3DFaseSet> = new GeometrySplitter().getSplittedMeshGeometries(rawGeometry, mesh);
				//分割数1なら分割する必要なし
				if (splitted.length == 1)
				{
					//continue;
				}
				
				var combined:M3DCombinedGeometry = new M3DCombinedGeometry();
				var n:int = splitted.length;
				mesh.surfacesList = [];
				for (var i:int = 0; i < n; i++) 
				{
					var faseSet:M3DFaseSet = splitted[i];
					var geometryID:int = addGeometry(faseSet.geometry);
					combined.geometryIDList.push(geometryID);
					mesh.surfacesList.push(faseSet.surfaces);
				}
				
				removeGeometry(rawGeometry);
				mesh.geometryID = addGeometry(combined);
			}
		}
		
		/**
		 * 全てのスキンジオメトリをボーン数限界に収まるように分割する
		 * @param	boneLimit　1ジオメトリが持てるボーンの数
		 */
		public function splitSkinGeometry(boneLimit:int):void 
		{
			for each(var obj:M3DObject in objectList)
			{
				var skin:M3DSkin = obj as M3DSkin;
				if (skin == null) continue;
				var rawGeometry:M3DSkinGeometry = getGeometryLink()[skin.geometryID];
				
				//スキンメッシュの分割
				var splitted:Vector.<M3DFaseSet> = new GeometrySplitter().getSplittedSkinGeometries(rawGeometry, skin, boneLimit);
				//分割数1なら分割する必要なし
				if (splitted.length == 1)
				{
					continue;
				}
				
				var combined:M3DCombinedGeometry = new M3DCombinedGeometry();
				var n:int = splitted.length;
				skin.surfacesList = [];
				for (var i:int = 0; i < n; i++) 
				{
					var faseSet:M3DFaseSet = splitted[i];
					var geometryID:int = addGeometry(faseSet.geometry);
					combined.geometryIDList.push(geometryID);
					skin.surfacesList.push(faseSet.surfaces);
				}
				
				removeGeometry(rawGeometry);
				skin.geometryID = addGeometry(combined);
			}
		}
		
		public function removeGeometry(value:M3DGeometry):Boolean 
		{
			var index:int = geometryList.indexOf(value);
			if (index == -1) return false;
			geometryList.splice(index, 1);
			return true;
		}
		
		public function addGeometry(value:M3DGeometry):int 
		{
			if (geometryList.indexOf(value) != -1) return value.id;
			
			value.id = getGeometryLastID() + 1;
			geometryList.push(value);
			return value.id;
		}
		
		/**
		 * 最後にデータをまとめる
		 */
		public function prepare():void 
		{
			for each(var geom:M3DGeometry in geometryList)
			{
				var skinGeom:M3DSkinGeometry = geom as M3DSkinGeometry;
				if (skinGeom)
				{
					skinGeom.fixJointIndex();
				}
			}
		}
		
	}

}