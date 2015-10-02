package net.morocoshi.moja3d.loader.exporters 
{
	import adobe.utils.CustomActions;
	import flash.display.BlendMode;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import net.morocoshi.alternativa.materials.TextureMaterial_back;
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
	import net.morocoshi.moja3d.loader.animation.M3DMatrixTrack;
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
		
		private function toM3DAnimation(animation:ColladaAnimationData):M3DAnimation 
		{
			var result:M3DAnimation = new M3DAnimation();
			result.type = M3DAnimation.TYPE_MATRIX;
			result.matrix = new M3DMatrixTrack();
			result.matrix.loop = true;
			result.matrix.timeList = Vector.<Number>(animation.times);
			result.matrix.matrixList = new Vector.<Vector.<Number>>;
			result.matrix.tangentList = new Vector.<int>;
			
			var tangentData:Object = {
				"LINEAR": TangentType.LINER,
				"BEZIER": TangentType.LINER,
				"CARDINAL": TangentType.LINER,
				"HERMITE": TangentType.LINER,
				"BSPLINE": TangentType.LINER,
				"STEP": TangentType.STEP
			}
			result.matrix.startTime = Number.MAX_VALUE;
			result.matrix.endTime = -Number.MAX_VALUE;
			
			var n:int = animation.values.length;
			for (var i:int = 0; i < n; i++) 
			{
				var tangent:int = (tangentData[animation.tangents[i]] === undefined)? TangentType.LINER : tangentData[animation.tangents[i]];
				result.matrix.tangentList.push(tangent);
				result.matrix.matrixList.push(ColladaUtil.ArrayToMatrix3D(animation.values[i]).rawData);
				var time:Number = result.matrix.timeList[i];
				if (result.matrix.startTime > time) result.matrix.startTime = time;
				if (result.matrix.endTime < time) result.matrix.endTime = time;
			}
			
			if (n == 0)
			{
				result.matrix.startTime = 0;
				result.matrix.endTime = 0;
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
			//if (data.tangent4List.length > 0) result.tangents = Vector.<Number>(data.tangent4List);
			if (data.uvList.length > 0) result.uvs = Vector.<Number>(data.uvList);
			if (data.jointList.length > 0) result.boneIndices = Vector.<Number>(data.jointList);
			if (data.weightList.length > 0) result.weights = Vector.<Number>(data.weightList);
			return result;
		}
		
		private function toM3DMaterial(material:ColladaMaterialNode):M3DMaterial 
		{
			var result:M3DMaterial = new M3DMaterial();
			var effect:ColladaEffectNode = collada.getEffectByID(material.effectID);
			result.alpha = effect.alpha;
			result.diffusePath = effect.diffuseTexture? collada.getImageByID(effect.diffuseTexture).path : "";
			result.opacityPath = effect.transparentTexture? collada.getImageByID(effect.transparentTexture).path : "";
			result.diffuseColor = effect.diffuseColor;
			result.smoothing = true;
			result.mipmap = Mipmap.MIPLINEAR;
			result.tiling = Tiling.WRAP;
			result.doubleSided = false;
			result.blendMode = BlendMode.NORMAL;
			
			return result;
		}
		
	}

}