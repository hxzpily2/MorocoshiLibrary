package net.morocoshi.common.loaders.fbx.expoters 
{
	import flash.utils.Dictionary;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXNumber;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用のジオメトリデータ
	 * 
	 * @author tencho
	 */
	public class FEGeometry 
	{
		public var id:Number;
		public var diffuseColor:Array = [0, 0, 0];
		
		/**識別名（FF11のMLTで後からジオメトリを割り当てる場合に使う）*/
		public var linkage:String;
		
		//頂点座標[x,y,z]のリスト
		public var vertexList:Array = [];
		//UV座標[u,v]のリスト
		public var uvList:Array = [];
		//頂点法線[x,y,z]のリスト
		public var normalList:Array = [];
		//頂点カラー[r,g,b,a]のリスト
		public var colorList:Array = [];
		
		public var vertexIndexList:Array = [];
		public var normalIndexList:Array = [];
		public var uvIndexList:Array = [];
		public var colorIndexList:Array = [];
		//各Faceのマテリアルの元のインデックスリスト
		///public var materialIndexList:Array = [];
		/**関連づいているオブジェクト*/
		public var object:FEObject;
		public var materialList:Vector.<FEMaterial> = new Vector.<FEMaterial>;
		//MIGではGeometryにもUserDataがあるので（どうやってFBXに渡すか？そもそも必要ない？）
		public var userData:Object = { };
		
		//全頂点のリスト[x,y,z,x,y,z...]
		private var vertices:Array = [];
		private var normals:Array = [];
		private var uvs:Array = [];
		private var colors:Array = [];
		private var hasColor:Boolean;
		
		private var _materialIDList:Array = [];
		private var vertexIndices:Array = [];
		private var colorIndices:Array = [];
		private var uvIndices:Array = [];
		private var materialIndices:Array = [];
		private var doublesided:Boolean = false;
		
		private var colorDictionary:Dictionary = new Dictionary();
		private var materialKeyList:Array = [];
		
		//同一頂点で違うカラーが割り当てられているかチェックするやつ
		private var vertexDictionary:Dictionary = new Dictionary();
		private var vertexExistCheck:Array = [];
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function FEGeometry() 
		{
		}
		
		public function get materialIDList():Array 
		{
			return _materialIDList;
		}
		
		public function parse():void
		{
			var i:int;
			var j:int;
			var n:int;
			var m:int;
			
			colorDictionary = new Dictionary();
			vertices = [];
			normals = [];
			uvs = [];
			colors = [];
			
			colorIndices = [];
			uvIndices = [];
			materialKeyList = [];
			
			n = uvList.length;
			for (i = 0; i < n; i++) 
			{
				uvs.push.apply(null, uvList[i]);
			}
			
			var colorCount:int = 0;
			n = colorList.length;
			for (i = 0; i < n; i++) 
			{
				var key:String = colorList[i].join(",");
				if (colorDictionary[key] == null)
				{
					colorDictionary[key] = colorCount++;
					colors.push.apply(null, colorList[i]);
				}
			}
			
			hasColor = colorIndexList.length > 0;
			//%%%ここがあやしい？
			if (!hasColor)
			{
				colors.push([1, 1, 1, 1]);
			}
			
			//全ポリゴン
			n = vertexIndexList.length;
			for (i = 0; i < n; i++) 
			{
				//1ポリゴンの各頂点の情報(頂点数は多分3か4)
				m = vertexIndexList[i].length - 1;
				for (j = 0; j <= m; j++)
				{
					var vtx:int = vertexIndexList[i][j];
					var nrm:int = normalIndexList[i][j];
					var uv:int = uvIndexList[i][j];
					if (hasColor)
					{
						try
						{
							var colorID:int = colorIndexList[i][j];
						}
						catch (e:Error)
						{
							throw e;
							//throw new Error([e, i, j, colorIndexList[0]].join(","));
						}
						//%%%ここでエラー
						var colorKey:String = colorList[colorID].join(",");
						var col:int = colorDictionary[colorKey];
						vtx = addVertexColor(vtx, col);
						colorIndices.push(col);
					}
					else
					{
						//%%%
						colorIndices.push(colors.length - 1);
					}
					if (j == m) vtx = -vtx - 1;
					vertexIndices.push(vtx);
					uvIndices.push(uv);
					normals.push.apply(null, normalList[nrm]);
				}
				//マテリアルID追加
				if (materialList[i])
				{
					materialKeyList.push(materialList[i].index);///materialIndexList[i]);
				}
			}
			n = vertexList.length;
			for (i = 0; i < n; i++) 
			{
				vertices.push.apply(null, vertexList[i]);
			}
		}
		
		public function listUpMaterialIndices(scene:FEScene):void
		{
			_materialIDList = [];
			materialIndices = [];
			
			var n:int = materialKeyList.length;
			var index:Object = { };
			var indexCount:int = 0;
			for (var i:int = 0; i < n; i++) 
			{
				var key:int = materialKeyList[i];
				if (index[key] == null)
				{
					_materialIDList.push(scene.materialList[key].id);
					index[key] = indexCount++;
				}
				materialIndices.push(index[key]);
			}
		}
		
		/**
		 * 頂点インデックス値と頂点カラーインデックス値を渡して、
		 * 同一頂点で違うカラーが割り当てられていれば頂点を複製してリストに追加する。
		 * 返り値は頂点の複製を考慮した新しい頂点インデックス値。
		 * @param	vtx
		 * @param	col
		 * @return
		 */
		private function addVertexColor(vtx:int, col:int):int 
		{
			var key:String = vertexList[vtx].join(",") + "," + col;
			if (!vertexDictionary[key])
			{
				var exist:Boolean = (vertexExistCheck.indexOf(vtx) != -1);
				if (!exist)
				{
					vertexExistCheck.push(vtx);
				}
				else
				{
					vertexList.push(vertexList[vtx].concat());
					vtx = vertexList.length - 1;
				}
				vertexDictionary[key] = vtx;
			}
			return vertexDictionary[key];
		}
		
		public function toFBXNode():FBXNode
		{
			var fbx:FBXNode;
			var fbx2:FBXNode;
			var node:FBXNode = new FBXNode(null, [id, "Geometry::", "Mesh"]);
			var p70:Array = [
				["Color", "ColorRGB", "Color", "", diffuseColor[0], diffuseColor[1], diffuseColor[2]]
			];
			FBXParser.addPropertyNode(node, p70);
			
			//Vertices
			fbx = new FBXNode(null, [new FBXNumber(vertices.length)]);
			fbx.addValue("a", vertices);
			node.addValue("Vertices", [fbx]);
			
			//VertexIndex
			fbx = new FBXNode(null, [new FBXNumber(vertexIndices.length)]);
			fbx.addValue("a", vertexIndices);
			node.addValue("PolygonVertexIndex", [fbx]);
			
			//Edge
			/*
			fbx = new FBXNode(null, [new FBXNumber(edges.length)]);
			fbx.addValue("a", edges);
			node.addValue("Edges", [fbx]);
			*/
			node.addValue("GeometryVersion", [124]);
			
			//Normal
			fbx = new FBXNode(null, [0]);
			fbx.addValue("Version", [101]);
			fbx.addValue("Name", [""]);
			fbx.addValue("MappingInformationType", ["ByPolygonVertex"]);
			fbx.addValue("ReferenceInformationType", ["Direct"]);
			fbx2 = new FBXNode(null, [new FBXNumber(normals.length)]);
			fbx2.addValue("a", normals);
			fbx.addValue("Normals", [fbx2]);
			node.addValue("LayerElementNormal", [fbx]);
			
			//UV
			fbx = new FBXNode(null, [0]);
			fbx.addValue("Version", [101]);
			fbx.addValue("Name", ["UVChannel_1"]);
			fbx.addValue("MappingInformationType", ["ByPolygonVertex"]);
			fbx.addValue("ReferenceInformationType", ["IndexToDirect"]);
			fbx2 = new FBXNode(null, [new FBXNumber(uvs.length)]);
			fbx2.addValue("a", uvs);
			fbx.addValue("UV", [fbx2]);
			fbx2 = new FBXNode(null, [new FBXNumber(uvIndices.length)]);
			fbx2.addValue("a", uvIndices);
			fbx.addValue("UVIndex", [fbx2]);
			node.addValue("LayerElementUV", [fbx]);
			
			//Visible
			/*
			fbx = new FBXNode(null, [0]);
			fbx.addValue("Version", [101]);
			fbx.addValue("Name", [""]);
			fbx.addValue("MappingInformationType", ["ByEdge"]);
			fbx.addValue("ReferenceInformationType", ["Direct"]);
			fbx2 = new FBXNode(null, [new FBXNumber(4)]);
			fbx2.addValue("a", [1, 0, 1, 1]);
			fbx.addValue("Visibility", [fbx2]);
			node.addValue("LayerElementVisibility", [fbx]);
			*/
			
			//Material
			fbx = new FBXNode(null, [0]);
			fbx.addValue("Version", [101]);
			fbx.addValue("Name", [""]);
			fbx.addValue("MappingInformationType", ["ByPolygon"]);
			fbx.addValue("ReferenceInformationType", ["IndexToDirect"]);
			fbx2 = new FBXNode(null, [new FBXNumber(materialIndices.length)]);
			fbx2.addValue("a", materialIndices);
			fbx.addValue("Materials", [fbx2]);
			node.addValue("LayerElementMaterial", [fbx]);
			
			//color
			fbx = new FBXNode(null, [0]);
			fbx.addValue("Version", [101]);
			fbx.addValue("Name", [""]);
			fbx.addValue("MappingInformationType", ["ByPolygonVertex"]);
			fbx.addValue("ReferenceInformationType", ["IndexToDirect"]);
			
			fbx2 = new FBXNode(null, [new FBXNumber(colors.length)]);
			fbx2.addValue("a", colors);
			fbx.addValue("Colors", [fbx2]);
			
			fbx2 = new FBXNode(null, [new FBXNumber(colorIndices.length)]);
			fbx2.addValue("a", colorIndices);
			fbx.addValue("ColorIndex", [fbx2]);
			node.addValue("LayerElementColor", [fbx]);
			
			//Element
			fbx = new FBXNode(null, [0]);
			fbx.addValue("Version", [100]);
			var layers:Array = ["LayerElementNormal", "LayerElementMaterial", "LayerElementUV", "LayerElementColor"];
			for (var i:int = 0; i < layers.length; i++) 
			{
				fbx2 = new FBXNode();
				fbx2.addValue("Type", [layers[i]]);
				fbx2.addValue("TypedIndex", [0]);
				fbx.addValue("LayerElement", [fbx2]);
			}
			node.addValue("Layer", [fbx]);
			
			return node;
		}
		
		/**
		 * 他のジオメトリから設定をコピーする。このメソッドはジオメトリを他Sceneから移す目的で使うため、一部の情報はコピーしません。
		 * @param	geom
		 */
		public function copyFrom(geom:FEGeometry):void 
		{
			//id = geom.id;
			//object = geom.object;
			diffuseColor = geom.diffuseColor.concat();
			linkage = geom.linkage;
			vertexList = geom.vertexList.concat();
			uvList = geom.uvList.concat();
			normalList = geom.normalList.concat();
			colorList = geom.colorList.concat();
			vertexIndexList = geom.vertexIndexList.concat();
			normalIndexList = geom.normalIndexList.concat();
			uvIndexList = geom.uvIndexList.concat();
			colorIndexList = geom.colorIndexList.concat();
			materialList = geom.materialList.concat();
			userData = geom.userData;
		}
		
	}

}