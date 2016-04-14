package net.morocoshi.moja3d.loader.optimize 
{
	import net.morocoshi.moja3d.agal.AGALInfo;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	import net.morocoshi.moja3d.loader.geometries.M3DSkinGeometry;
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DFaseSet 
	{
		public var faceList:Vector.<M3DFace>;
		public var geometry:M3DMeshGeometry;
		public var surfaces:Vector.<M3DSurface>;
		
		public var jointIndices:Vector.<int>;
		
		private var vertexCount:int;
		private var cacheVertex:Object;
		private var skin:Boolean;
		
		public function M3DFaseSet(skin:Boolean) 
		{
			this.skin = skin;
			faceList = new Vector.<M3DFace>;
			jointIndices = new Vector.<int>;
			surfaces = new Vector.<M3DSurface>;
		}
		
		private var existVertexKey:Object = { };
		private var existVertexNum:int = 0;
		
		public function addMeshFace(face:M3DFace):Boolean 
		{
			if (skin == true) throw new Error("無効な呼び出しです");
			
			var key1:String = face.vertices[0].getKey();
			var key2:String = face.vertices[1].getKey();
			var key3:String = face.vertices[2].getKey();
			
			var exist1:int = existVertexKey.hasOwnProperty(key1)? 0 : 1;
			var exist2:int = existVertexKey.hasOwnProperty(key2)? 0 : 1;
			var exist3:int = existVertexKey.hasOwnProperty(key3)? 0 : 1;
			
			var total:int = existVertexNum + exist1 + exist2 + exist3;
			if (total > AGALInfo.VERTEXDATA_LIMIT)
			{
				return false;
			}
			
			existVertexNum = total;
			existVertexKey[key1] = true;
			existVertexKey[key2] = true;
			existVertexKey[key3] = true;
			faceList.push(face);
			return true;
		}
		
		public function addSkinFace(face:M3DFace, limit:int):Boolean
		{
			if (skin == false) throw new Error("無効な呼び出しです");
			
			if (jointIndices.length == 0)
			{
				jointIndices = face.jointIndices.concat();
				faceList.push(face);
				return true;
			}
			
			//faceがもつインデックスが既にあるかチェック
			var unregister:Vector.<int> = new Vector.<int>;
			var n:int = face.jointIndices.length;
			for (var i:int = 0; i < n; i++) 
			{
				var joint:int = face.jointIndices[i];
				if (jointIndices.indexOf(joint) == -1)
				{
					//未登録のインデックスだけカウント
					unregister.push(joint);
				}
			}
			//現在の登録数+未登録数が限度以下ならFace追加
			if (unregister.length + jointIndices.length <= limit)
			{
				jointIndices = jointIndices.concat(unregister);
				faceList.push(face);
				return true;
			}
			
			//追加できない
			return false;
		}
		
		public function fix():void 
		{
			var i:int;
			var n:int;
			
			var surfaceData:Object = { };
			var surfaceList:Array = [];
			var materialList:Array = [];
			
			//マテリアルごとに分ける
			n = faceList.length;
			for (i = 0; i < n; i++) 
			{
				var face:M3DFace = faceList[i];
				if (surfaceData[face.material] === undefined)
				{
					surfaceData[face.material] = new Vector.<M3DFace>;
					surfaceList.push(surfaceData[face.material]);
					materialList.push(face.material);
				}
				surfaceData[face.material].push(face);
			}
			
			//ジオメトリ生成開始
			geometry = skin? new M3DSkinGeometry() : new M3DMeshGeometry();
			geometry.vertexIndices = new Vector.<uint>;
			
			if (surfaceList.length == 0 || surfaceList[0].length == 0 || surfaceList[0][0].vertices.length == 0) return;
			
			//適当な頂点の情報から各種配列を初期化
			var v0:M3DVertex = M3DFace(surfaceList[0][0]).vertices[0];
			if (v0.vertex)		geometry.vertices = new Vector.<Number>;
			if (v0.uv)			geometry.uvs = new Vector.<Number>;
			if (v0.normal)		geometry.normals = new Vector.<Number>;
			if (v0.color) 		geometry.colors = new Vector.<Number>;
			if (v0.tangent4)	geometry.tangents = new Vector.<Number>;
			
			if (skin)
			{
				var skinGeom:M3DSkinGeometry = geometry as M3DSkinGeometry;
				if (v0.weight1)		skinGeom.weights1 = new Vector.<Number>;
				if (v0.weight2)		skinGeom.weights2 = new Vector.<Number>;
				if (v0.boneIndex1)	skinGeom.boneIndices1 = new Vector.<Number>;
				if (v0.boneIndex2)	skinGeom.boneIndices2 = new Vector.<Number>;
			}
			
			
			surfaces.length = 0;
			
			vertexCount = -1;
			cacheVertex = { };
			var indexBegin:int = 0;
			n = surfaceList.length;
			for (i = 0; i < n; i++) 
			{
				var faces:Vector.<M3DFace> = surfaceList[i];
				
				if (faces.length == 0) continue;
				
				var surface:M3DSurface = new M3DSurface();
				surface.indexBegin = indexBegin;
				surface.numTriangle = faces.length;
				surface.material = materialList[i];
				surfaces.push(surface);
				indexBegin += surface.numTriangle * 3;
				
				nextGeometry(faces);
			}
			
			if (skin)
			{
				M3DSkinGeometry(geometry).fixJointIndex();
			}
		}
		
		private function nextGeometry(faces:Vector.<M3DFace>):void 
		{
			var n:int = faces.length;
			for (var i:int = 0; i < n; i++) 
			{
				var face:M3DFace = faces[i];
				for (var j:int = 0; j < 3; j++)
				{
					var v:M3DVertex = face.vertices[j];
					var key:String = v.getKey();
					if (cacheVertex.hasOwnProperty(key) == false)
					{
						vertexCount++;
						cacheVertex[key] = vertexCount;
						if (v.uv) 			geometry.uvs.push.apply(null, v.uv);
						if (v.vertex)		geometry.vertices.push.apply(null, v.vertex);
						if (v.normal)		geometry.normals.push.apply(null, v.normal);
						if (v.color) 		geometry.colors.push.apply(null, v.color);
						if (v.tangent4) 	geometry.tangents.push.apply(null, v.tangent4);
						if (skin)
						{
							var skinGeom:M3DSkinGeometry = geometry as M3DSkinGeometry;
							if (v.weight1) 		skinGeom.weights1.push.apply(null, v.weight1);
							if (v.weight2) 		skinGeom.weights2.push.apply(null, v.weight2);
							if (v.boneIndex1) 	skinGeom.boneIndices1.push.apply(null, v.boneIndex1);
							if (v.boneIndex2) 	skinGeom.boneIndices2.push.apply(null, v.boneIndex2);
						}
					}
					geometry.vertexIndices.push(cacheVertex[key]);
				}
			}
			trace("@@@@", geometry.vertices.length / 3);
		}
		
	}

}