package net.morocoshi.moja3d.loader.exporters 
{
	import flash.display.BlendMode;
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import net.morocoshi.common.loaders.fbx.animation.FBXAnimationCurve;
	import net.morocoshi.common.loaders.fbx.animation.FBXAnimationNode;
	import net.morocoshi.common.loaders.fbx.attributes.FBXCameraAttribute;
	import net.morocoshi.common.loaders.fbx.attributes.FBXLightAttribute;
	import net.morocoshi.common.loaders.fbx.bones.FBXBoneDeformer;
	import net.morocoshi.common.loaders.fbx.bones.FBXPose;
	import net.morocoshi.common.loaders.fbx.FBXLayer;
	import net.morocoshi.common.loaders.fbx.FBXScene;
	import net.morocoshi.common.loaders.fbx.geometries.FBXGeometry;
	import net.morocoshi.common.loaders.fbx.geometries.FBXLineGeometry;
	import net.morocoshi.common.loaders.fbx.geometries.FBXLineSegment;
	import net.morocoshi.common.loaders.fbx.geometries.FBXMeshGeometry;
	import net.morocoshi.common.loaders.fbx.materials.FBXMaterial;
	import net.morocoshi.common.loaders.fbx.materials.FBXSurface;
	import net.morocoshi.common.loaders.fbx.objects.FBXBone;
	import net.morocoshi.common.loaders.fbx.objects.FBXCamera;
	import net.morocoshi.common.loaders.fbx.objects.FBXLight;
	import net.morocoshi.common.loaders.fbx.objects.FBXLine;
	import net.morocoshi.common.loaders.fbx.objects.FBXMesh;
	import net.morocoshi.common.loaders.fbx.objects.FBXObject;
	import net.morocoshi.moja3d.loader.animation.M3DAnimation;
	import net.morocoshi.moja3d.loader.animation.M3DCurveTrack;
	import net.morocoshi.moja3d.loader.animation.M3DKeyframe;
	import net.morocoshi.moja3d.loader.animation.M3DTrackXYZ;
	import net.morocoshi.moja3d.loader.animation.TangentType;
	import net.morocoshi.moja3d.loader.geometries.M3DGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DLineGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DLineSegment;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.M3DParser;
	import net.morocoshi.moja3d.loader.M3DScene;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	import net.morocoshi.moja3d.loader.objects.M3DBillboard;
	import net.morocoshi.moja3d.loader.objects.M3DBone;
	import net.morocoshi.moja3d.loader.objects.M3DCamera;
	import net.morocoshi.moja3d.loader.objects.M3DLayer;
	import net.morocoshi.moja3d.loader.objects.M3DLight;
	import net.morocoshi.moja3d.loader.objects.M3DLine;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;
	import net.morocoshi.moja3d.loader.objects.M3DObject;
	import net.morocoshi.moja3d.loader.objects.M3DSkin;
	import net.morocoshi.moja3d.materials.Tiling;
	
	/**
	 * FBXSceneオブジェクトをM3Dデータに変換する
	 * 
	 * @author tencho
	 */
	public class M3DFBXExporter extends EventDispatcher
	{
		/**TextEvent*/
		static public const EVENT_LOG:String = "log";
		
		private var option:M3DExportOption;
		private var scene:M3DScene;
		
		private var idCount:int = 0;
		private var materialM3DLink:Dictionary;
		private var objectM3DLink:Dictionary;
		private var objectFBXLink:Dictionary;
		private var activeMaterial:Dictionary;
		private var m3dGeomLink:Dictionary;
		private var offsetLink:Dictionary;
		private var parentM3DLink:Dictionary;
		private var fbxScene:FBXScene;
		private var fbxBoneLink:Dictionary;
		//private var lowLV:int;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function M3DFBXExporter() 
		{
			m3dGeomLink = new Dictionary();
			offsetLink = new Dictionary();
			parentM3DLink = new Dictionary();
			fbxBoneLink = new Dictionary();
		}
		
		//--------------------------------------------------------------------------
		//
		//  FBXからM3D書き出し
		//
		//--------------------------------------------------------------------------
		
		/**
		 * FBXSceneオブジェクトから必要な情報だけ抜き出してM3DScene化
		 * @param	fbx
		 * @param	option
		 * @param	animationData
		 * @return
		 */
		public function convert(fbx:FBXScene, option:M3DExportOption, animationData:ByteArray):M3DScene
		{
			this.option = option;
			this.fbxScene = fbx;
			M3DParser.registClasses();
			
			//lowLV = Math.pow(10, option.lowNumber);
			materialM3DLink = new Dictionary();
			objectM3DLink = new Dictionary();
			objectFBXLink = new Dictionary();
			parentM3DLink = new Dictionary();
			activeMaterial = new Dictionary();
			
			scene = new M3DScene();
			scene.version = M3DParser.VERSION;
			scene.materialList = new Vector.<M3DMaterial>;
			scene.objectList = new Vector.<M3DObject>;
			scene.geometryList = new Vector.<M3DGeometry>;
			
			var materialCount:int = 0;
			var i:int;
			var n:int;
			
			var animation:M3DParser;
			//アニメーションデータのパース（あれば）
			if (animationData)
			{
				animation = new M3DParser();
				animation.bezierCurveInterval = 1.0 / 15;
				animation.parse(animationData);
			}
			
			//マテリアル
			var fbxMaterials:Vector.<FBXMaterial> = fbx.getAllMaterialList();
			for (i = 0; i < fbxMaterials.length; i++) 
			{
				var materialFBX:FBXMaterial = fbxMaterials[i];
				var materialM3D:M3DMaterial = toM3DMaterial(materialFBX);
				var exsistMaterial:M3DMaterial = scene.getMaterialByKey(materialM3D.getKey());
				if (!exsistMaterial)
				{
					materialM3D.id = ++materialCount;
					scene.materialList.push(materialM3D);
				}
				else
				{
					materialM3D = exsistMaterial;
				}
				materialM3DLink[materialFBX] = materialM3D;
			}
			
			//ジオメトリ
			n = fbx.geometryList.length;
			for (i = 0; i < n; i++) 
			{
				var geomFBX:FBXGeometry = fbx.geometryList[i];
				var geomM3D:M3DGeometry = toM3DGeometry(geomFBX, animation, scene);
				geomM3D.id = i;
				m3dGeomLink[geomFBX] = geomM3D;
			}
			
			//レイヤー
			var layerFBX:FBXLayer;
			var layerM3D:M3DLayer;
			
			n = fbx.layers.length;
			for (i = 0; i < n; i++) 
			{
				layerFBX = fbx.layers[i];
				trace(layerFBX.name, layerFBX.id);
			}
			
			//オブジェクト
			var objFBX:FBXObject;
			var objM3D:M3DObject;
			
			n = fbx.objectList.length;
			for (i = 0; i < n; i++) 
			{
				objFBX = fbx.objectList[i];
				//非表示レイヤーを含めないかどうか
				if (!option.useHideLayer && !objFBX.layer.visible) continue;
				//フリーズレイヤーを含めないかどうか
				if (!option.useFreezeLayer && objFBX.layer.freeze) continue;
				//空のオブジェクトを全て削除するか
				/*
				if (option.deleteEmptyObject && objFBX.empty)
				{
					var lock:Boolean = objFBX.getUserData("lock", false);
					if (lock == false && !(objFBX.hasUserData && option.lockUserPropertyObject))
					{
						continue;
					}
				}
				*/
				//ライトを削除するか
				if (option.exportLight == false && objFBX is FBXLight) continue;
				if (option.exportCamera == false && objFBX is FBXCamera) continue;
				
				objM3D = toM3DObject(objFBX);
				objectM3DLink[objFBX] = objM3D;
				objectFBXLink[objM3D] = objFBX;
				scene.objectList.push(objM3D);
			}
			
			//___ここでボーンをPOSEの姿勢にしてるけどおかしい
			for each(var pose:FBXPose in fbx.poseList)
			{
				var poseObject:M3DObject = objectM3DLink[fbx.getObjectByID(pose.nodeID)];
				if (poseObject is M3DSkin || 1)
				{
					poseObject.matrix = pose.matrix;
				}
			}
			
			//不用マテリアル削除
			n = scene.materialList.length;
			var removeMaterialList:Array = [];
			for (i = 0; i < n; i++) 
			{
				var mt:M3DMaterial = scene.materialList[i];
				if (!activeMaterial[mt]) removeMaterialList.push(i);
			}
			while (removeMaterialList.length)
			{
				i = removeMaterialList.pop();
				scene.materialList.splice(i, 1);
			}
			
			//親子関係と階層移動
			var parentM3D:M3DObject;
			n = scene.objectList.length;
			for (i = 0; i < n; i++) 
			{
				objM3D = scene.objectList[i];
				objFBX = objectFBXLink[objM3D];
				
				if (!option.useHideLayer && !objFBX.layer.visible) continue;
				if (!objFBX.parent) continue;
				
				var needMoveToRoot:Boolean = false;
				
				parentM3D = objectM3DLink[objFBX.parent];
				//親のM3Dへのリンクを保存しておく（ID設定用）
				parentM3DLink[objM3D] = parentM3D;
				if (parentM3D)
				{
					//objM3D.parent = parentM3D.id;
					var parentFBX:FBXObject = objectFBXLink[parentM3D];
					if (parentFBX.offset)
					{
						offsetM3D(objM3D, parentFBX.offset);
					}
					//階層移動が可能かチェック
					needMoveToRoot = checkMovableObject(objFBX, animation);
					if (!needMoveToRoot && option.moveToRoot)
					{
						//log("[階層移動不可]" + objM3D.name + "は階層を動かせません");
					}
				}
				else
				{
					//親が非表示レイヤーに含まれている等で存在しない場合は
					//自分をルート階層に移動させる
					moveToRoot(objM3D);
				}
				
				//必要ならルート階層に移動させる
				if (needMoveToRoot && option.moveToRoot)
				{
					moveToRoot(objM3D);
				}
			}
			
			//一時検索用にスキンのリストをまとめる
			var boneDeformersLink:Dictionary = new Dictionary();
			for (i = 0; i < scene.objectList.length; i++) 
			{
				objM3D = scene.objectList[i];
				objFBX = objectFBXLink[objM3D];
				var mesh:FBXMesh = objFBX as FBXMesh;
				if (mesh)
				{
					var geom:FBXMeshGeometry = mesh.geometry as FBXMeshGeometry;
					if (geom && geom.skin)
					{
						boneDeformersLink[objM3D] = geom.skin.boneList;
					}
				}
			}
			
			//ボーン移動
			var boneList:Vector.<M3DBone> = new Vector.<M3DBone>;
			for (i = 0; i < scene.objectList.length; i++) 
			{
				objM3D = scene.objectList[i];
				objFBX = objectFBXLink[objM3D];
				if (objM3D is M3DBone)
				{
					boneList.push(objM3D as M3DBone);
					var existParentBone:Boolean = false;
					var current:FBXObject = objFBX.parent;
					while (current)
					{
						if (current is FBXBone)
						{
							existParentBone = true;
							break;
						}
						current = current.parent;
					}
					//親にボーンがなければ最上位判定
					if (existParentBone == false)
					{
						var fbxBone:FBXBone = objFBX as FBXBone;
						var itemList:Array = [fbxBone];
						var def:FBXBoneDeformer;// = fbxBone.deformer;
						while (itemList.length)
						{
							var boneCurrent:FBXObject = itemList.pop();
							if (boneCurrent && FBXBone(boneCurrent).deformer)
							{
								def = FBXBone(boneCurrent).deformer;
								break;
							}
							for each(var child:FBXObject in boneCurrent.children)
							{
								itemList.push(child);
							}
						}
						
						for (var skin:* in boneDeformersLink) 
						{
							if (boneDeformersLink[skin].indexOf(def) != -1)
							{
								addChildToSkin(skin, objM3D as M3DBone);
							}
						}
					}
				}
			}
			
			//空っぽかどうかの事前設定
			var existLink:Dictionary = new Dictionary();
			for (i = 0; i < scene.objectList.length; i++) 
			{
				objM3D = scene.objectList[i];
				if (isContainer(objM3D))
				{
					continue;
				}
				//自分の全ての親を辿り、空っぽではない事を設定しておく
				var target:M3DObject = objM3D;
				while (target)
				{
					existLink[target] = true;
					target = getParent(target);
				}
			}
			
			//空っぽのObjectを全削除
			if (option.deleteEmptyObject)
			{
				for (i = 0; i < scene.objectList.length; i++)
				{
					objM3D = scene.objectList[i];
					if (!existLink[objM3D])
					{
						if (!objM3D.userData.lock && !(objM3D.hasUserData && option.lockUserPropertyObject))
						{
							scene.objectList.splice(i, 1);
							i--;
						}
					}
				}
			}
			
			//リストのM3DObjectにid一括指定
			idCount = 0;
			for (i = 0; i < scene.objectList.length; i++)
			{
				idCount++;
				objM3D = scene.objectList[i];
				objM3D.id = idCount;
			}
			
			//親idの設定
			for (i = 0; i < scene.objectList.length; i++) 
			{
				objM3D = scene.objectList[i];
				parentM3D = getParent(objM3D);
				objM3D.parent = parentM3D? parentM3D.id : -1;
			}
			
			//環境光
			if (fbx.global.ambientColor && option.exportLight)
			{
				var ambient:M3DLight = new M3DLight();
				ambient.type = M3DLight.AMBIENT;
				ambient.color = fbx.global.ambientColor;
				ambient.intensity = 1;
				scene.objectList.push(ambient);
			}
			
			//アニメーションのみの場合
			if (option.exportAnimation && !option.exportModel)
			{
				scene.setOnlyAnimation();
			}
			
			return scene;
		}
		
		/**
		 * スキンにボーンなどを追加する際に使う
		 * @param	skin
		 * @param	object
		 */
		private function addChildToSkin(skin:M3DSkin, object:M3DBone):void 
		{
			var skinTemp:SkinTemp = skinTemps[skin] || new SkinTemp();
			skinTemps[skin] = skinTemp;
			
			var skinMatrix:Matrix3D = getWorldMatrix(skin);
			skinMatrix.invert();
			
			var boneMatrix:Matrix3D = getWorldMatrix(object);
			boneMatrix.append(skinMatrix);
			//___POSEで位置を決めるようにしたので除外する？
			object.matrix = boneMatrix.rawData;
			
			//ボーンが内包する全ての子ボーンをチェック
			for each(var item:M3DObject in getM3DChildren(object))
			{
				var bone:M3DBone = item as M3DBone;
				if (bone == null || bone.transformLink == null) continue;
				var initMatrix:Matrix3D = new Matrix3D(bone.transformLink);
				initMatrix.append(skinMatrix);
				bone.transformLink = initMatrix.rawData;
				/*
				initMatrix.rawData = bone.transform2;
				initMatrix.append(skinMatrix);
				bone.transform2 = initMatrix.rawData;
				*/
			}
			
			/*
			var objectMatrix:Matrix3D = new Matrix3D(object.matrix);
			objectMatrix.invert();
			boneMatrix.append(objectMatrix);
			
			var mtx:Matrix3D = new Matrix3D(object.matrix);
			mtx.append(boneMatrix);
			object.matrix = mtx.rawData;
			trace_(object.name, boneMatrix.rawData);
			*/
			
			parentM3DLink[object] = skin;
			
			var fbx:FBXObject = objectFBXLink[object];
			boneIndexCount = 0;
			scanSkinBone(skin, fbx);
			
			//スキンのウェイトをまとめる
			var i:int;
			var j:int;
			var n:int;
			var m:int;
			
			//indexListTemp、weightListTempの全ての要素の長さを揃える（いまのところ4）
			var WEIGHT_NUM:int = 4;
			n = skinTemp.indexListTemp.length;
			for (i = 0; i < n; i++) 
			{
				var indexList:Array = skinTemp.indexListTemp[i];
				var weightList:Array = skinTemp.weightListTemp[i];
				if (indexList == null)
				{
					indexList = skinTemp.indexListTemp[i] = [];
				}
				if (weightList == null)
				{
					weightList = skinTemp.weightListTemp[i] = [];
				}
				m = WEIGHT_NUM - indexList.length;
				for (j = 0; j < m; j++)
				{
					indexList.push(0);
				}
				m = WEIGHT_NUM - weightList.length;
				for (j = 0; j < m; j++)
				{
					weightList.push(0);
				}
			}
			
			//元の頂点インデックスからボーンインデックス＆ウェイトを展開していく
			var fbxSkin:FBXMesh = objectFBXLink[skin];
			var geom:FBXMeshGeometry = fbxSkin.geometry as FBXMeshGeometry;
			var vertexIndices:Vector.<uint> = geom.vertexIndices;
			
			skinTemp.indexList = new Vector.<Number>;
			skinTemp.weightList = new Vector.<Number>;
			
			n = geom.vertexIndices.length;
			for (i = 0; i < n; i++) 
			{
				var vertexIndex:int = geom.vertexIndices[i];
				var index:int = geom.localVertexIndexLink[vertexIndex];
				
				var max:int = (vertexIndex + 1) * 4;
				if (skinTemp.indexList.length < max)
				{
					skinTemp.indexList.length = max;
				}
				if (skinTemp.weightList.length < max)
				{
					skinTemp.weightList.length = max;
				}
				skinTemp.indexList[vertexIndex * 4 + 0] = skinTemp.indexListTemp[index][0];
				skinTemp.indexList[vertexIndex * 4 + 1] = skinTemp.indexListTemp[index][1];
				skinTemp.indexList[vertexIndex * 4 + 2] = skinTemp.indexListTemp[index][2];
				skinTemp.indexList[vertexIndex * 4 + 3] = skinTemp.indexListTemp[index][3];
				skinTemp.weightList[vertexIndex * 4 + 0] = skinTemp.weightListTemp[index][0];
				skinTemp.weightList[vertexIndex * 4 + 1] = skinTemp.weightListTemp[index][1];
				skinTemp.weightList[vertexIndex * 4 + 2] = skinTemp.weightListTemp[index][2];
				skinTemp.weightList[vertexIndex * 4 + 3] = skinTemp.weightListTemp[index][3];
			}
		}
		
		private function getM3DChildren(root:M3DObject):Vector.<M3DObject> 
		{
			var result:Vector.<M3DObject> = new Vector.<M3DObject>;
			
			var task:Vector.<M3DObject> = new Vector.<M3DObject>;
			task.push(root);
			
			while (task.length)
			{
				var m3d:M3DObject = task.pop();
				result.push(m3d);
				
				for each(var fbx:FBXObject in objectFBXLink[m3d].children)
				{
					task.push(objectM3DLink[fbx]);
				}
			}
			return result;
		}
		
		private function getWorldMatrix(current:M3DObject):Matrix3D 
		{
			var matrix:Matrix3D = new Matrix3D();
			while (current)
			{
				matrix.prepend(new Matrix3D(current.matrix));
				current = parentM3DLink[current];
			}
			return matrix;
		}
		
		private var boneIndexCount:int;
		private var skinTemps:Dictionary = new Dictionary();
		/**
		 * fbx以下の子を再帰的に調べて、FBXBoneだったらdeformerの関連頂点インデックスとウェイトを調べてまとめる
		 * @param	skin
		 * @param	fbx
		 */
		private function scanSkinBone(skin:M3DSkin, fbx:FBXObject):void 
		{
			var skinTemp:SkinTemp = skinTemps[skin] || new SkinTemp();
			skinTemps[skin] = skinTemp;
			
			var fbxBone:FBXBone = fbx as FBXBone;
			var m3dBone:M3DBone = objectM3DLink[fbxBone] as M3DBone;
			if (m3dBone)
			{
				m3dBone.enabled = Boolean(fbxBone.deformer);
			}
			//どの頂点とも関連付けられていないボーンはdeformerがない？
			if (fbxBone && fbxBone.deformer)
			{
				m3dBone.index = boneIndexCount++;
				
				var m:int = fbxBone.deformer.indexes.length;
				for (var j:int = 0; j < m; j++) 
				{
					//FBXBone側のウェイト設定をM3DSkin側に設定する
					var addIndex:int = fbxBone.deformer.indexes[j];
					var addWeight:Number = fbxBone.deformer.weights[j];
					
					//各頂点のボーンインデックス
					if (skinTemp.indexListTemp[addIndex] == null)
					{
						skinTemp.indexListTemp[addIndex] = [];
					}
					skinTemp.indexListTemp[addIndex].push(m3dBone.index);
					
					//各頂点のウェイト
					if (skinTemp.weightListTemp[addIndex] == null)
					{
						skinTemp.weightListTemp[addIndex] = [];
					}
					skinTemp.weightListTemp[addIndex].push(addWeight);
				}
			}
			
			//子供を再帰的にチェック
			var n:int = fbx.children.length;
			for (var i:int = 0; i < n; i++) 
			{
				scanSkinBone(skin, fbx.children[i]);
 			}
		}
		
		/**
		 * M3DObjectを継承したオブジェクトがM3DObjectそのものかどうか
		 * @param	obj
		 * @return
		 */
		private function isContainer(obj:M3DObject):Boolean 
		{
			return !(obj is M3DCamera || obj is M3DMesh || obj is M3DLine || obj is M3DLight || obj is M3DBillboard);
		}
		
		/**
		 * 指定M3DObjectの親のM3DObjectを取得
		 * @param	m3d
		 * @return
		 */
		private function getParent(m3d:M3DObject):M3DObject 
		{
			return parentM3DLink[m3d];
		}
		
		/**
		 * ルート階層へ動かしてもいいオブジェクトかどうか
		 */
		private function checkMovableObject(fbx:FBXObject, animation:M3DParser):Boolean 
		{
			//天球オブジェクトの場合
			if (fbx.ancestorUserData("sky", true, true)) return false;
			
			//メッシュでもライトでもない場合
			if (!(fbx is FBXMesh) && !(fbx is FBXLight)) return false;
			
			var target:FBXObject;
			//アニメーションチェック
			//自分の親を辿ってキーアニメーションが存在するかチェック
			target = fbx;
			while (target)
			{
				if (target.hasAnimation) return false;
				if (animation)
				{
					var animationID:String = target.getAnimationID();
					if (animation.getObjectByAnimationID(animationID)) return false;
				}
				target = target.parent;
			}
			
			//移動不可コンテナのチェック
			//自分の親を辿ってcontainer=trueが存在するかチェック
			target = fbx;
			while (target)
			{
				if (target.getUserData("container", false)) return false;
				target = target.parent;
			}
			
			return true;
		}
		
		/**
		 * 指定のM3Dオブジェクトをルート階層に移動する
		 * @param	m3d
		 */
		private function moveToRoot(m3d:M3DObject):void 
		{
			var fbx:FBXObject = objectFBXLink[m3d];
			var globalMatrix:Matrix3D = fbx.parent.getGlobalMatrix();
			globalMatrix.prepend(new Matrix3D(m3d.matrix));
			m3d.matrix = globalMatrix.rawData;
			parentM3DLink[m3d] = null;
			//祖先のvisible/showを全てチェックして自分に適用
			m3d.visible = fbx.checkVisible(option.useVisible, option.useShow);
		}
		
		private function addGeometry(geom:M3DGeometry):int
		{
			if (!geom) return -1;
			
			var index:int = scene.geometryList.indexOf(geom);
			if (index != -1)
			{
				return index;
			}
			
			scene.geometryList.push(geom);
			return scene.geometryList.length - 1;
		}
		
		public function log(...arg):void 
		{
			dispatchEvent(new TextEvent("log", false, false, arg.join(",")));
		}
		
		//--------------------------------------------------------------------------
		//
		//  アニメーションのみM3D化
		//
		//--------------------------------------------------------------------------
		
		
		
		//--------------------------------------------------------------------------
		//
		//  ジオメトリ生成
		//
		//--------------------------------------------------------------------------
		
		/**
		 * FBXジオメトリからM3Dジオメトリ生成
		 * @param	fbx
		 * @return
		 */
		private function toM3DGeometry(fbx:FBXGeometry, animation:M3DParser, scene:M3DScene):M3DGeometry 
		{
			if (fbx is FBXMeshGeometry) return toM3DMeshGeometry(fbx as FBXMeshGeometry, animation, scene);
			if (fbx is FBXLineGeometry) return toM3DLineGeometry(fbx as FBXLineGeometry);
			return null;
		}
		
		private function toM3DLineGeometry(fbx:FBXLineGeometry):M3DLineGeometry 
		{
			var geom:M3DLineGeometry = new M3DLineGeometry();
			geom.segmentList = new Vector.<M3DLineSegment>;
			var n:int = fbx.segmentList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var fbxSeg:FBXLineSegment = fbx.segmentList[i];
				var m3dSeg:M3DLineSegment = new M3DLineSegment();
				m3dSeg.pointList = fbxSeg.pointList.concat();
				geom.segmentList.push(m3dSeg);
			}
			return geom;
		}
		
		/**
		 * 
		 * @param	fbx
		 * @return
		 */
		private function toM3DMeshGeometry(fbx:FBXMeshGeometry, animation:M3DParser, scene:M3DScene):M3DMeshGeometry
		{
			var geom:M3DMeshGeometry = new M3DMeshGeometry();
			geom.vertexIndices = fbx.vertexIndices.concat();
			
			var lowVtx:Boolean = option.lowVertices;
			var lowNum:int = option.lowNumber;
			var numVertices:int = fbx.vertices.length / 3;
			
			geom.vertices = fbx.vertices.concat();
			geom.uvs = (!option.exportUV || fbx.hasUV == false)? null : fbx.uvs.concat();
			geom.normals = (!option.exportNormal || fbx.hasNormal == false)? null : fbx.normals.concat();
			geom.colors = (!option.exportVertexColor || fbx.hasColor == false)? null : fbx.colors.concat();
			
			if (!option.exportTangent4)
			{
				geom.tangents = null
			}
			else if (fbx.hasTangent4)
			{
				geom.tangents = fbx.tangent4.concat();// .getDummyTangent4(numVertices);
			}
			else
			{
				geom.calculateTangents();
			}
			//}
			
			if (!fbx.hasTangent4)
			{
				///log("★★★" + fbx.ownerList[0].name + "のジオメトリにTangent4がないため、ダミーの値をいれます！");
			}
			
			//自分を参照しているオブジェクトの中に基点移動ができないタイプがあるか調べる
			var offsetEnabled:Boolean = true;
			var i:int;
			var n:int;
			n = fbx.ownerList.length;
			for (i = 0; i < n; i++) 
			{
				var owner:FBXObject = fbx.ownerList[i];
				if (checkMoveBasePointEnabled(owner, animation) == false)
				{
					offsetEnabled = false;
					break;
				}
			}
			
			//空は基点オフセットしない
			if (option.moveBasePoint && offsetEnabled)
			{
				//AABBの中心座標がそのままオフセット量になる
				var offset:Vector3D = getCenterPoint(geom.vertices);
				//全頂点をオフセット
				n = geom.vertices.length;
				for (i = 0; i < n; i += 3)
				{
					geom.vertices[i + 0] -= offset.x;
					geom.vertices[i + 1] -= offset.y;
					geom.vertices[i + 2] -= offset.z;
				}
				offsetLink[fbx] = offset;
			}
			return geom;
		}
		
		/**
		 * FBXオブジェクトが基点移動可能なタイプか調べる
		 * @param	fbx
		 * @param	animation
		 * @return
		 */
		private function checkMoveBasePointEnabled(fbx:FBXObject, animation:M3DParser):Boolean 
		{
			//天球に内包されていればだめ
			if (fbx.ancestorUserData("sky", true, false))
			{
				return false;
			}
			//アニメーションオブジェクトでもだめ
			if (animation && animation.getObjectByAnimationID(fbx.getAnimationID()))
			{
				return false;
			}
			//それ以外ならtrue
			return true;
		}
		
		private function toM3DBone(fbx:FBXBone):M3DBone
		{
			var bone:M3DBone = new M3DBone();
			if (fbx.deformer == null)
			{
				log("★★★★★" + String(fbx) + "(" + fbx.name + ")にdeformer情報がありません！");
				bone.transformLink = null;
			}
			else
			{
				//@@@ここ、deformer.transformとdeformer.transformLinkどっちがいいのか？
				var mtx:Matrix3D = new Matrix3D(fbx.deformer.transformLink);
				mtx.invert();
				bone.transformLink = mtx.rawData;// .transformLink;
				///bone.transform2 = fbx.deformer.transform;// .transformLink;
			}
			return bone;
		}
		
		private function toM3DCamera(fbx:FBXCamera):M3DCamera
		{
			var camera:M3DCamera = new M3DCamera();
			var attr:FBXCameraAttribute = fbx.attribute as FBXCameraAttribute;
			camera.fovX = attr.fovX;
			camera.fovY = attr.fovY;
			camera.width = attr.aspectWidth;
			camera.height = attr.aspectHeight;
			camera.zNear = attr.zNear;
			camera.zFar = attr.zFar;
			return camera;
		}
		
		private function toM3DLine(fbx:FBXLine):M3DLine 
		{
			var line:M3DLine = new M3DLine();
			return line;
		}
		
		//--------------------------------------------------------------------------
		//
		//  マテリアル生成
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	fbx
		 * @return
		 */
		private function toM3DMaterial(fbx:FBXMaterial):M3DMaterial 
		{
			var material:M3DMaterial = new M3DMaterial();
			material.name = fbx.name;
			//テクスチャパスからフォルダを削除（画像埋め込み時もフォルダパスは削除）
			var dir:Boolean = option.removeDirectory;// || option.exportImage;
			if (fbx.diffuseMap)
			{
				material.diffusePath = dir? getFileName(fbx.diffuseMap.fullPath) : fbx.diffuseMap.fullPath;
			}
			if (fbx.normalMap && option.exportNormal)
			{
				material.normalPath = dir? getFileName(fbx.normalMap.fullPath) : fbx.normalMap.fullPath;
			}
			if (fbx.transparentMap && option.exportTransparent)
			{
				material.opacityPath = dir? getFileName(fbx.transparentMap.fullPath) : fbx.transparentMap.fullPath;
			}
			if (fbx.reflectionMap && option.exportReflection)
			{
				material.reflectionPath = dir? getFileName(fbx.reflectionMap.fullPath) : fbx.reflectionMap.fullPath;
			}
			
			material.reflectionFactor = fbx.reflectionFactor;
			material.diffuseColor = fbx.diffuseColor;
			material.blendMode = toCorrectedBlendMode(fbx.blendMode);
			material.doubleSided = fbx.doubleSided;
			material.alpha = fbx.alpha;
			material.tiling = fbx.repeat? Tiling.WRAP : Tiling.CLAMP;
			return material;
		}
		
		private function toCorrectedBlendMode(blendMode:String):String 
		{
			switch(blendMode)
			{
				case BlendMode.ADD		: return BlendMode.ADD;
				case BlendMode.MULTIPLY	: return BlendMode.MULTIPLY;
				case BlendMode.SCREEN	: return BlendMode.SCREEN;
			}
			return BlendMode.NORMAL;
		}
		
		/**
		 * 
		 * @param	path
		 * @return
		 */
		private function getFileName(path:String):String 
		{
			return path.split("\\").join("/").split("/").pop();
		}
		
		//--------------------------------------------------------------------------
		//
		//  オブジェクト生成
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	m3d
		 * @param	offset
		 */
		private function offsetM3D(m3d:M3DObject, offset:Vector3D):void 
		{
			m3d.matrix[12] -= offset.x;
			m3d.matrix[13] -= offset.y;
			m3d.matrix[14] -= offset.z;
		}
		
		/**
		 * 
		 * @param	fbx
		 * @return
		 */
		private function toM3DObject(fbx:FBXObject):M3DObject 
		{
			var result:M3DObject;
			
			//Sprite3D化する場合
			///var spriteAxis:String = fbx.getUserData("sprite3D");
			
			if (fbx is FBXMesh)
			{
				/*
				if (spriteAxis)
				{
					result = toM3DBillboard(fbx as FBXMesh, spriteAxis);
				}
				else
				{*/
					if (option.moveBasePoint)
					{
						moveCenter(fbx as FBXMesh);
					}
					result = toM3DMesh(fbx as FBXMesh);
				//}
			}
			else if (fbx is FBXBone)
			{
				result = toM3DBone(fbx as FBXBone);
			}
			else if (fbx is FBXCamera)
			{
				result = toM3DCamera(fbx as FBXCamera);
			}
			else if (fbx is FBXLine)
			{
				result = toM3DLine(fbx as FBXLine);
			}
			else if (fbx is FBXLight)
			{
				result = toM3DLight(fbx as FBXLight);
			}
			else
			{
				result = new M3DObject();
			}
			
			//ジオメトリがあればここで追加
			if (fbx.geometry)
			{
				var mgeom:M3DGeometry = m3dGeomLink[fbx.geometry];
				addGeometry(mgeom);
				result.geometryID = mgeom.id;
			}
			
			//UserData
			result.userData = { };
			for (var k:String in fbx.userData)
			{
				if (option.ignoreUserDaraList.indexOf(k) != -1) continue;
				result.userData[k] = fbx.userData[k];
			}
			
			if (option.extractObjectParam)
			{
				var numParams:int = option.objectParamList.length;
				for (var i:int = 0; i < numParams; i++) 
				{
					var key:String = option.objectParamList[i];
					if (fbx.param.hasOwnProperty(key))
					{
						result.userData[key] = fbx.param[key];
					}
				}	
			}
			
			var visible1:Boolean = !option.useVisible || fbx.getUserData("visible", true);
			var visible2:Boolean = !option.useShow || fbx.getUserData("show", true);
			result.visible = visible1 && visible2;
			
			//アニメーション
			if (option.exportAnimation && fbx.hasAnimation)
			{
				result.animation = new M3DAnimation();
				result.animation.position = toCurveAnimation(fbx.translateAnimation);
				result.animation.rotation = toCurveAnimation(fbx.rotateAnimation);
				result.animation.scale = toCurveAnimation(fbx.scaleAnimation);
				//アニメーションしない要素はデフォルト値にしておく必要があるので（fbxから取り出した回転でないとおかしくなる）
				result.animation.defaultRotation = fbx.rotation.clone();
				result.animation.defaultRotation.scaleBy(180 / Math.PI);
			}
			
			//元の名前を保存
			result.animationID = fbx.getUserData("animationID") || fbx.name;
			result.name = fbx.name;
			result.matrix = fbx.getMatrix().rawData.concat();
			return result;
		}
		
		private function toCurveAnimation(node:FBXAnimationNode):M3DTrackXYZ 
		{
			if (node == null) return null;
			
			var result:M3DTrackXYZ = new M3DTrackXYZ();
			if (node.x) result.x = toAnimationTrack(node.x);
			if (node.y) result.y = toAnimationTrack(node.y);
			if (node.z) result.z = toAnimationTrack(node.z);
			return result;
		}
		
		private function toAnimationTrack(fbx:FBXAnimationCurve):M3DCurveTrack 
		{
			var result:M3DCurveTrack = new M3DCurveTrack();
			result.startTime = fbxScene.global.startTime;
			result.endTime = fbxScene.global.endTime;
			result.keyList = new Vector.<M3DKeyframe>;
			var n:int = fbx.times.length;
			for (var i:int = 0; i < n; i++) 
			{
				var key:M3DKeyframe = new M3DKeyframe();
				key.tangent = TangentType.BEZIER;
				key.time = fbx.times[i];
				key.value = fbx.values[i];
				key.nextTime = fbx.nextControlT[i];
				key.nextValue = fbx.nextControlV[i];
				key.prevTime = fbx.prevControlT[i];
				key.prevValue = fbx.prevControlV[i];
				result.keyList.push(key);
			}
			result.loop = true;
			return result;
		}
		
		private function toM3DBillboard(fbx:FBXMesh, axis:String):M3DBillboard
		{
			var bb:M3DBillboard = new M3DBillboard();
			var fbxMeshGeom:FBXMeshGeometry = fbx.geometry as FBXMeshGeometry;
			
			var maxX:Number = 0;
			var maxY:Number = 0;
			var maxZ:Number = 0;
			var n:int = fbxMeshGeom.vertexIndices.length;
			for (var i:int = 0; i < n; i += 3)
			{
				var index:int = fbxMeshGeom.vertexIndices[i];
				var x:Number = Math.abs(fbxMeshGeom.vertices[index + 0]);
				var y:Number = Math.abs(fbxMeshGeom.vertices[index + 1]);
				var z:Number = Math.abs(fbxMeshGeom.vertices[index + 2]);
				if (maxX < x) maxX = x;
				if (maxY < y) maxY = y;
				if (maxZ < z) maxZ = z;
			}
			maxX *= 2;
			maxY *= 2;
			maxZ *= 2;
			switch(axis)
			{
				case "zy":
					bb.width = maxX;
					bb.height = maxY;
					break;
				case "zx":
					bb.width = maxY;
					bb.height = maxX;
					break;
				case "yz":
					bb.width = maxX;
					bb.height = maxZ;
					break;
				case "yx":
					bb.width = maxZ;
					bb.height = maxX;
					break;
				case "xz":
					bb.width = maxY;
					bb.height = maxZ;
					break;
				case "xy":
					bb.width = maxZ;
					bb.height = maxY;
					break;
				default:
					throw new Error("軸の指定が正しくありません。");
			}
			
			//マテリアル
			bb.material = -1;
			if (fbxMeshGeom.surfaceList.length)
			{
				var surface:FBXSurface = fbxMeshGeom.surfaceList[0]
				var materialM3D:M3DMaterial = materialM3DLink[surface.material];
				if (materialM3D)
				{
					bb.material = materialM3D.id;
					activeMaterial[materialM3D] = true;
				}
				fbx.geometry = null;
			}
			
			return bb;
		}
		
		private function toM3DMesh(fbx:FBXMesh):M3DObject
		{
			if (!fbx.geometry)
			{
				return new M3DObject();
			}
			
			var mesh:M3DMesh;
			/*
			var decal:Boolean;
			var priority:Number;
			if (option.useDecal && fbx.userData.decal != undefined)
			{
				decal = true;
				priority = Number(fbx.userData.decal) || 0;
			}
			if (option.useZbias && fbx.userData["zbias_enable"])
			{
				decal = true;
				priority = fbx.getUserData("zbias") || 0;
			}
			*/
			var fbxMeshGeom:FBXMeshGeometry = fbx.geometry as FBXMeshGeometry;
			
			if (fbxMeshGeom.skin)
			{
				//SKIN
				mesh = new M3DSkin();
				fbxBoneLink[mesh] = fbxMeshGeom.skin.boneList;
			}
			else
			{
				mesh = new M3DMesh();
			}
			//マテリアル
			mesh.surfaceList = new Vector.<M3DSurface>;
			var n:int = fbxMeshGeom.surfaceList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var surface:M3DSurface = new M3DSurface();
				var sf:FBXSurface = fbxMeshGeom.surfaceList[i];
				if (!sf) continue;
				
				surface.indexBegin = sf.indexBegin;
				surface.numTriangle = sf.numTriangle;
				surface.hasTransparentVertex = sf.hasTransparentVertex;
				
				var mt:M3DMaterial = materialM3DLink[sf.material];
				if (!mt) continue;
				
				surface.material = mt.id;
				activeMaterial[mt] = true;
				mesh.surfaceList.push(surface);
			}
			
			return mesh;
		}
		
		private function toM3DLight(fbx:FBXLight):M3DLight 
		{
			var light:M3DLight = new M3DLight();
			var attr:FBXLightAttribute = fbx.attribute;
			if (attr.type == FBXLight.OMNI) light.type = M3DLight.OMNI;
			if (attr.type == FBXLight.DIRECTIONAL) light.type = M3DLight.DIRECTIONAL;
			if (attr.type == FBXLight.SPOT) light.type = M3DLight.SPOT;
			
			light.color = attr.color;
			light.intensity = attr.intensity;
			light.fadeStart = attr.farStart;
			light.fadeEnd = attr.farEnd;
			light.innerAngle = attr.innerAngle;
			light.outerAngle = attr.outerAngle;
			return light;
		}
		
		//--------------------------------------------------------------------------
		//
		//  色々
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 基点をAABBの中心に移動させるために全頂点をオフセットする
		 * @param	fbx
		 */
		private function moveCenter(fbx:FBXMesh):void 
		{
			var fg:FBXMeshGeometry = fbx.geometry as FBXMeshGeometry;
			var offset:Vector3D = offsetLink[fg] || new Vector3D();
			//自分の子もオフセットさせるために記憶しておく
			fbx.offset = offset.clone();
			//オブジェクトのオフセット量は回転・スケールに影響される
			var v:Vector3D = fbx.getMatrix().deltaTransformVector(offset);
			fbx.position.x += v.x;
			fbx.position.y += v.y;
			fbx.position.z += v.z;
		}
		
		/**
		 * 全頂点リストから中心座標を求める
		 * @param	vertices
		 * @return
		 */
		private function getCenterPoint(vertices:Vector.<Number>):Vector3D 
		{
			var xMax:Number = -Number.MAX_VALUE;
			var yMax:Number = -Number.MAX_VALUE;
			var zMax:Number = -Number.MAX_VALUE;
			var xMin:Number = Number.MAX_VALUE;
			var yMin:Number = Number.MAX_VALUE;
			var zMin:Number = Number.MAX_VALUE;
			var n:int = vertices.length;
			for (var i:int = 0; i < n; i += 3)
			{
				var vx:Number = vertices[i];
				var vy:Number = vertices[i + 1];
				var vz:Number = vertices[i + 2];
				
				if (xMax < vx) xMax = vx;
				if (yMax < vy) yMax = vy;
				if (zMax < vz) zMax = vz;
				if (xMin > vx) xMin = vx;
				if (yMin > vy) yMin = vy;
				if (zMin > vz) zMin = vz;
			}
			var offset:Vector3D = new Vector3D();
			offset.x = (xMax + xMin) * 0.5;
			offset.y = (yMax + yMin) * 0.5;
			offset.z = (zMax + zMin) * 0.5;
			return offset;
		}
		
	}

}