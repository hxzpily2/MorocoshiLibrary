package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColladaGeometryNode extends ColladaNode
	{
		public var surfaces:Vector.<ColladaSurface>;
		public var data:ColladaGeometryData;
		
		public function ColladaGeometryNode() 
		{
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
			
			surfaces = new Vector.<ColladaSurface>;
			data = new ColladaGeometryData();
			
			var mesh:XML = xml.mesh[0];
			if (!mesh) return;
			
			data.parseSourceData(mesh, mesh.vertices[0]);
			data.vertexPositionList = [];
			
			//サーフェイス数分ループ
			var indexBegin:int = 0;
			for each(var triangle:XML in mesh.triangles)
			{
				var surface:ColladaSurface = new ColladaSurface();
				surfaces.push(surface);
				
				var triCount:int = XMLUtil.getAttrNumber(triangle, "count", 0);
				surface.indexBegin = indexBegin;
				surface.numTriangle = triCount;
				surface.materialID = XMLUtil.getAttrString(triangle, "material", "");
				indexBegin += triCount * 3;
				
				//ポリゴン無し
				if (triCount == 0) continue;
				
				var maxOffset:int = -1;
				var offsetList:Array = [];
				var semanticList:Array = [];
				var exsistInput:Object = { };
				
				for each(var input:XML in triangle.input)
				{
					var offset:int = XMLUtil.getAttrNumber(input, "offset", 0);
					//アトリビュート名（NORMALとか）
					var semantic:String = XMLUtil.getAttrString(input, "semantic", "");
					//最大offset値を調べて後でループの区切りに使う
					if (maxOffset < offset) maxOffset = offset;
					
					//TEXCOORDが同一頂点に複数ある場合もある。現時点では対応できないのでスキップしちゃう
					if (exsistInput[semantic]) continue;
					
					exsistInput[semantic] = true;
					offsetList.push(offset);
					semanticList.push(semantic);
					data.linkMap(semantic, XMLUtil.getAttrString(input, "source", "").substr(1), collector);
				}
				maxOffset++;
				
				//UVW?値をUVに減らす
				var uvData:Array = data.getInputData(ColladaGeometryData.TEXCOORD);
				if (uvData)
				{
					for each(var uv:Array in uvData)
					{
						var temp:Array = [uv[0], uv[1]];
						uv[0] = temp[0];
						uv[1] = 1 - temp[1];
						uv.length = 2;
					}
				}
				
				//頂点情報がないならスキップ
				if (maxOffset <= 0)
				{
					collector.addMiscLog("noOffset", "頂点情報がありません。");
					continue;
				}
				
				//全頂点情報インデックス
				var indexList:Array = ColladaUtil.toNumberArray(triangle.p[0]);
				//頂点数分ループ
				for (var i:int = 0; i < triCount * 3; i++)
				{
					//POSITIONとかNORMALとかの要素の種類の数だけループ
					for (var j:int = 0; j < offsetList.length; j++) 
					{
						var index:int = indexList[i * maxOffset + offsetList[j]];
						var semanticKey:String = semanticList[j];
						if (semanticKey == ColladaGeometryData.VERTEX)
						{
							data.vertexPositionList.push(index);
						}
						data.getList(semanticKey).push(data.getInputData(semanticKey)[index]);
					}
				}
			}
			data.createTangent4();
		}
		
	}

}