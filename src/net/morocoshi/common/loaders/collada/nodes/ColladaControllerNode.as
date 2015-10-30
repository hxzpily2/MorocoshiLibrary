package net.morocoshi.common.loaders.collada.nodes 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColladaControllerNode extends ColladaNode 
	{
		public var shapeMatrix:Matrix3D;
		public var skinLink:String;
		public var weightData:ColladaGeometryData;
		//重みが0ではないウェイトがいくつあるか
		public var numWeight:int;
		
		public function ColladaControllerNode() 
		{
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void 
		{
			super.parse(xml, collector);
			
			var skin:XML = xml.skin[0];
			if (!skin) return;
			
			//1頂点にもてるウェイトの限界
			var weightLimit:int = collector.option.halfWeight? 4 : 8;
			numWeight = 0;
			
			skinLink = XMLUtil.getAttrString(skin, "source", "");
			shapeMatrix = ColladaUtil.toMatrix3D(skin.bind_shape_matrix);
			
			weightData = new ColladaGeometryData();
			weightData.parseSourceData(skin, null);
			var maxOffset:int = -1;
			var offsetList:Array = [];
			var semanticList:Array = [];
			var exsistInput:Object = { };
			
			var weightsNode:XML = skin.vertex_weights[0];
			if (!weightsNode) return;
			
			for each(var input:XML in weightsNode.input)
			{
				var offset:int = XMLUtil.getAttrNumber(input, "offset", 0);
				//アトリビュート名（NORMALとか）
				var semantic:String = XMLUtil.getAttrString(input, "semantic", "");
				//最大offset値を調べて後でループの区切りに使う
				if (maxOffset < offset) maxOffset = offset;
				
				//同名アトリビュートが同一頂点に複数ある場合もある。現時点では対応できないのでスキップしちゃう
				if (exsistInput[semantic]) continue;
				
				exsistInput[semantic] = true;
				offsetList.push(offset);
				semanticList.push(semantic);
				weightData.linkMap(semantic, XMLUtil.getAttrString(input, "source", "").substr(1), collector);
			}
			maxOffset++;
			weightData.parseJointMatrix(skin.joints[0], collector, shapeMatrix);
			
			//ボーン情報がないならスキップ
			if (maxOffset <= 0)
			{
				collector.addMiscLog("noOffset2", "ボーン情報がありません。");
				return;
			}
			
			var vcount:Array = ColladaUtil.toNumberArray(weightsNode.vcount[0]);
			//全頂点情報インデックス
			var indexList:Array = ColladaUtil.toNumberArray(weightsNode.v[0]);
			//頂点数分ループ
			//var count:int = XMLUtil.getAttrNumber(weightsNode, "count", 0);
			var indexCount:int = -1;
			var j:int;
			var k:int;
			var semanticKey:String;
			
			for (var i:int = 0; i < vcount.length; i++)
			{
				var dataList:Object = { };
				for (j = 0; j < offsetList.length; j++) 
				{
					semanticKey = semanticList[j];
					dataList[semanticKey] = [];
				}
				//JOINTとかWEIGHTとかの要素の種類の数だけループ
				for (k = 0; k < vcount[i]; k++)
				{
					for (j = 0; j < offsetList.length; j++) 
					{
						semanticKey = semanticList[j];
						indexCount++;
						var index:int = indexList[indexCount];
						var value:Number = weightData.getInputData(semanticKey)[index][0];
						dataList[semanticKey].push(value);
					}
				}
				var tempWeight:Array = [];
				var tempJoint:Array = [];
				var zeroWeight:Array = [];
				var zeroJoint:Array = [];
				var ws:Array = dataList["WEIGHT"];
				var js:Array = dataList["JOINT"];
				for (var g:int = 0; g < ws.length; g++) 
				{
					if (ws[g] != 0)
					{
						tempWeight.push(ws[g]);
						tempJoint.push(js[g]);
					}
					else if(zeroWeight.length == 0)
					{
						zeroWeight.push(ws[g]);
						zeroJoint.push(js[g]);
					}
				}
				if (tempWeight.length  == 0)
				{
					tempWeight = zeroWeight;
					tempJoint = zeroJoint;
					collector.addMiscLog("noWright", "合計のウェイトが0の頂点があります！");
				}
				dataList["WEIGHT"] = tempWeight;
				dataList["JOINT"] = tempJoint;
				
				//重みソート
				var swap:Array = [];
				var iw:int;
				for (iw = 0; iw < tempWeight.length; iw++) 
				{
					swap.push( { weight:tempWeight[iw], joint:tempJoint[iw] } );
				}
				
				swap.sortOn("weight", Array.NUMERIC | Array.DESCENDING);
				
				//ウェイトが4つを超えていたら
				if (swap.length > weightLimit)
				{
					collector.addMiscLog("weight" + swap.length, "ウェイトが" + swap.length + "個設定されています！応急処置で4個に丸め込みました！");
					swap.length = weightLimit;
				}
				
				//ノーマライズ
				tempWeight.length = 0;
				tempJoint.length = 0;
				var totalWeight:Number = 0;
				for (iw = 0; iw < swap.length; iw++)
				{
					totalWeight += swap[iw].weight;
					tempWeight.push(swap[iw].weight);
					tempJoint.push(swap[iw].joint);
				}
				
				var scale:Number = 1 / totalWeight;
				if (totalWeight != 0)
				{
					for (iw = 0; iw < tempWeight.length; iw++) 
					{
						tempWeight[iw] = tempWeight[iw] * scale;
					}
				}
				
				//8つに足りない枠は一番ウェイトが重いジョイントを重み0で埋める
				var weightCount:int = dataList["WEIGHT"].length;
				if (numWeight < weightCount) numWeight = weightCount;
				
				var zero:int = weightLimit - weightCount;
				for (k = 0; k < zero; k++) 
				{
					if (swap[0].joint === undefined)
					{
						collector.addMiscLog("jointError", "ジョイントデータのパースがなんだかおかしいです！");
					}
					dataList["JOINT"].push(swap[0].joint);
					dataList["WEIGHT"].push(0);
				}
				weightData.getList("JOINT").push(dataList["JOINT"]);
				weightData.getList("WEIGHT").push(dataList["WEIGHT"]);
			}
		}
		
	}

}
		/*
		<joints>
          <input semantic="JOINT" source="#geom-Plane01-skin1-joints"/>
          <input semantic="INV_BIND_MATRIX" source="#geom-Plane01-skin1-bind_poses"/>
        </joints>
        <vertex_weights count="3">
          <input semantic="JOINT" source="#geom-Plane01-skin1-joints" offset="0"/>
          <input semantic="WEIGHT" source="#geom-Plane01-skin1-weights" offset="1"/>
          <vcount>1 1 1</vcount>
          <v>1 0 0 0 0 0</v>
        </vertex_weights>*/