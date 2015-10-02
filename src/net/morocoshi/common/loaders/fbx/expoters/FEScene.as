package net.morocoshi.common.loaders.fbx.expoters 
{
	import flash.utils.Dictionary;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用のシーンデータ
	 * 
	 * @author tencho
	 */
	public class FEScene 
	{
		static public var timeScale:Number = 1539538600;
		/**モデルの実態が無く位置情報のみのデータかどうか（trueの場合、attack時に同名ジオメトリが入れ替えられる）*/
		public var isLayoutData:Boolean = false;
		
		private var axis:Array = [1, 1, 2, 1, 0, 1];//[2, 1, 1, -1, 0, 1];
		private var ambient:Array = [0, 0, 0];
		private var materialLink:Dictionary = new Dictionary();
		private var documentID:Number;
		private var animationBaseLayer:FEAnimationLayer;
		///public var animationLayerList:Vector.<FEAnimationLayer>;
		public var objectList:Vector.<FEObject>;
		public var lightGeometryList:Vector.<FELightGeometry>;
		public var geometryList:Vector.<FEGeometry>;
		public var materialList:Vector.<FEMaterial>;
		public var imageList:Vector.<FEImage>;
		public var layerList:Vector.<FELayer>;
		public var isAnimation:Boolean;
		public var onlyAnimation:Boolean;
		public var numMultiTexture:int;
		public var numDetachedGeometry:int;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function FEScene() 
		{
			isAnimation = false;
			onlyAnimation = false;
			animationBaseLayer = new FEAnimationLayer();
			objectList = new Vector.<FEObject>;
			geometryList = new Vector.<FEGeometry>;
			lightGeometryList = new Vector.<FELightGeometry>;
			///animationLayerList = new Vector.<FEAnimationLayer>;
			materialList = new Vector.<FEMaterial>;
			imageList = new Vector.<FEImage>;
			layerList = new Vector.<FELayer>;
			numMultiTexture = 0;
			numDetachedGeometry = 0;
		}
		
		private function setNewName(data:*):void
		{
			var name:String = data.name;
		}
		
		public function getObjectByName(name:String):FEObject
		{
			for (var i:int = 0; i < objectList.length; i++) 
			{
				if (objectList[i].name == name) return objectList[i];
			}
			return null;
		}
		
		public function getObjectByAnimationID(id:String):FEObject 
		{
			for (var i:int = 0; i < objectList.length; i++) 
			{
				if (objectList[i].getAnimationID() == id) return objectList[i];
			}
			return null;
		}
		
		/**
		 * 別のFESceneをこのFESceneと結合し、重複オブジェクト名をリネームする
		 * @param	scene
		 */
		public function attach(scene:FEScene):void
		{
			var renamer:Renamer = new Renamer();
			
			var i:int;
			var anm:FEAnimationCurve;
			var obj:FEObject;
			var mt:FEMaterial;
			var img:FEImage;
			var newName:String;
			
			for each (obj in objectList)
			{
				renamer.addName(obj.name);
			}
			
			for each (mt in materialList)
			{
				renamer.addName(mt.name);
			}
			
			for each (img in imageList)
			{
				renamer.addName(img.name);
			}
			
			//レイアウト用Sceneの場合、ジオメトリを差し替えてマテリアルを追加する
			if (isLayoutData)
			{
				attachSceneGeometry(scene);
				
				for (i = 0; i < scene.materialList.length; i++) 
				{
					mt = scene.materialList[i];
					mt.name = renamer.rename(mt.name);
					renamer.addName(mt.name);
					addMaterial(mt);
				}
				
				for (i = 0; i < scene.imageList.length; i++) 
				{
					img = scene.imageList[i];
					img.name = renamer.rename(img.name);
					renamer.addName(img.name);
					addImage(img);
				}
				
				return;
			}
			
			for (i = 0; i < scene.objectList.length; i++) 
			{
				obj = scene.objectList[i];
				if (scene.isAnimation)
				{
					//アニメーションデータの場合
					var obj2:FEObject = getObjectByAnimationID(obj.getAnimationID());
					if (!obj2)
					{
						//renamer.addName(obj.name);
						objectList.push(obj);
					}
					else
					{
						obj2.positionAnimation = obj.positionAnimation;
						obj2.rotateAnimation = obj.rotateAnimation;
						obj2.scaleAnimation = obj.scaleAnimation;
					}
				}
				else
				{
					//モデルデータの場合
					obj.name = renamer.rename(obj.name);
					renamer.addName(obj.name);
					objectList.push(obj);
				}
			}
			
			for (i = 0; i < scene.geometryList.length; i++) 
			{
				geometryList.push(scene.geometryList[i]);
			}
			for (i = 0; i < scene.lightGeometryList.length; i++) 
			{
				lightGeometryList.push(scene.lightGeometryList[i]);
			}
			for (i = 0; i < scene.materialList.length; i++) 
			{
				mt = scene.materialList[i];
				mt.name = renamer.rename(mt.name);
				renamer.addName(mt.name);
				addMaterial(mt);
			}
			for (i = 0; i < scene.layerList.length; i++) 
			{
				layerList.push(scene.layerList[i]);
			}
			for (i = 0; i < scene.imageList.length; i++) 
			{
				img = scene.imageList[i];
				img.name = renamer.rename(img.name);
				renamer.addName(img.name);
				addImage(img);
			}
			
			numDetachedGeometry += scene.numDetachedGeometry;
			numMultiTexture += scene.numMultiTexture;
		}
		
		/**
		 * mlt用特殊処理
		 * 他のFESceneからジオメトリだけ取り込む。
		 * デタッチされてるジオメトリがインスタンス共有されてた場合がやっかいでなんとかしたい
		 * @param	scene
		 */
		private function attachSceneGeometry(scene:FEScene):void 
		{
			var rawObject:FEObject = scene.objectList[0];
			var linkage:String = rawObject.linkage;
			if (scene.geometryList.length == 0) return;
			
			var i:int;
			var n:int;
			
			n = objectList.length;
			for (i = 0; i < n; i++) 
			{
				var obj:FEObject = objectList[i];
				if (obj.linkage != linkage) continue;
				
				obj.userData = rawObject.userData;
				var l:int = scene.geometryList.length;
				//シーン内にジオメトリが複数あった場合、2つ目以降はデタッチされたオブジェクトになる
				for (var g:int = 0; g < l; g++) 
				{
					var geom:FEGeometry = scene.geometryList[g];
					addGeometry(geom);
					if (g == 0)
					{
						geom.object = obj;
						obj.geometry = geom;
					}
					else
					{
						var newObject:FEObject = obj.clone();
						newObject.name = obj.name + "_detach" + g;
						newObject.geometry = geom;
						newObject.userData.decal = 1;
						//objをクローンしたときにignoreTransparentがtrueになってしまうので削除
						delete newObject.userData.ignoreTransparent;
						geom.object = newObject;
						objectList.push(newObject);
					}
				}
			}
		}
		
		/**
		 * FEGeometryをリストに追加
		 * @param	geom
		 * @return
		 */
		private function addGeometry(geom:FEGeometry):void 
		{
			if (geometryList.indexOf(geom) >= 0) return;
			
			geometryList.push(geom);
			//return geometryList.length - 1;
		}
		
		/**
		 * 
		 * @param	img
		 */
		public function addImage(img:FEImage):FEImage
		{
			//if (imageLink[img.name]) return imageLink[img.name];
			imageList.push(img);
			//imageLink[img.name] = img;
			return img;
		}
		
		public function addMaterial(mt:FEMaterial):FEMaterial 
		{
			if (materialLink[mt.name]) return materialLink[mt.name];
			materialList.push(mt);
			//imageLink[mt.name] = mt;
			return mt;
		}
		
		/**
		 * 全ての追加済みのFEObjectが所属するレイヤーをインデックスで指定する。
		 * @param	layerIndex
		 */
		public function setLayerAllObjects(layer:FELayer):void
		{
			for each (var item:FEObject in objectList) 
			{
				item.layer = layer;
			}
		}
		
		/**
		 * 
		 */
		public function parse():void 
		{
			var i:int;
			
			for (i = 0; i < materialList.length; i++)
			{
				materialList[i].index = i;
			}
			
			for (i = 0; i < geometryList.length; i++) 
			{
				var geom:FEGeometry = geometryList[i];
				geom.parse();
			}
			
			for (i = 0; i < imageList.length; i++) 
			{
				var img:FEImage = imageList[i];
				img.changePath();
			}
		}
		
		private function initID():void 
		{
			var idCount:Number = 100;
			var i:int;
			var n:int;
			
			documentID = idCount++;
			
			n = geometryList.length;
			for (i = 0; i < n; i++) geometryList[i].id = idCount++;
			n = lightGeometryList.length;
			for (i = 0; i < n; i++) lightGeometryList[i].id = idCount++;
			n = objectList.length;
			for (i = 0; i < n; i++)
			{
				objectList[i].id = idCount++;
			}
			
			for each(var anmNode:FEAnimationNode in getAnimationNodeList())
			{
				anmNode.id = idCount++;
				if (anmNode.x) anmNode.x.id = idCount++;
				if (anmNode.y) anmNode.y.id = idCount++;
				if (anmNode.z) anmNode.z.id = idCount++;
			}
			
			for each(var anmLayer:FEAnimationLayer in getAnimationLayerList())
			{
				anmLayer.layerID = idCount++;
				anmLayer.stackID = idCount++;
			}
			
			n = imageList.length;
			for (i = 0; i < n; i++) imageList[i].id = idCount++;
			n = materialList.length;
			for (i = 0; i < n; i++) materialList[i].id = idCount++;
			n = layerList.length;
			for (i = 0; i < n; i++) layerList[i].id = idCount++;
		}
		
		/**
		 * FBX文字列を生成する
		 * @return
		 */
		public function toFBXString():String
		{
			return new FBXParser().toFBXString(toFBXNode());
		}
		
		/**
		 * 全オブジェクトが持つFEAnimationNodeを取得
		 * @return
		 */
		public function getAnimationNodeList():Vector.<FEAnimationNode>
		{
			var list:Vector.<FEAnimationNode> = new Vector.<FEAnimationNode>;
			for (var i:int = 0; i < objectList.length; i++)
			{
				var obj:FEObject = objectList[i];
				for each (var key:String in ["positionAnimation", "rotateAnimation","scaleAnimation"]) 
				{
					if (!obj[key]) continue;
					list.push(obj[key]);
				}
			}
			return list;
		}
		
		/**
		 * 全オブジェクトが持つFEAnimationLayerを取得
		 * @return
		 */
		public function getAnimationLayerList():Vector.<FEAnimationLayer>
		{
			var list:Vector.<FEAnimationLayer> = new Vector.<FEAnimationLayer>;
			var nodeList:Vector.<FEAnimationNode> = getAnimationNodeList();
			for (var i:int = 0; i < nodeList.length; i++)
			{
				var node:FEAnimationNode = nodeList[i];
				var layer:FEAnimationLayer = node.layer? node.layer : animationBaseLayer;
				if (list.indexOf(layer) == -1) list.push(layer);
			}
			return list;
		}
		
		/**
		 * FBXNodeを生成する
		 * @return
		 */
		public function toFBXNode():FBXNode
		{
			initID();
			
			var propTemp:FBXNode;
			var props:Array;
			var i:int;
			var n:int;
			
			var node:FBXNode = new FBXNode();
			
			//--------------------------------------
			//　　documents
			//--------------------------------------
			
			node.addValue("FBXHeaderExtension", [createHeaderNode()]);
			node.addValue("GlobalSettings", [createSettingNode()]);
			node.addValue("Documents", [createDocmentNode()]);
			node.addValue("References", [new FBXNode()]);
			node.addValue("Definitions", [createAllDefinitionsNode()]);
			
			//--------------------------------------
			//　　object
			//--------------------------------------
			
			var object:FBXNode = new FBXNode();
			
			for (i = 0; i < objectList.length; i++) 
			{
				object.addValue("Model", [objectList[i].toFBXNode()]);
			}
			
			for (i = 0; i < materialList.length; i++) 
			{
				object.addValue("Material", [materialList[i].toFBXNode()]);
			}
			
			for (i = 0; i < imageList.length; i++) 
			{
				object.addValue("Texture", [imageList[i].toFBXNode()]);
			}
			
			for (i = 0; i < layerList.length; i++) 
			{
				object.addValue("CollectionExclusive", [layerList[i].toFBXNode()]);
			}
			
			node.addValue("Objects", [object]);
			
			//--------------------------------------
			//　　animation
			//--------------------------------------
			var key:String;
			
			for (i = 0; i < objectList.length; i++)
			{
				for each (key in FEObject.animationKeyList) 
				{
					var anm:FEAnimationNode = objectList[i][key] as FEAnimationNode;
					if (!anm) continue;
					object.addValue("AnimationCurveNode", [anm.toFBXNode()]);
					if (anm.x) object.addValue("AnimationCurve", [anm.x.toFBXNode()]);
					if (anm.y) object.addValue("AnimationCurve", [anm.y.toFBXNode()]);
					if (anm.z) object.addValue("AnimationCurve", [anm.z.toFBXNode()]);
				}
			}
			
			//--------------------------------------
			//　　animation take
			//--------------------------------------
			
			var anmLayers:Vector.<FEAnimationLayer> = getAnimationLayerList();
			var anmLayer:FEAnimationLayer;
			if (anmLayers.length)
			{
				var takeNode:FBXNode = new FBXNode();
				takeNode.addValue("Current", [""]);
				for (i = 0; i < anmLayers.length; i++) 
				{
					anmLayer = anmLayers[i];
					takeNode.addValue("Take", [anmLayer.toTakeSectionNode()]);
					object.addValue("AnimationLayer", [anmLayer.toLayerNode()]);
					object.addValue("AnimationStack", [anmLayer.toStackNode()]);
				}
				node.addValue("Takes", [takeNode]);
			}
			
			//--------------------------------------
			//　　connection
			//--------------------------------------
			
			var connection:FBXNode = new FBXNode();
			
			//anmLayer
			if (anmLayers.length)
			{
				for (i = 0; i < anmLayers.length; i++) 
				{
					anmLayer = anmLayers[i];
					connection.addValue("C", ["OO", anmLayer.layerID, anmLayer.stackID]);
				}
			}
			
			//objects
			n = objectList.length;
			for (i = 0; i < n; i++)
			{
				var obj:FEObject = objectList[i];
				if (obj.geometry)
				{
					connection.addValue("C", ["OO", obj.geometry.id, obj.id]);
				}
				var parentID:Number = obj.parent? obj.parent.id : 0;
				connection.addValue("C", ["OO", obj.id, parentID]);
				
				//layer
				if (obj.layer)
				{
					connection.addValue("C", ["OO", obj.id, obj.layer.id]);
				}
				
				//anmNode
				for each (key in FEObject.animationKeyList) 
				{
					var anmNode:FEAnimationNode = obj[key];
					if (!anmNode) continue;
					anmLayer = (anmNode.layer)? anmNode.layer : animationBaseLayer;
					connection.addValue("C", ["OP", anmNode.id, obj.id, anmNode.type]);
					connection.addValue("C", ["OO", anmNode.id, anmLayer.layerID]);
					if(anmNode.x) connection.addValue("C", ["OP", anmNode.x.id, anmNode.id, "d|X"]);
					if(anmNode.y) connection.addValue("C", ["OP", anmNode.y.id, anmNode.id, "d|Y"]);
					if(anmNode.z) connection.addValue("C", ["OP", anmNode.z.id, anmNode.id, "d|Z"]);
				}
			}
			
			//lightGeometries
			n = lightGeometryList.length;
			for (i = 0; i < n; i++) 
			{
				var lightGeom:FELightGeometry = lightGeometryList[i];
				object.addValue("NodeAttribute", [lightGeom.toFBXNode()]);
			}
			
			//geometries
			n = geometryList.length;
			for (i = 0; i < n; i++) 
			{
				var geom:FEGeometry = geometryList[i];
				geom.listUpMaterialIndices(this);
				object.addValue("Geometry", [geom.toFBXNode()]);
				/*
				if (!geom.object) continue;
				
				var m:int = geom.materialIDList.length;
				for (var j:int = 0; j < m; j++) 
				{
					var mid:int = geom.materialIDList[j];
					connection.addValue("C", ["OO_0", mid, geom.object.id]);
				}
				*/
			}
			//material->object
			n = objectList.length;
			for (i = 0; i < n; i++) 
			{
				var feObj:FEObject = objectList[i];
				if (!feObj.geometry) continue;
				
				var count:int = feObj.geometry.materialIDList.length;
				for (var j:int = 0; j < count; j++) 
				{
					var mid:Number = feObj.geometry.materialIDList[j];
					connection.addValue("C", ["OO", mid, feObj.id]);
				}
			}
			
			
			//materials
			n = materialList.length;
			for (i = 0; i < n; i++) 
			{
				var fmt:FEMaterial = materialList[i];
				for (var k:String in fmt.texture)
				{
					if (fmt.texture[k] is String) throw new Error("textureの値がFEImageではなくStringのままです。");
					var img:FEImage = fmt.texture[k];
					if (img) connection.addValue("C", ["OP", img.id, fmt.id, k]);
				}
			}
			
			node.addValue("Connections", [connection]);
			
			return node;
		}
		
		/**
		 * name値でFEImageを取得する
		 * @param	name
		 * @return
		 */
		public function getImage(name:String):FEImage 
		{
			for each(var img:FEImage in imageList)
			{
				if (img.name == name) return img;
			}
			return null;
		}
		
		/**
		 * 
		 * @return
		 */
		private function createDocmentNode():FBXNode 
		{
			var document:FBXNode = new FBXNode();
			var props:Array;
			document.addValue("Count", [1]);
			var doc:FBXNode = new FBXNode(null, [documentID, "", "Scene"]);
			props = [
				["SourceObject", "object", "", ""],
				["ActiveAnimStackName", "KString", "", "", ""]
			];
			FBXParser.addPropertyNode(doc, props);
			doc.addValue("RootNode", [0]);
			document.addValue("Document", [doc]);
			return document;
		}
		
		/**
		 * 
		 * @return
		 */
		private function createSettingNode():FBXNode 
		{
			var setting:FBXNode = new FBXNode();
			var props:Array;
			setting.addValue("Version", [1000]);
			props = [
				["UpAxis", "int", "Integer", "", axis[0]],
				["UpAxisSign", "int", "Integer", "", axis[1]],
				["FrontAxis", "int", "Integer", "", axis[2]],
				["FrontAxisSign", "int", "Integer", "", axis[3]],
				["CoordAxis", "int", "Integer", "", axis[4]],
				["CoordAxisSign", "int", "Integer", "", axis[5]],
				["OriginalUpAxis", "int", "Integer", "", 2],//1
				["OriginalUpAxisSign", "int", "Integer", "", 1],
				["UnitScaleFactor", "double", "Number", "", 1],
				["OriginalUnitScaleFactor", "double", "Number", "", 1],
				["AmbientColor", "ColorRGB", "Color", "", ambient[0], ambient[1], ambient[2]],
				["DefaultCamera", "KString", "", "", "Producer Perspective"],
				["TimeMode", "enum", "", "", 6],
				["TimeSpanStart", "KTime", "Time", "", 0],
				["TimeSpanStop", "KTime", "Time", "", timeScale * 100],
				["CustomFrameRate", "double", "Number", "", 30],
			];
			FBXParser.addPropertyNode(setting, props);
			return setting;
		}
		
		/**
		 * 
		 * @return
		 */
		private function createHeaderNode():FBXNode 
		{
			var props:Array;
			
			var header:FBXNode = new FBXNode();
			header.addValue("FBXHeaderVersion", [1003]);
			header.addValue("FBXVersion", [7200]);
			var timeStamp:FBXNode = new FBXNode();
			timeStamp.addValue("Version", [1000]);
			timeStamp.addValue("Year", [2012]);
			timeStamp.addValue("Month", [1]);
			timeStamp.addValue("Day", [1]);
			timeStamp.addValue("Hour", [0]);
			timeStamp.addValue("Minute", [0]);
			timeStamp.addValue("Second", [0]);
			timeStamp.addValue("Millisecond", [0]);
			header.addValue("CreationTimeStamp", [timeStamp]);
			header.addValue("Creator", ["tencho"]);
			
			var sceneInfo:FBXNode = new FBXNode(null, ["SceneInfo::GlobalInfo", "UserData"]);
			sceneInfo.addValue("Type", ["UserData"]);
			sceneInfo.addValue("Version", [100]);
			var meta:FBXNode = new FBXNode();
			meta.addValue("Version", [100]);
			meta.addValue("Title", [""]);
			meta.addValue("Subject", [""]);
			meta.addValue("Author", [""]);
			meta.addValue("Keywords", [""]);
			meta.addValue("Revision", [""]);
			meta.addValue("Comment", [""]);
			sceneInfo.addValue("MetaData", [meta]);
			
			props = [
				["DocumentUrl", "KString", "Url", "", "xxxxxxxxxx.FBX"],
				["SrcDocumentUrl", "KString", "Url", "", "xxxxxxxxxx.FBX"],
				["Original", "Compound", "", ""],
				["Original|ApplicationVendor", "KString", "", "", "Autodesk"],
				["Original|ApplicationName", "KString", "", "", "3ds Max"],
				["Original|ApplicationVersion", "KString", "", "", "2010"],
				["Original|DateTime_GMT", "DateTime", "", "", "10/05/2012 07:04:13.424"],
				["Original|FileName", "KString", "", "", "xxxxxxxxxx.FBX"],
				["LastSaved", "Compound", "", ""],
				["LastSaved|ApplicationVendor", "KString", "", "", "Autodesk"],
				["LastSaved|ApplicationName", "KString", "", "", "3ds Max"],
				["LastSaved|ApplicationVersion", "KString", "", "", "2010"],
				["LastSaved|DateTime_GMT", "DateTime", "", "", "10/05/2012 07:04:13.424"]
			];
			FBXParser.addPropertyNode(sceneInfo, props);
			header.addValue("SceneInfo", [sceneInfo]);
			return header;
		}
		
		/**
		 * 
		 * @return
		 */
		private function createAllDefinitionsNode():FBXNode 
		{
			var props:Array;
			var def:FBXNode = new FBXNode();
			def.addValue("Version", [100]);
			def.addValue("Count", [10]);
			def.addValue("ObjectType", [createDefinitionNode("GlobalSettings")]);
			
			//AnimationStack
			props = [
				["Description", "KString", "", "", ""],
				["LocalStart", "KTime", "Time", "", 0],
				["LocalStop", "KTime", "Time", "", 0],
				["ReferenceStart", "KTime", "Time", "", 0],
				["ReferenceStop", "KTime", "Time", "", 0]
			];
			def.addValue("ObjectType", [createDefinitionNode("AnimationStack", "KFbxAnimStack", props)]);
			
			//AnimationLayer
			props = [
				["Weight", "Number", "", "A",100],
				["Mute", "bool", "", "",0],
				["Solo", "bool", "", "",0],
				["Lock", "bool", "", "",0],
				["Color", "ColorRGB", "Color", "",0.8,0.8,0.8],
				["BlendMode", "enum", "", "",0],
				["RotationAccumulationMode", "enum", "", "",0],
				["ScaleAccumulationMode", "enum", "", "",0],
				["BlendModeBypass", "ULongLong", "", "",0]
			];
			def.addValue("ObjectType", [createDefinitionNode("AnimationLayer", "KFbxAnimLayer", props)]);
			
			//Model
			props = [
				["QuaternionInterpolate", "enum", "", "",0],
				["RotationOffset", "Vector3D", "Vector", "",0,0,0],
				["RotationPivot", "Vector3D", "Vector", "",0,0,0],
				["ScalingOffset", "Vector3D", "Vector", "",0,0,0],
				["ScalingPivot", "Vector3D", "Vector", "",0,0,0],
				["TranslationActive", "bool", "", "",0],
				["TranslationMin", "Vector3D", "Vector", "",0,0,0],
				["TranslationMax", "Vector3D", "Vector", "",0,0,0],
				["TranslationMinX", "bool", "", "",0],
				["TranslationMinY", "bool", "", "",0],
				["TranslationMinZ", "bool", "", "",0],
				["TranslationMaxX", "bool", "", "",0],
				["TranslationMaxY", "bool", "", "",0],
				["TranslationMaxZ", "bool", "", "",0],
				["RotationOrder", "enum", "", "",0],
				["RotationSpaceForLimitOnly", "bool", "", "",0],
				["RotationStiffnessX", "double", "Number", "",0],
				["RotationStiffnessY", "double", "Number", "",0],
				["RotationStiffnessZ", "double", "Number", "",0],
				["AxisLen", "double", "Number", "",10],
				["PreRotation", "Vector3D", "Vector", "",0,0,0],
				["PostRotation", "Vector3D", "Vector", "",0,0,0],
				["RotationActive", "bool", "", "",0],
				["RotationMin", "Vector3D", "Vector", "",0,0,0],
				["RotationMax", "Vector3D", "Vector", "",0,0,0],
				["RotationMinX", "bool", "", "",0],
				["RotationMinY", "bool", "", "",0],
				["RotationMinZ", "bool", "", "",0],
				["RotationMaxX", "bool", "", "",0],
				["RotationMaxY", "bool", "", "",0],
				["RotationMaxZ", "bool", "", "",0],
				["InheritType", "enum", "", "",0],
				["ScalingActive", "bool", "", "",0],
				["ScalingMin", "Vector3D", "Vector", "",0,0,0],
				["ScalingMax", "Vector3D", "Vector", "",1,1,1],
				["ScalingMinX", "bool", "", "",0],
				["ScalingMinY", "bool", "", "",0],
				["ScalingMinZ", "bool", "", "",0],
				["ScalingMaxX", "bool", "", "",0],
				["ScalingMaxY", "bool", "", "",0],
				["ScalingMaxZ", "bool", "", "",0],
				["GeometricTranslation", "Vector3D", "Vector", "",0,0,0],
				["GeometricRotation", "Vector3D", "Vector", "",0,0,0],
				["GeometricScaling", "Vector3D", "Vector", "",1,1,1],
				["MinDampRangeX", "double", "Number", "",0],
				["MinDampRangeY", "double", "Number", "",0],
				["MinDampRangeZ", "double", "Number", "",0],
				["MaxDampRangeX", "double", "Number", "",0],
				["MaxDampRangeY", "double", "Number", "",0],
				["MaxDampRangeZ", "double", "Number", "",0],
				["MinDampStrengthX", "double", "Number", "",0],
				["MinDampStrengthY", "double", "Number", "",0],
				["MinDampStrengthZ", "double", "Number", "",0],
				["MaxDampStrengthX", "double", "Number", "",0],
				["MaxDampStrengthY", "double", "Number", "",0],
				["MaxDampStrengthZ", "double", "Number", "",0],
				["PreferedAngleX", "double", "Number", "",0],
				["PreferedAngleY", "double", "Number", "",0],
				["PreferedAngleZ", "double", "Number", "",0],
				["LookAtProperty", "object", "", ""],
				["UpVectorProperty", "object", "", ""],
				["Show", "bool", "", "",1],
				["NegativePercentShapeSupport", "bool", "", "",1],
				["DefaultAttributeIndex", "int", "Integer", "",-1],
				["Freeze", "bool", "", "",0],
				["LODBox", "bool", "", "",0],
				["Lcl Translation", "Lcl Translation", "", "A",0,0,0],
				["Lcl Rotation", "Lcl Rotation", "", "A",0,0,0],
				["Lcl Scaling", "Lcl Scaling", "", "A",1,1,1],
				["Visibility", "Visibility", "", "A",1],
				["Visibility Inheritance", "Visibility Inheritance", "", "",1]
			]
			/*
				["QuaternionInterpolate", "enum", "", "",0],
				["RotationOffset", "Vector3D", "Vector", "",0,0,0],
				["RotationPivot", "Vector3D", "Vector", "",0,0,0],
				["ScalingOffset", "Vector3D", "Vector", "",0,0,0],
				["ScalingPivot", "Vector3D", "Vector", "",0,0,0],
				["TranslationActive", "bool", "", "",0],
				["TranslationMin", "Vector3D", "Vector", "",0,0,0],
				["TranslationMax", "Vector3D", "Vector", "",0,0,0],
				["TranslationMinX", "bool", "", "",0],
				["TranslationMinY", "bool", "", "",0],
				["TranslationMinZ", "bool", "", "",0],
				["TranslationMaxX", "bool", "", "",0],
				["TranslationMaxY", "bool", "", "",0],
				["TranslationMaxZ", "bool", "", "",0],
				["RotationOrder", "enum", "", "",0],
				["RotationSpaceForLimitOnly", "bool", "", "",0],
				["RotationStiffnessX", "double", "Number", "",0],
				["RotationStiffnessY", "double", "Number", "",0],
				["RotationStiffnessZ", "double", "Number", "",0],
				["AxisLen", "double", "Number", "",10],
				["PreRotation", "Vector3D", "Vector", "",0,0,0],
				["PostRotation", "Vector3D", "Vector", "",0,0,0],
				["RotationActive", "bool", "", "",0],
				["RotationMin", "Vector3D", "Vector", "",0,0,0],
				["RotationMax", "Vector3D", "Vector", "",0,0,0],
				["RotationMinX", "bool", "", "",0],
				["RotationMinY", "bool", "", "",0],
				["RotationMinZ", "bool", "", "",0],
				["RotationMaxX", "bool", "", "",0],
				["RotationMaxY", "bool", "", "",0],
				["RotationMaxZ", "bool", "", "",0],
				["InheritType", "enum", "", "",0],
				["ScalingActive", "bool", "", "",0],
				["ScalingMin", "Vector3D", "Vector", "",0,0,0],
				["ScalingMax", "Vector3D", "Vector", "",1,1,1],
				["ScalingMinX", "bool", "", "",0],
				["ScalingMinY", "bool", "", "",0],
				["ScalingMinZ", "bool", "", "",0],
				["ScalingMaxX", "bool", "", "",0],
				["ScalingMaxY", "bool", "", "",0],
				["ScalingMaxZ", "bool", "", "",0],
				["GeometricTranslation", "Vector3D", "Vector", "",0,0,0],
				["GeometricRotation", "Vector3D", "Vector", "",0,0,0],
				["GeometricScaling", "Vector3D", "Vector", "",1,1,1],
				["MinDampRangeX", "double", "Number", "",0],
				["MinDampRangeY", "double", "Number", "",0],
				["MinDampRangeZ", "double", "Number", "",0],
				["MaxDampRangeX", "double", "Number", "",0],
				["MaxDampRangeY", "double", "Number", "",0],
				["MaxDampRangeZ", "double", "Number", "",0],
				["MinDampStrengthX", "double", "Number", "",0],
				["MinDampStrengthY", "double", "Number", "",0],
				["MinDampStrengthZ", "double", "Number", "",0],
				["MaxDampStrengthX", "double", "Number", "",0],
				["MaxDampStrengthY", "double", "Number", "",0],
				["MaxDampStrengthZ", "double", "Number", "",0],
				["PreferedAngleX", "double", "Number", "",0],
				["PreferedAngleY", "double", "Number", "",0],
				["PreferedAngleZ", "double", "Number", "",0],
				["LookAtProperty", "object", "", ""],
				["UpVectorProperty", "object", "", ""],
				["Show", "bool", "", "",1],
				["NegativePercentShapeSupport", "bool", "", "",1],
				["DefaultAttributeIndex", "int", "Integer", "",-1],
				["Freeze", "bool", "", "",0],
				["LODBox", "bool", "", "",0],
				["Lcl Translation", "Lcl Translation", "", "A",0,0,0],
				["Lcl Rotation", "Lcl Rotation", "", "A",0,0,0],
				["Lcl Scaling", "Lcl Scaling", "", "A",1,1,1],
				["Visibility", "Visibility", "", "A",1],
				["Visibility Inheritance", "Visibility Inheritance", "", "",1]
			];
			*/
			def.addValue("ObjectType", [createDefinitionNode("Model", "KFbxNode", props)]);
			//Material
			props = [
				["ShadingModel", "KString", "", "", "Phong"],
				["MultiLayer", "bool", "", "",0],
				["EmissiveColor", "ColorRGB", "Color", "",0,0,0],
				["EmissiveFactor", "double", "Number", "",1],
				["AmbientColor", "ColorRGB", "Color", "",0.2,0.2,0.2],
				["AmbientFactor", "double", "Number", "",1],
				["DiffuseColor", "ColorRGB", "Color", "",0.8,0.8,0.8],
				["DiffuseFactor", "double", "Number", "",1],
				["Bump", "Vector3D", "Vector", "",0,0,0],
				["NormalMap", "Vector3D", "Vector", "",0,0,0],
				["BumpFactor", "double", "Number", "",1],
				["TransparentColor", "ColorRGB", "Color", "",0,0,0],
				["TransparencyFactor", "double", "Number", "",0],
				["DisplacementColor", "ColorRGB", "Color", "",0,0,0],
				["DisplacementFactor", "double", "Number", "",1],
				["VectorDisplacementColor", "ColorRGB", "Color", "",0,0,0],
				["VectorDisplacementFactor", "double", "Number", "",1],
				["SpecularColor", "ColorRGB", "Color", "",0.2,0.2,0.2],
				["SpecularFactor", "double", "Number", "",1],
				["ShininessExponent", "double", "Number", "",20],
				["ReflectionColor", "ColorRGB", "Color", "",0,0,0],
				["ReflectionFactor", "double", "Number", "",1]
			];
			def.addValue("ObjectType", [createDefinitionNode("Material", "KFbxSurfacePhong", props)]);
			//Texture
			props = [
				["TextureTypeUse", "enum", "", "",0],
				["Texture alpha", "Number", "", "A",1],
				["CurrentMappingType", "enum", "", "",0],
				["WrapModeU", "enum", "", "",0],
				["WrapModeV", "enum", "", "",0],
				["UVSwap", "bool", "", "",0],
				["PremultiplyAlpha", "bool", "", "",1],
				["Translation", "Vector", "", "A",0,0,0],
				["Rotation", "Vector", "", "A",0,0,0],
				["Scaling", "Vector", "", "A",1,1,1],
				["TextureRotationPivot", "Vector3D", "Vector", "",0,0,0],
				["TextureScalingPivot", "Vector3D", "Vector", "",0,0,0],
				["CurrentTextureBlendMode", "enum", "", "",1],
				["UVSet", "KString", "", "", "default"],
				["UseMaterial", "bool", "", "",0],
				["UseMipMap", "bool", "", "",0]
			];
			def.addValue("ObjectType", [createDefinitionNode("Texture", "KFbxFileTexture", props)]);
			
			//Geometry
			props = [
				["Color", "ColorRGB", "Color", "",0.8,0.8,0.8],
				["BBoxMin", "Vector3D", "Vector", "",0,0,0],
				["BBoxMax", "Vector3D", "Vector", "",0,0,0]
			];
			def.addValue("ObjectType", [createDefinitionNode("Geometry", "KFbxMesh", props)]);
			
			//Video
			props = [
				["ImageSequence", "bool", "", "",0],
				["ImageSequenceOffset", "int", "Integer", "",0],
				["FrameRate", "double", "Number", "",0],
				["LastFrame", "int", "Integer", "",0],
				["Width", "int", "Integer", "",0],
				["Height", "int", "Integer", "",0],
				["Path", "KString", "XRefUrl", "", ""],
				["StartFrame", "int", "Integer", "",0],
				["StopFrame", "int", "Integer", "",0],
				["PlaySpeed", "double", "Number", "",0],
				["Offset", "KTime", "Time", "",0],
				["InterlaceMode", "enum", "", "",0],
				["FreeRunning", "bool", "", "",0],
				["Loop", "bool", "", "",0],
				["AccessMode", "enum", "", "",0]
			];
			def.addValue("ObjectType", [createDefinitionNode("Video", "KFbxVideo", props)]);
			
			//NodeAttribute (Light)
			props = [
				["Color", "Color", "", "A",1,1,1],
				["LightType", "enum", "", "",0],
				["CastLightOnObject", "bool", "", "",1],
				["DrawVolumetricLight", "bool", "", "",1],
				["DrawGroundProjection", "bool", "", "",1],
				["DrawFrontFacingVolumetricLight", "bool", "", "",0],
				["Intensity", "Number", "", "A",100],
				["HotSpot", "Number", "", "A",0],
				["Cone angle", "Number", "", "A",45],
				["Fog", "Number", "", "A",50],
				["DecayType", "enum", "", "",0],
				["DecayStart", "Number", "", "A",0],
				["FileName", "KString", "", "", ""],
				["EnableNearAttenuation", "bool", "", "",0],
				["NearAttenuationStart", "Number", "", "A",0],
				["NearAttenuationEnd", "Number", "", "A",0],
				["EnableFarAttenuation", "bool", "", "",0],
				["FarAttenuationStart", "Number", "", "A",0],
				["FarAttenuationEnd", "Number", "", "A",0],
				["CastShadows", "bool", "", "",0],
				["ShadowColor", "Color", "", "A",0,0,0],
				["AreaLightShape", "enum", "", "",0],
				["LeftBarnDoor", "Float", "", "A",20],
				["RightBarnDoor", "Float", "", "A",20],
				["TopBarnDoor", "Float", "", "A",20],
				["BottomBarnDoor", "Float", "", "A",20],
				["EnableBarnDoor", "Bool", "", "A",0],
				["InnerAngle", "Number", "", "A",-1],
				["OuterAngle", "Number", "", "A",-1]
			];
			def.addValue("ObjectType", [createDefinitionNode("NodeAttribute", "KFbxLight", props)]);
			
			//CollectionExclusive
			def.addValue("ObjectType", [createDefinitionNode("CollectionExclusive")]);
			//AnimationCurveNode
			def.addValue("ObjectType", [createDefinitionNode("AnimationCurveNode")]);
			//AnimationCurve
			def.addValue("ObjectType", [createDefinitionNode("AnimationCurve")]);
			
			return def;
		}
		
		/**
		 * 
		 * @param	name1
		 * @param	name2
		 * @param	list
		 * @return
		 */
		private function createDefinitionNode(name1:String, name2:String = "", list:Array = null):FBXNode
		{
			var node:FBXNode = new FBXNode(null, [name1]);
			node.addValue("Count", [1]);
			if (list)
			{
				var propTemp:FBXNode = new FBXNode(null, [name2]);
				FBXParser.addPropertyNode(propTemp, list);
				node.addValue("PropertyTemplate", [propTemp]);
			}
			return node;
		}
		
	}

}