package net.morocoshi.moja3d.loader.exporters 
{
	import a24.tween.core.plugins.PluginTween24Property;
	import adobe.utils.CustomActions;
	import flash.display.BlendMode;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.loaders.collada.nodes.ColladaAnimationData;
	import net.morocoshi.common.loaders.collada.nodes.ColladaControllerNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaEffectNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaGeometryData;
	import net.morocoshi.common.loaders.collada.nodes.ColladaGeometryNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaMaterialNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaObjectNode;
	import net.morocoshi.common.loaders.collada.nodes.ColladaScene;
	import net.morocoshi.common.loaders.collada.nodes.ColladaSurface;
	import net.morocoshi.moja3d.loader.animation.M3DAnimation;
	import net.morocoshi.moja3d.loader.animation.M3DCurveTrack;
	import net.morocoshi.moja3d.loader.animation.M3DKeyframe;
	import net.morocoshi.moja3d.loader.animation.M3DMatrixTrack;
	import net.morocoshi.moja3d.loader.animation.M3DTrackUV;
	import net.morocoshi.moja3d.loader.animation.M3DTrackXYZ;
	import net.morocoshi.moja3d.loader.animation.TangentType;
	import net.morocoshi.moja3d.loader.geometries.M3DGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.M3DParser;
	import net.morocoshi.moja3d.loader.M3DScene;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	import net.morocoshi.moja3d.loader.objects.M3DBone;
	import net.morocoshi.moja3d.loader.objects.M3DMesh;
	import net.morocoshi.moja3d.loader.objects.M3DObject;
	import net.morocoshi.moja3d.loader.objects.M3DSkin;
	import net.morocoshi.moja3d.materials.Mipmap;
	import net.morocoshi.moja3d.materials.Tiling;
	import net.morocoshi.moja3d.resources.Geometry;
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DColladaExporter 
	{
		private var option:M3DExportOption;
		private var collada:ColladaScene;
		private var scene:M3DScene;
		
		private var materialCount:int;
		private var geometryCount:int;
		private var objectCount:int;
		
		private var materialM3DLink:Dictionary;
		private var geometryM3DLink:Dictionary;
		
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function M3DColladaExporter() 
		{
			//m3dGeomLink = new Dictionary();
			//offsetLink = new Dictionary();
			//parentM3DLink = new Dictionary();
			//fbxBoneLink = new Dictionary();
		}
		
		//--------------------------------------------------------------------------
		//
		//  ColladaからM3D書き出し
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ColladaSceneオブジェクトから必要な情報だけ抜き出してM3DScene化
		 * @param	collada
		 * @param	option
		 * @return
		 */
		public function convert(collada:ColladaScene, option:M3DExportOption):M3DScene
		{
			this.collada = collada;
			this.option = option;
			
			collada.fixJointHierarchy();
			M3DParser.registClasses();
			
			materialM3DLink = new Dictionary();
			geometryM3DLink = new Dictionary();
			materialCount = 0;
			geometryCount = 0;
			objectCount = 0;
			
			scene = new M3DScene();
			scene.version = M3DParser.VERSION;
			scene.isAnimation = false;
			scene.materialList = new Vector.<M3DMaterial>;
			scene.objectList = new Vector.<M3DObject>;
			scene.geometryList = new Vector.<M3DGeometry>;
			
			//マテリアル
			for each(var material:ColladaMaterialNode in collada.materials)
			{
				var materialM3D:M3DMaterial = toM3DMaterial(material);
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
				materialM3DLink[material] = materialM3D;
			}
			
			for each(var geometry:ColladaGeometryNode in collada.geometries)
			{
				var geometryM3D:M3DGeometry = toM3DGeometry(geometry);
				geometryM3D.id = ++geometryCount;
				scene.geometryList.push(geometryM3D);
				geometryM3DLink[geometry] = geometryM3D;
			}
			
			for each(var object:ColladaObjectNode in collada.root.childlen)
			{
				toM3DObject(object, null);
			}
			
			if (option.exportAnimation && !option.exportModel)
			{
				scene.setOnlyAnimation();
			}
			
			//全オブジェクトのアニメーションの開始～終了時間を統一する
			var matrixes:Vector.<M3DMatrixTrack> = new Vector.<M3DMatrixTrack>;
			var tracks:Vector.<M3DCurveTrack> = new Vector.<M3DCurveTrack>;
			for each(var m3dObject:M3DObject in scene.objectList)
			{
				var anm:M3DAnimation = m3dObject.animation;
				if (!anm) continue;
				
				if (anm.position)
				{
					if (anm.position.x) tracks.push(anm.position.x);
					if (anm.position.y) tracks.push(anm.position.y);
					if (anm.position.z) tracks.push(anm.position.z);
				}
				if (anm.rotation)
				{
					if (anm.rotation.x) tracks.push(anm.rotation.x);
					if (anm.rotation.y) tracks.push(anm.rotation.y);
					if (anm.rotation.z) tracks.push(anm.rotation.z);
				}
				if (anm.scale)
				{
					if (anm.scale.x) tracks.push(anm.scale.x);
					if (anm.scale.y) tracks.push(anm.scale.y);
					if (anm.scale.z) tracks.push(anm.scale.z);
				}
				if (anm.matrix)
				{
					matrixes.push(anm.matrix);
				}
			}
			
			//全トラックの終了時間で一番遅いものを記録
			var track:M3DCurveTrack;
			var matrix:M3DMatrixTrack;
			var endTime:Number = 0;
			for each(track in tracks) if (endTime < track.endTime) endTime = track.endTime;
			for each(matrix in matrixes) if (endTime < matrix.endTime) endTime = matrix.endTime;
			//全ての終了時間をそれに統一する
			for each(track in tracks) track.endTime = endTime;
			for each(matrix in matrixes) matrix.endTime = endTime;
			
			return scene;
		}
		
		private function toM3DObject(object:ColladaObjectNode, parent:M3DObject):M3DObject 
		{
			var result:M3DObject;
			var i:int;
			var n:int;
			
			if (object.type == ColladaObjectNode.TYPE_JOINT)
			{
				var bone:M3DBone = new M3DBone();
				bone.index = object.jointIndex;
				bone.enabled = true;
				bone.transformLink = object.jointMatrix.rawData;
				result = bone;
			}
			
			if (object.type == ColladaObjectNode.TYPE_LIGHT)
			{
				result = new M3DObject();
			}
			
			if (object.type == ColladaObjectNode.TYPE_OBJECT)
			{
				result = new M3DObject();
			}
			
			var geom:ColladaGeometryNode;
			var colladaSurfaces:ColladaSurface;
			var surface:M3DSurface;
			var materialNode:ColladaMaterialNode;
			
			if (object.type == ColladaObjectNode.TYPE_SKIN)
			{
				var skin:M3DSkin = new M3DSkin();
				var controller:ColladaControllerNode = collada.getControllerByID(object.instanceLink);
				geom = collada.getGeometryByID(controller.skinLink);
				
				skin.geometryID = geometryM3DLink[geom].id;
				skin.surfaceList = new Vector.<M3DSurface>;
				
				n = geom.surfaces.length;
				for (i = 0; i < n; i++) 
				{
					colladaSurfaces = geom.surfaces[i];
					surface = new M3DSurface();
					surface.hasTransparentVertex = false;
					surface.indexBegin = colladaSurfaces.indexBegin;
					surface.numTriangle = colladaSurfaces.numTriangle;
					materialNode = collada.getMaterialByID(object.bindMaterial[colladaSurfaces.materialID]);
					surface.material = materialM3DLink[materialNode].id;
					skin.surfaceList.push(surface);
				}
				
				result = skin;
			}
			
			if (object.type == ColladaObjectNode.TYPE_MESH)
			{
				var mesh:M3DMesh = new M3DMesh();
				geom = collada.getGeometryByID(object.instanceLink);
				mesh.geometryID = geometryM3DLink[geom].id;
				mesh.surfaceList = new Vector.<M3DSurface>;
				
				n = geom.surfaces.length;
				for (i = 0; i < n; i++) 
				{
					colladaSurfaces = geom.surfaces[i];
					surface = new M3DSurface();
					surface.hasTransparentVertex = false;
					surface.indexBegin = colladaSurfaces.indexBegin;
					surface.numTriangle = colladaSurfaces.numTriangle;
					materialNode = collada.getMaterialByID(object.bindMaterial[colladaSurfaces.materialID]);
					surface.material = materialM3DLink[materialNode].id;
					mesh.surfaceList.push(surface);
				}
				
				result = mesh;
			}
			
			if (object.animation)
			{
				result.animation = toM3DAnimation(object.animation);
			}
			
			result.animationID = object.id || object.name;
			result.visible = object.visible;
			result.name = object.name;
			result.id = ++objectCount;
			result.matrix = object.matrix.rawData.concat();
			result.parent = parent? parent.id : -1;
			scene.objectList.push(result);
			
			n = object.childlen.length;
			for (i = 0; i < n; i++) 
			{
				var child:ColladaObjectNode = object.childlen[i];
				toM3DObject(child, result);
			}
			
			return result;
		}
		
		private function toM3DScaleAnimation(animation:ColladaAnimationData):M3DTrackXYZ
		{
			var tangentData:Object = {
				"LINEAR": TangentType.LINER,
				"BEZIER": TangentType.BEZIER,
				"CARDINAL": TangentType.LINER,
				"HERMITE": TangentType.LINER,
				"BSPLINE": TangentType.LINER,
				"STEP": TangentType.STEP
			}
			
			var result:M3DTrackXYZ = new M3DTrackXYZ();
			result.x = new M3DCurveTrack();
			result.y = new M3DCurveTrack();
			result.z = new M3DCurveTrack();
			
			var startTime:Number = Number.MAX_VALUE;
			var endTime:Number = -Number.MAX_VALUE;
			var scales:Array = [result.x, result.y, result.z];
			for (var j:int = 0; j < 3; j++) 
			{
				var track:M3DCurveTrack = scales[j];
				track.loop = true;
				track.keyList = new Vector.<M3DKeyframe>;
				
				var n:int = animation.times.length;
				for (var i:int = 0; i < n; i++) 
				{
					var keyframe:M3DKeyframe = new M3DKeyframe();
					var time:Number = animation.times[i];
					var value:Number = animation.values[i][j];
					keyframe.time = time;
					keyframe.value = value;
					keyframe.tangent = tangentData[animation.tangents[i]];
					if (keyframe.tangent == TangentType.BEZIER)
					{
						keyframe.prevTime = animation.inTangent[i][0] - time;
						keyframe.prevValue = animation.inTangent[i][1] - value;
						keyframe.nextTime = animation.outTangent[i][0] - time;
						keyframe.nextValue = animation.outTangent[i][1] - value;
					}
					
					track.keyList.push(keyframe);
					
					if (startTime > time) startTime = time;
					if (endTime < time) endTime = time;
				}
				
				if (n == 0)
				{
					startTime = 0;
					endTime = 0;
				}
			}
			
			for (j = 0; j < 3; j++) 
			{
				track = scales[j];
				track.startTime = startTime;
				track.endTime = endTime;
			}
			
			return result;
		}
		
		private function toM3DCurveAnimation(animation:ColladaAnimationData):M3DCurveTrack
		{
			var result:M3DCurveTrack = new M3DCurveTrack();
			
			result.loop = true;
			result.keyList = new Vector.<M3DKeyframe>;
			
			var tangentData:Object = {
				"LINEAR": TangentType.LINER,
				"BEZIER": TangentType.BEZIER,
				"CARDINAL": TangentType.LINER,
				"HERMITE": TangentType.LINER,
				"BSPLINE": TangentType.LINER,
				"STEP": TangentType.STEP
			}
			
			result.startTime = Number.MAX_VALUE;
			result.endTime = -Number.MAX_VALUE;
			
			var n:int = animation.times.length;
			for (var i:int = 0; i < n; i++) 
			{
				var keyframe:M3DKeyframe = new M3DKeyframe();
				var time:Number = animation.times[i];
				var value:Number = animation.values[i];
				keyframe.time = time;
				keyframe.value = value;
				keyframe.tangent = tangentData[animation.tangents[i]];
				if (keyframe.tangent == TangentType.BEZIER)
				{
					//___trace("IN", animation.inTangent[i][0]-time);
					//___trace("OT", animation.outTangent[i][0]-time);
					keyframe.prevTime = animation.inTangent[i][0] - time;
					keyframe.prevValue = animation.inTangent[i][1] - value;
					keyframe.nextTime = animation.outTangent[i][0] - time;
					keyframe.nextValue = animation.outTangent[i][1] - value;
				}
				
				result.keyList.push(keyframe);
				
				if (result.startTime > time) result.startTime = time;
				if (result.endTime < time) result.endTime = time;
			}
			
			if (n == 0)
			{
				result.startTime = 0;
				result.endTime = 0;
			}
			return result;
		}
		
		private function toM3DMatrixAnimation(animation:ColladaAnimationData):M3DMatrixTrack
		{
			var result:M3DMatrixTrack = new M3DMatrixTrack();
			
			result.loop = true;
			result.timeList = Vector.<Number>(animation.times);
			result.matrixList = new Vector.<Vector.<Number>>;
			result.tangentList = new Vector.<int>;
			
			var tangentData:Object = {
				"LINEAR": TangentType.LINER,
				"BEZIER": TangentType.LINER,
				"CARDINAL": TangentType.LINER,
				"HERMITE": TangentType.LINER,
				"BSPLINE": TangentType.LINER,
				"STEP": TangentType.STEP
			}
			result.startTime = Number.MAX_VALUE;
			result.endTime = -Number.MAX_VALUE;
			
			var n:int = animation.values.length;
			for (var i:int = 0; i < n; i++) 
			{
				var tangent:int = (tangentData[animation.tangents[i]] === undefined)? TangentType.LINER : tangentData[animation.tangents[i]];
				result.tangentList.push(tangent);
				result.matrixList.push(ColladaUtil.ArrayToMatrix3D(animation.values[i]).rawData);
				var time:Number = result.timeList[i];
				if (result.startTime > time) result.startTime = time;
				if (result.endTime < time) result.endTime = time;
			}
			
			if (n == 0)
			{
				result.startTime = 0;
				result.endTime = 0;
			}
			
			return result;
		}
		
		private function toM3DMaerialAnimation(data:Object):M3DAnimation
		{
			var result:M3DAnimation = new M3DAnimation();
			result.type = M3DAnimation.TYPE_MATERIAL;
			result.material = new M3DTrackUV();
			var noData:Boolean = true;
			for (var key:String in data)
			{
				noData = false;
				var animation:ColladaAnimationData = data[key];
				if (animation.type == "offsetU")
				{
					result.material.offsetU = toM3DCurveAnimation(animation);
				}
				if (animation.type == "offsetV")
				{
					result.material.offsetV = toM3DCurveAnimation(animation);
				}
			}
			
			if (noData) result = null;
			return result;
		}
		
		private function toM3DAnimation(data:Object):M3DAnimation 
		{
			var result:M3DAnimation = new M3DAnimation();
			for (var key:String in data)
			{
				var animation:ColladaAnimationData = data[key];
				if (animation.type == "matrix")
				{
					result.type = M3DAnimation.TYPE_MATRIX;
					result.matrix = toM3DMatrixAnimation(animation);
				}
				else
				{
					var target:Array = animation.type.split(".");
					result.type = M3DAnimation.TYPE_CURVE;
					if (target[0] == "translation")
					{
						if (result.position == null) result.position = new M3DTrackXYZ();
						if (target[1] == "X") result.position.x = toM3DCurveAnimation(animation);
						if (target[1] == "Y") result.position.y = toM3DCurveAnimation(animation);
						if (target[1] == "Z") result.position.z = toM3DCurveAnimation(animation);
					}
					if (target[0] == "rotationX")
					{
						if (result.rotation == null) result.rotation = new M3DTrackXYZ();
						result.rotation.x = toM3DCurveAnimation(animation);
					}
					if (target[0] == "rotationY")
					{
						if (result.rotation == null) result.rotation = new M3DTrackXYZ();
						result.rotation.y = toM3DCurveAnimation(animation);
					}
					if (target[0] == "rotationZ")
					{
						if (result.rotation == null) result.rotation = new M3DTrackXYZ();
						result.rotation.z = toM3DCurveAnimation(animation);
					}
					if (target[0] == "scale")
					{
						result.scale = toM3DScaleAnimation(animation);
					}
				}
			}			
			return result;
		}
		
		private function toM3DGeometry(geometry:ColladaGeometryNode):M3DGeometry 
		{
			var geometryData:ColladaGeometryData = geometry.data;
			var data:ColladaGeometryData = geometryData.getFixedData(option.toColladaOption());
			
			var result:M3DMeshGeometry = new M3DMeshGeometry();
			if (data.vertexIndices.length > 0) result.vertexIndices = Vector.<uint>(data.vertexIndices);
			if (data.normalList.length > 0) result.normals = Vector.<Number>(data.normalList);
			if (data.positionList.length > 0) result.vertices = Vector.<Number>(data.positionList);
			if (data.tangent4List.length > 0) result.tangents = Vector.<Number>(data.tangent4List);
			if (data.uvList.length > 0) result.uvs = Vector.<Number>(data.uvList);
			if (data.jointList.length > 0) result.boneIndices = Vector.<Number>(data.jointList);
			if (data.weightList.length > 0) result.weights = Vector.<Number>(data.weightList);
			return result;
		}
		
		private function toM3DMaterial(material:ColladaMaterialNode):M3DMaterial 
		{
			var result:M3DMaterial = new M3DMaterial();
			var effect:ColladaEffectNode = collada.getEffectByID(material.effectID);
			result.name = material.name;
			result.alpha = effect.alpha;
			result.diffusePath = effect.diffuseTexture? collada.getImageByID(effect.diffuseTexture).path : "";
			result.normalPath = effect.normalTexture? collada.getImageByID(effect.normalTexture).path : "";
			result.opacityPath = effect.transparentTexture? collada.getImageByID(effect.transparentTexture).path : "";
			result.diffuseColor = effect.diffuseColor;
			result.smoothing = true;
			result.mipmap = Mipmap.MIPLINEAR;
			result.tiling = Tiling.WRAP;
			result.doubleSided = false;
			result.blendMode = BlendMode.NORMAL;
			result.animation = toM3DMaerialAnimation(effect.animation);
			
			return result;
		}
		
	}

}