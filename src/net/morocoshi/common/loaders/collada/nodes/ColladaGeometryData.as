package net.morocoshi.common.loaders.collada.nodes 
{
	import adobe.utils.CustomActions;
	import flash.geom.Matrix3D;
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaParseOption;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaGeometryData 
	{
		public var vertexIndices:Array;
		public var vertexPositionList:Array;
		
		public var positionList:Array;
		public var uvList:Array;
		public var normalList:Array;
		public var tangentList:Array;
		public var binormalList:Array;
		public var tangent4List:Array;
		
		public var jointList:Array;
		public var weightList:Array;
		
		private var sourceData:Object;
		private var inputData:Object = {};
		private var sourceLink:Object = { };
		
		static public const VERTEX:String = "VERTEX";
		static public const NORMAL:String = "NORMAL";
		static public const TEXCOORD:String = "TEXCOORD";
		static public const TEXTANGENT:String = "TEXTANGENT";
		static public const TEXBINORMAL:String = "TEXBINORMAL";
		static public const TANGENT4:String = "TANGENT4";
		static public const JOINT:String = "JOINT";
		static public const WEIGHT:String = "WEIGHT";
		static public const INV_BIND_MATRIX:String = "INV_BIND_MATRIX";
		
		public function ColladaGeometryData() 
		{
			vertexIndices = [];
			
			positionList = [];
			normalList = [];
			tangentList = [];
			binormalList = [];
			uvList = [];
			
			tangent4List = [];
			
			jointList = [];
			weightList = [];
		}
		
		public function getList(semantic:String):Array 
		{
			var target:Array;
			switch(semantic)
			{
				case VERTEX: target = positionList; break;
				case NORMAL: target = normalList; break;
				case TEXCOORD: target = uvList; break;
				case TEXTANGENT: target = tangentList; break;
				case TEXBINORMAL: target = binormalList; break;
				case TANGENT4: target = tangent4List; break;
				case JOINT: target = jointList; break;
				case WEIGHT: target = weightList; break;
			}
			return target;
		}
		
		public function createTangent4():void
		{
			tangent4List = [];
			var n:int = tangentList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var tan:Array = tangentList[i];
				var bin:Array = binormalList[i];
				var nrm:Array = normalList[i];
				tangent4List.push(ColladaUtil.getTangent4(tan, bin, nrm));
			}
		}
		
		/**
		 * 最適化された頂点情報を取得する。スキン用ジオメトリならウェイト情報などが結合される。
		 * @param	skin
		 * @return
		 */
		public function getFixedData(option:ColladaParseOption):ColladaGeometryData
		{
			var result:ColladaGeometryData = new ColladaGeometryData();
			
			var types:Array = [];
			if (option.exportPosition) types.push(VERTEX);
			if (option.exportNormal) types.push(NORMAL);
			if (option.exportUV) types.push(TEXCOORD);
			if (option.exportTangent4) types.push(TANGENT4);
			if (jointList.length)
			{
				types.push(JOINT);
				types.push(WEIGHT);
			}
			
			var numList:int = getList(VERTEX).length;
			var numTypes:int = types.length;
			var indexCache:Object = { };
			var indexCount:int = -1;
			var t:int;
			
			for (var i:int = 0; i < numList; i++) 
			{
				var key:String = "";
				for (t = 0; t < numTypes; t++)
				{
					var list:Array = getList(types[t]);
					key += list[i].join(",") + "_";
				}
				if (indexCache[key] !== null)
				{
					indexCount++;
					indexCache[key] = indexCount;
					for (t = 0; t < numTypes; t++)
					{
						var type:String = types[t];
						result.getList(type).push.apply(null, getList(type)[i]);
					}
				}
				result.vertexIndices.push(indexCache[key]);
			}
			
			return result;
		}
		
		public function getMatrixList():Array
		{
			return sourceData[INV_BIND_MATRIX];
		}
		
		public function linkMap(semantic:String, sourceID:String, collector:ColladaCollector):void
		{
			sourceLink[semantic] = sourceData[sourceID];
			inputData[semantic] = JSON.parse(JSON.stringify(sourceData[sourceID]));
			
			if (semantic != JOINT) return;
			
			//文字列をインデックスへ変換
			var cache:Object = { };
			var boneCount:int = -1;
			var data:Array = inputData[semantic];
			for (var i:int = 0; i < data.length; i++)
			{
				var key:String = data[i][0];
				if (cache[key] === undefined)
				{
					boneCount++;
					cache[key] = boneCount;
					collector.mapJointID(key, boneCount);
				}
				data[i][0] = cache[key];
			}
		}
		
		public function parseSourceData(node:XML, subNode:XML):void 
		{
			sourceData = { };
			for each(var source:XML in node.source)
			{
				var id:String = XMLUtil.getAttrString(source, "id", "");
				if (id == "" || !source.technique_common[0]) continue;
				var segment:int = XMLUtil.getAttrNumber(source.technique_common[0].accessor[0], "stride", 3);
				if (source.float_array[0])
				{
					sourceData[id] = ColladaUtil.toNumberArrayList(source.float_array[0], segment);
				}
				if (source.Name_array[0])
				{
					sourceData[id] = ColladaUtil.toStringArrayList(source.Name_array[0], segment);
				}
			}
			
			//メッシュジオメトリの場合頂点のリンク情報をパースする
			if (subNode && subNode.input[0])
			{
				var linkID:String = XMLUtil.getAttrString(subNode.input[0], "source", "").substr(1);
				var vertexID:String = XMLUtil.getAttrString(subNode, "id", "");
				if (vertexID)
				{
					sourceData[vertexID] = sourceData[linkID];
					delete sourceData[linkID];
				}				
			}
		}
		
		public function getInputData(semantic:String):Array 
		{
			return inputData[semantic];
		}
		
		public function getJoineNames():Array 
		{
			var result:Array = [];
			for each(var list:Array in sourceLink[JOINT])
			{
				result.push(list[0]);
			}
			return result;
		}
		
		public function attachSkinData(data:ColladaGeometryData):void 
		{
			jointList = [];
			weightList = [];
			var n:int = vertexPositionList.length;	
			for (var i:int = 0; i < n; i++)
			{
				var index:int = vertexPositionList[i];
				jointList.push(data.jointList[index]);
				weightList.push(data.weightList[index]);
			}
		}
		
		public function parseJointMatrix(xml:XML, collector:ColladaCollector):void 
		{
			for each(var input:XML in xml.input)
			{
				var semantic:String = XMLUtil.getAttrString(input, "semantic", "");
				var source:String = XMLUtil.getAttrString(input, "source", "");
				if (semantic == INV_BIND_MATRIX)
				{
					var data:Array = sourceData[source.substr(1)];
					var n:int = data.length;
					for (var i:int = 0; i < n; i++) 
					{
						var key:String = sourceLink[JOINT][i];
						collector.jointMatrixMap[key] = ColladaUtil.ArrayToMatrix3D(data[i]);
					}
					return;
				}
			}
		}
		
	}

}