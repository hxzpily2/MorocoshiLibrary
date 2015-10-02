package net.morocoshi.common.loaders.fbx 
{
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.loaders.fbx.animation.FBXAnimationCurve;
	import net.morocoshi.common.loaders.fbx.animation.FBXAnimationNode;
	import net.morocoshi.common.loaders.fbx.attributes.FBXAttribute;
	import net.morocoshi.common.loaders.fbx.attributes.FBXCameraAttribute;
	import net.morocoshi.common.loaders.fbx.attributes.FBXLightAttribute;
	import net.morocoshi.common.loaders.fbx.bones.FBXBoneDeformer;
	import net.morocoshi.common.loaders.fbx.bones.FBXPose;
	import net.morocoshi.common.loaders.fbx.bones.FBXSkinDeformer;
	import net.morocoshi.common.loaders.fbx.geometries.FBXGeometry;
	import net.morocoshi.common.loaders.fbx.geometries.FBXLineGeometry;
	import net.morocoshi.common.loaders.fbx.geometries.FBXMeshGeometry;
	import net.morocoshi.common.loaders.fbx.materials.FBXMaterial;
	import net.morocoshi.common.loaders.fbx.materials.FBXTexture;
	import net.morocoshi.common.loaders.fbx.objects.FBXBone;
	import net.morocoshi.common.loaders.fbx.objects.FBXCamera;
	import net.morocoshi.common.loaders.fbx.objects.FBXLight;
	import net.morocoshi.common.loaders.fbx.objects.FBXLine;
	import net.morocoshi.common.loaders.fbx.objects.FBXMesh;
	import net.morocoshi.common.loaders.fbx.objects.FBXObject;
	import net.morocoshi.common.math.list.VectorUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXScene 
	{
		public var root:FBXObject;
		public var poseList:Vector.<FBXPose>;
		public var objectList:Vector.<FBXObject>;
		public var geometryList:Vector.<FBXGeometry>;
		private var geometryInstanceList:Vector.<FBXGeometry>;
		private var curveInstanceList:Vector.<FBXAnimationCurve>;
		private var curveNodeInstanceList:Vector.<FBXAnimationNode>;
		//public var materialList:Vector.<FBXMaterial>;
		public var textureList:Vector.<FBXTexture>;
		public var attributeList:Vector.<FBXAttribute>;
		public var layers:Vector.<FBXLayer>;
		public var defaultLayer:FBXLayer;
		public var global:FBXGlobal;
		
		/**FBX時間をミリ秒に変換する係数*/
		static public const MSEC_TO_FBX:Number = 46186158;
		public var numAnimation:int;
		
		private var element:Object;
		
		/**
		 * 
		 * @param	fbx
		 */
		public function FBXScene() 
		{
		}
		
		/**
		 * 
		 * @param	fbx
		 * @param	collector
		 */
		public function parse(fbx:FBXNode, collector:FBXParseCollector):void
		{
			root = new FBXObject();
			element = { };
			poseList = new Vector.<FBXPose>;
			objectList = new Vector.<FBXObject>;
			geometryList = new Vector.<FBXGeometry>;
			geometryInstanceList = new Vector.<FBXGeometry>;
			curveInstanceList = new Vector.<FBXAnimationCurve>;
			curveNodeInstanceList = new Vector.<FBXAnimationNode>;
			//materialList = new Vector.<FBXMaterial>;
			textureList = new Vector.<FBXTexture>;
			attributeList = new Vector.<FBXAttribute>;
			layers = new Vector.<FBXLayer>;
			defaultLayer = new FBXLayer();
			
			var node:FBXNode;
			var type:String;
			
			var i:int;
			var n:int;
			
			//グローバル設定
			global = new FBXGlobal(fbx.GlobalSettings ? fbx.GlobalSettings[0][0] : null);
			
			//各種オブジェクト
			var obj:FBXNode = fbx.Objects[0][0];
			
			//レイヤー
			if (obj.CollectionExclusive)
			{
				n = obj.CollectionExclusive.length;
				for (i = 0; i < n; i++) 
				{
					addLayer(new FBXLayer(obj.CollectionExclusive[i][0]));
				}
			}
			
			//NodeAttribute
			if (obj.NodeAttribute)
			{
				n = obj.NodeAttribute.length;
				for (i = 0; i < n; i++) 
				{
					node = obj.NodeAttribute[i][0];
					type = node.$args[2];
					switch(type)
					{
						case "Light": addAttribute(new FBXLightAttribute(node)); break;
						case "Camera": addAttribute(new FBXCameraAttribute(node)); break;
					}
				}
			}
			
			var geomNodeLink:Dictionary = new Dictionary();
			//ジオメトリ
			if (obj.Geometry)
			{
				n = obj.Geometry.length;
				for (i = 0; i < n; i++) 
				{
					node = obj.Geometry[i][0];
					type = node.$args[2];
					switch(type)
					{
						case "Line":
							var lineGeom:FBXLineGeometry = new FBXLineGeometry();
							lineGeom.parse(node);
							addGeometry(lineGeom);
							break;
						case "Mesh":
							var fbxMeshGeom:FBXMeshGeometry = new FBXMeshGeometry();
							fbxMeshGeom.autoRepeatTexture = collector.option.autoMaterialRepeat;
							fbxMeshGeom.repeatMargin = collector.option.repeatMargin;
							//ここではIDのみパース。メッシュジオメトリはオブジェクトパース後にパース
							fbxMeshGeom.parse(node);
							geomNodeLink[fbxMeshGeom] = node;
							addGeometry(fbxMeshGeom);
							break;
					}
				}
			}
			
			//AnimationCurve
			//%%%ここらへん途中。FBXのアニメーション関連の値の意味がよくわからず保留に。
			if (obj.AnimationCurve)
			{
				n = obj.AnimationCurve.length;
				for (i = 0; i < n; i++) 
				{
					node = obj.AnimationCurve[i][0];
					addAnimationCurve(new FBXAnimationCurve(node));
				}
			}
			
			//AnimationNode
			if (obj.AnimationCurveNode)
			{
				n = obj.AnimationCurveNode.length;
				for (i = 0; i < n; i++) 
				{
					node = obj.AnimationCurveNode[i][0];
					addAnimationNode(new FBXAnimationNode(node));
				}
			}
			
			if (obj.Pose)
			{
				n = obj.Pose.length;
				for (i = 0; i < n; i++) 
				{
					node = obj.Pose[i][0];
					if (node.PoseNode == null) continue;
					
					var nn:int = node.PoseNode.length;
					for (var ii:int = 0; ii < nn; ii++) 
					{
						addPose(new FBXPose(node.PoseNode[ii][0]));
					}
				}
			}
			
			//オブジェクト
			if (obj.Model)
			{
				n = obj.Model.length;
				for (i = 0; i < n; i++) 
				{
					node = obj.Model[i][0];
					type = node.$args[2];
					switch(type)
					{
						case "Null": addObject(new FBXObject(node)); break;
						case "Mesh": addObject(new FBXMesh(node)); break;
						case "LimbNode": addObject(new FBXBone(node)); break;
						case "Line": addObject(new FBXLine(node)); break;
						case "Light": addObject(new FBXLight(node)); break;
						case "Camera": addObject(new FBXCamera(node)); break;
					}
				}
			}
			
			//ボーン
			if (obj.Deformer)
			{
				n = obj.Deformer.length;
				for (i = 0; i < n; i++) 
				{
					node = obj.Deformer[i][0];
					type = node.$args[2];
					switch(type)
					{
						case "Skin": addElement(new FBXSkinDeformer(node)); break;
						case "Cluster": addElement(new FBXBoneDeformer(node)); break;
					}
				}
			}
			
			//マテリアル
			if (obj.Material)
			{
				n = obj.Material.length;
				for (i = 0; i < n; i++)
				{
					node = obj.Material[i][0];
					addMaterial(new FBXMaterial(node));
				}
			}
			
			if (obj.Texture)
			{
				n = obj.Texture.length;
				for (i = 0; i < n; i++)
				{
					node = obj.Texture[i][0];
					addTexture(new FBXTexture(node));
				}
			}
			
			//親子リンク
			if (fbx.Connections)
			{
				var c:Array = fbx.Connections[0][0].C;
				n = c.length;
				for (i = 0; i < n; i++)
				{
					var a:* = c[i][1] == 0? root : element[c[i][1]];
					var b:* = c[i][2] == 0? root : element[c[i][2]];
					var extra:String = c[i][3];
					if (a is FBXSkinDeformer && b is FBXMeshGeometry)
					{
						FBXMeshGeometry(b).skin = a as FBXSkinDeformer;
					}
					if (a is FBXBoneDeformer && b is FBXSkinDeformer)
					{
						FBXSkinDeformer(b).boneList.push(a as FBXBoneDeformer);
					}
					if (a is FBXBone && b is FBXBoneDeformer)
					{
						FBXBone(a).deformer = b as FBXBoneDeformer;
					}
					if (a is FBXObject && b is FBXLayer)
					{
						FBXObject(a).layer = b as FBXLayer;
					}
					if (a is FBXObject && b is FBXObject)
					{
						if (extra == "LookAtProperty")
						{
							FBXObject(b).lookAt(a as FBXObject);
						}
						else
						{
							FBXObject(b).addChild(a as FBXObject);
						}
					}
					if (a is FBXGeometry && b is FBXObject)
					{
						FBXObject(b).linkGeometry(a as FBXGeometry);
					}
					if (a is FBXMaterial && b is FBXObject)
					{
						FBXObject(b).addMaterial(a as FBXMaterial);
					}
					if (a is FBXTexture && b is FBXMaterial)
					{
						FBXMaterial(b).setTexture(a as FBXTexture, extra);
					}
					if (a is FBXLightAttribute && b is FBXLight)
					{
						FBXLight(b).attribute = (a as FBXLightAttribute);
					}
					if (a is FBXCameraAttribute && b is FBXCamera)
					{
						FBXCamera(b).attribute = (a as FBXCameraAttribute);
					}
					if (collector.option.addAnimation)
					{
						if (a is FBXAnimationCurve && b is FBXAnimationNode)
						{
							FBXAnimationNode(b).attachCurve(a as FBXAnimationCurve, extra);
						}
						if (a is FBXAnimationNode && b is FBXObject)
						{
							FBXObject(b).attachAnimation(a as FBXAnimationNode, extra);
						}
					}
				}
			}
			var meshGeom:FBXMeshGeometry;
			
			//ここでメッシュジオメトリのみパースの続きをやる
			for each(var geom:FBXGeometry in geometryInstanceList)
			{
				meshGeom = geom as FBXMeshGeometry;
				if (!meshGeom) continue;
				if (meshGeom.parseRest(geomNodeLink[geom], collector) == false)
				{
					collector.addLog("■ジオメトリのパースに失敗しました！");
				}
			}
			
			numAnimation = 0;
			//サーフェイスとマテリアルの関連付け、スケール調整、空オブジェクト確認
			for each(var fbxObj:FBXObject in objectList)
			{
				var hasAnimation:Boolean = fbxObj.checkAnimationValid();
				if (hasAnimation)
				{
					numAnimation++;
				}
				fbxObj.calculateScale(this);
				meshGeom = fbxObj.geometryInstance as FBXMeshGeometry;
				if (meshGeom)
				{
					//マテリアル数0の場合はオブジェクトカラーのマテリアルを生成＆追加
					if (!fbxObj.materialList.length)
					{
						var fill:FBXMaterial = createFillMaterial(meshGeom.meshColor);
						fbxObj.materialList.push(fill);
					}
				}
				fbxObj.updateSurface(collector.option);
				
				//もし自分が階層の末端でジオメトリも無い場合＆カメラでもない場合
				if (!fbxObj.children.length && !fbxObj.geometryInstance && !(fbxObj is FBXCamera))
				{
					var target:FBXObject = fbxObj;
					while (target)
					{
						if (target.children.length >= 2 || target.empty)
						{
							break;
						}
						target.empty = true;
						target = target.parent;
					}
				}
			}
			
			//collector.addLog("アニメーションが" + numAnimation + "個あります。");
		}
		
		private function addPose(pose:FBXPose):void 
		{
			poseList.push(pose);
		}
		
		/**
		 * オブジェクトカラーでFillマテリアルを生成
		 * @return
		 */
		public function createFillMaterial(rgb:uint):FBXMaterial
		{
			var fillMaterial:FBXMaterial = new FBXMaterial();
			fillMaterial.setFillMaterial(rgb);
			return fillMaterial;
		}
		
		
		private var scaledGeometryLink:Object = { };
		
		public function getScaledGeometry(id:Number, matrix:Matrix3D, scaleX:int, scaleY:int, scaleZ:int):FBXGeometry 
		{
			var key:String = [id, matrix.rawData.join("@"), scaleX, scaleY, scaleZ].join("@");
			
			var geom:FBXGeometry;
			if (!scaledGeometryLink[key])
			{
				var fg:FBXGeometry = element[id] as FBXGeometry;
				geom = fg.clone();
				geom.setGeomMatrix(matrix);
				geom.rescale(scaleX, scaleY, scaleZ);
				geometryList.push(geom);
				scaledGeometryLink[key] = geom;
			}
			else
			{
				geom = scaledGeometryLink[key];
			}
			
			return geom;
		}
		
		public function getGeometry(id:Number, matrix:Matrix3D):FBXGeometry 
		{
			var key:String = [id, matrix.rawData.join("@")].join("@");
			
			var geom:FBXGeometry;
			if (!scaledGeometryLink[key])
			{
				var fg:FBXGeometry = element[id] as FBXGeometry;
				geom = fg.clone();
				geom.setGeomMatrix(matrix);
				//geom.rescale(scaleX, scaleY, scaleZ);
				geometryList.push(geom);
				scaledGeometryLink[key] = geom;
			}
			else
			{
				geom = scaledGeometryLink[key];
			}
			
			return geom;
		}
		
		/**
		 * 全てのObjectが持つマテリアルを取得する
		 * @return
		 */
		public function getAllMaterialList():Vector.<FBXMaterial> 
		{
			var list:Vector.<FBXMaterial> = new Vector.<FBXMaterial>;
			for (var i:int = 0; i < objectList.length; i++) 
			{
				VectorUtil.attachListDiff(list, objectList[i].materialList);
			}
			return list;
		}
		
		public function getObjectByID(id:Number):FBXObject 
		{
			var n:int = objectList.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (id == objectList[i].id)
				{
					return objectList[i];
				}
			}
			return null;
		}
		
		private function addAttribute(attribute:FBXAttribute):void 
		{
			attributeList.push(attribute);
			element[attribute.id] = attribute;
		}
		
		private function addLayer(layer:FBXLayer):void 
		{
			layers.push(layer);
			element[layer.id] = layer;
		}
		
		private function addTexture(texture:FBXTexture):void 
		{
			textureList.push(texture);
			element[texture.id] = texture;
		}
		
		private function addMaterial(material:FBXMaterial):void 
		{
			//materialList.push(material);
			element[material.id] = material;
		}
		
		private function addAnimationNode(node:FBXAnimationNode):void
		{
			//curveNodeInstanceList.push(node);
			element[node.id] = node;
		}
		
		private function addAnimationCurve(curve:FBXAnimationCurve):void 
		{
			//curveInstanceList.push(curve);
			element[curve.id] = curve;
		}
		
		private function addGeometry(geometry:FBXGeometry):void 
		{
			geometryInstanceList.push(geometry);
			addElement(geometry);
		}
		
		private function addElement(fbx:FBXElement):void 
		{
			element[fbx.id] = fbx;
		}
		
		private function addObject(object:FBXObject):void 
		{
			objectList.push(object);
			object.layer = defaultLayer;
			addElement(object);
		}
		
	}

}