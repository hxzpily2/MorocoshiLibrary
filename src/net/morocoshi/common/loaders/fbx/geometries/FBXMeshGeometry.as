package net.morocoshi.common.loaders.fbx.geometries 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.loaders.fbx.bones.FBXBoneDeformer;
	import net.morocoshi.common.loaders.fbx.bones.FBXSkinDeformer;
	import net.morocoshi.common.loaders.fbx.FBXConst;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParseCollector;
	import net.morocoshi.common.loaders.fbx.FBXParseOption;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	import net.morocoshi.common.loaders.fbx.materials.FBXSurface;
	import net.morocoshi.common.math.geom.TangentUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXMeshGeometry extends FBXGeometry 
	{
		public var hasNormal:Boolean = false;
		public var hasUV:Boolean = false;
		public var hasColor:Boolean = false;
		public var hasTangent4:Boolean = false;
		
		/**サーフェイスデータのリスト。全てにデータがあるとは限らずnullの場所もある？*/
		public var surfaceList:Vector.<FBXSurface> = new Vector.<FBXSurface>;
		public var surfaceIndices:Vector.<int> = new Vector.<int>;
		public var rawSurfaceIndex:Object;
		public var vertexIndices:Vector.<uint> = new Vector.<uint>;
		//public var localVertexIndices:Vector.<uint> = new Vector.<uint>;
		public var vertices:Vector.<Number> = new Vector.<Number>;
		public var uvs:Vector.<Number> = new Vector.<Number>;
		public var normals:Vector.<Number> = new Vector.<Number>;
		public var tangent4:Vector.<Number> = new Vector.<Number>;
		public var colors:Vector.<Number> = new Vector.<Number>;
		
		public var isSingleSurface:Boolean = true;
		public var numTriangle:int;
		public var meshColor:uint;
		public var autoRepeatTexture:Boolean = true;
		public var repeatMargin:Number = 0.001;
		public var numSurface:int = 0;
		public var skin:FBXSkinDeformer;
		/**本来の頂点インデックスリスト。主にスキン用に使うデータ*/
		public var localVertexIndexLink:Dictionary;
		
		/**
		 * 
		 * @param	node
		 */
		public function FBXMeshGeometry(node:FBXNode = null)
		{
			super(node);
		}
		
		/**
		 * ジオメトリノードを渡してIDだけをパース
		 * @param	node
		 */
		override public function parse(node:FBXNode):void 
		{
			super.parse(node);
		}
		
		/**
		 * ジオメトリID以外の残りのデータを全てパース
		 * @param	node
		 */
		public function parseRest(node:FBXNode, collector:FBXParseCollector):Boolean
		{
			var option:FBXParseOption = collector.option;
			localVertexIndexLink = new Dictionary();
			param = FBXParser.parseProperties(node.Properties70);
			meshColor = param ? param.Color : 0x000000;
			
			var i:int;
			var n:int;
			var elm:FBXNode;
			var list:Array;
			
			//頂点座標(xyzセットにした)
			var verticesLocal:Vector.<Vector3D> = new Vector.<Vector3D>;
			var indicesLocal:Vector.<uint> = new Vector.<uint>;
			
			if (node.Vertices)
			{
				elm = node.Vertices[0][0];
				list = elm.a[0];
				n = list.length;
				for (i = 0; i < n; i += 3) 
				{
					verticesLocal.push(new Vector3D(list[i], list[i + 1], list[i + 2]));
				}
			}
			
			//頂点インデックス
			if (node.PolygonVertexIndex)
			{
				elm = node.PolygonVertexIndex[0][0];
				list = elm.a[0];
				n = list.length;
				for (i = 0; i < n; i++) 
				{
					var t:int = list[i];
					//負数は*-1して-1する
					if (t < 0)
					{
						if ((i + 1) % 3 != 0)
						{
							collector.alert("三角ポリゴン以外には対応していません！");
							return false;
						}
						t = t * -1 -1;
					}
					indicesLocal.push(t);
				}
			}
			
			//頂点カラー
			var colorsLocal:Vector.<Array> = new Vector.<Array>;
			hasColor = false;
			if (node.LayerElementColor && option.deleteVertexColor == false)
			{
				elm = node.LayerElementColor[0][0];
				var vertexMapType:String = elm.MappingInformationType[0][0];
				var vertexRefType:String = elm.ReferenceInformationType[0][0];
				
				if (vertexMapType != FBXConst.BY_POLYGON_VERTEX || vertexRefType != FBXConst.INDEX_TO_DIRECT)
				{
					collector.alert("[" + vertexMapType + "," + vertexRefType + "]タイプの頂点カラーはまだパースできません！");
					return false;
				}
				var colorData:Array = elm.Colors[0][0].a[0];
				list = elm.ColorIndex[0][0].a[0];
				n = list.length;
				for (i = 0; i < n; i++)
				{
					var idx:int = list[i] * 4;
					var r:Number = colorData[idx];
					var g:Number = colorData[idx + 1];
					var b:Number = colorData[idx + 2];
					var a:Number = colorData[idx + 3];
					var rgba:Array = [r, g, b, a];
					colorsLocal.push(rgba);
				}
				hasColor = colorsLocal.length > 0;
			}
			
			//マテリアル
			var maxSurface:int = 0;
			/*
				LayerElementMaterial: 0 {
					Version: 101
					Name: ""s
					MappingInformationType: "ByPolygon"
					ReferenceInformationType: "IndexToDirect"
					Materials: *12 {
						a: 6,6,6,6,0,0,6,6,0,0,6,6 //Materialリストのインデックス
					} 
				}
			 */
			if (node.LayerElementMaterial)
			{
				elm = node.LayerElementMaterial[0][0];
				isSingleSurface = (elm.MappingInformationType[0][0] == FBXConst.ALLSAME);
				if(!isSingleSurface)
				{
					var materialRefType:String = elm.ReferenceInformationType[0][0];
					if (materialRefType != FBXConst.INDEX_TO_DIRECT)
					{
						collector.alert("[" + materialRefType + "]タイプのマテリアル貼りには対応していません！");
						return false;
					}
					list = elm.Materials[0][0].a[0];
					n = list.length;
					for (i = 0; i < n; i++) 
					{
						var currentSurface:int = list[i];
						if (maxSurface < currentSurface) maxSurface = currentSurface;
						surfaceIndices.push(currentSurface);
					}
				}
			}
			numSurface = maxSurface + 1;
			
			//UV
			var uvsLocal:Vector.<Array> = new Vector.<Array>;
			var uvIndicesLocal:Vector.<uint> = new Vector.<uint>;
			hasUV = false;
			if (node.LayerElementUV && option.deleteUV == false)
			{
				list = node.LayerElementUV;
				n = list.length;
				for (i = 0; i < n; i++) 
				{
					elm = list[i][0];
					//とりあえず、1番目のUVチャンネルだけ使うようにしておく
					if (elm.$args[0] != 0) continue;
					var uvMapType:String = elm.MappingInformationType[0][0];
					var uvRefType:String = elm.ReferenceInformationType[0][0];
					if (uvMapType != FBXConst.BY_POLYGON_VERTEX || uvRefType != FBXConst.INDEX_TO_DIRECT)
					{
						collector.alert("[" + uvMapType + "," + uvRefType + "]このタイプのUVはまだパースできません！");
						return false;
					}
					
					var uvList:Array = elm.UV[0][0].a[0];
					var uvIdx:Array = elm.UVIndex[0][0].a[0];
					for (var j:int = 0; j < uvList.length; j += 2)
					{
						var uvSet:Array = [uvList[j], 1 - uvList[j + 1]];
						uvsLocal.push(uvSet);
					}
					for (var k:int = 0; k < uvIdx.length; k++)
					{
						uvIndicesLocal.push(uvIdx[k]);
					}
				}
				hasUV = uvsLocal.length > 0;
			}
			
			//法線
			var normalsLocal:Vector.<Array> = new Vector.<Array>;
			var normalKeys:Vector.<String> = new Vector.<String>;
			hasNormal = false;
			
			if (node.LayerElementNormal && option.deleteNormal == false)
			{
				elm = node.LayerElementNormal[0][0];
				
				var normalRefType:String = elm.ReferenceInformationType[0][0];
				var normalMapType:String = elm.MappingInformationType[0][0];
				if (normalRefType != FBXConst.DIRECT || (normalMapType != FBXConst.BY_POLYGON_VERTEX && normalMapType != FBXConst.BY_VERTICE))
				{
					collector.alert("[" + normalRefType + "," + normalMapType + "]の法線はまだパースできません！");
					return false;
				}
				
				//法線を取り出す
				list = elm.Normals[0][0].a[0];
				n = list.length;
				for (i = 0; i < n; i += 3)
				{
					var normalSet:Array = [list[i], list[i + 1], list[i + 2]];
					normalKeys.push(normalSet.join(","));
					normalsLocal.push(normalSet);
				}
				hasNormal = normalsLocal.length > 0;
			}
			
			//Tangent4
			var tangent4Local:Vector.<Array> = new Vector.<Array>;
			var tangentKeys:Vector.<String> = new Vector.<String>;
			hasTangent4 = false;
			
			if (option.simpleTangent4 == false && node.LayerElementTangent && node.LayerElementBinormal && option.deleteTangent4 == false)
			{
				var elmT:FBXNode = node.LayerElementTangent[0][0];
				var elmB:FBXNode = node.LayerElementBinormal[0][0];
				
				var tangentMapType:String = elmT.MappingInformationType[0][0];
				var tangentRefType:String = elmT.ReferenceInformationType[0][0];
				if ((tangentMapType != FBXConst.BY_VERTICE && tangentMapType != FBXConst.BY_POLYGON_VERTEX) || tangentRefType != FBXConst.DIRECT)
				{
					collector.alert("[" + tangentMapType + "," + tangentRefType + "]のTangentデータはまだパースできません！");
					return false;
				}
				var mapTypeB:String = elmT.MappingInformationType[0][0];
				var refTypeB:String = elmT.ReferenceInformationType[0][0];
				if ((mapTypeB != FBXConst.BY_VERTICE && mapTypeB != FBXConst.BY_POLYGON_VERTEX) || refTypeB != FBXConst.DIRECT)
				{
					collector.alert("[" + mapTypeB + "," + refTypeB + "]のBinormalデータはまだパースできません！");
					return false;
				}
				
				var listT:Array = elmT.Tangents[0][0].a[0];
				var listB:Array = elmB.Binormals[0][0].a[0];
				if (listT.length != listB.length)
				{
					collector.alert("TangentとBinormalの要素数が一致しません！");
					return false;
				}
				
				n = listT.length;
				for (i = 0; i < n; i += 3)
				{
					var tangent:Array = [listT[i], listT[i + 1], listT[i + 2]];
					var binormal:Array = [listB[i], listB[i + 1], listB[i + 2]];
					var t4Array:Array = getTangent4(tangent, binormal, normalsLocal[i / 3]);
					tangent4Local.push(t4Array);
					tangentKeys.push(t4Array.join(","));
				}
				
				hasTangent4 = true;
			}
			
			//Tangent4がなければ計算するが、正確には計算できない。uv座標が無いと確実におかしくなる
			if (option.simpleTangent4 == false && hasTangent4 == false && option.deleteTangent4 == false)
			{
				collector.addMiscLog("calcNoTangent4", "★ジオメトリにTangent情報が無いため、UV座標から計算しました。");
				
				tangent4Local.length = 0;
				tangentKeys.length = 0;
				n = indicesLocal.length;
				var errorTangent4:Boolean = false;
				for (i = 0; i < n; i += 3)
				{
					for (var vti:int = 0; vti < 3; vti++)
					{
						var ii0:int = i + ((vti + 0) % 3);
						var ii1:int = i + ((vti + 1) % 3);
						var ii2:int = i + ((vti + 2) % 3);
						
						var vp0:Vector3D = verticesLocal[indicesLocal[ii0]];
						var vp1:Vector3D = verticesLocal[indicesLocal[ii1]];
						var vp2:Vector3D = verticesLocal[indicesLocal[ii2]];
						
						var uv0:Array = hasUV? uvsLocal[uvIndicesLocal[ii0]] : [0, 0];
						var uv1:Array = hasUV? uvsLocal[uvIndicesLocal[ii1]] : [0, 0];
						var uv2:Array = hasUV? uvsLocal[uvIndicesLocal[ii2]] : [0, 0];
						
						var nrmIndex:int = (normalMapType == FBXConst.BY_VERTICE)? indicesLocal[ii0] : ii0;
						var na:Array = normalsLocal[nrmIndex];
						
						var t4Vector:Vector3D = TangentUtil.calcTangentBinormalArray(vp0, vp1, vp2, uv0, uv1, uv2, na);
						if (t4Vector == null)
						{
							t4Vector = new Vector3D(0, 0, 1, 1);
							errorTangent4 = true;
						}
						var t4List:Array = [t4Vector.x, t4Vector.y, t4Vector.z, t4Vector.w];
						tangent4Local.push(t4List);
						tangentKeys.push(t4List.join(","));
					}
				}
				if (errorTangent4)
				{
					collector.addMiscLog("cantCalcTangent4", "★ポリゴンのUV値か頂点座標が不正な為Tangent4が計算できませんでした。");
				}
				hasTangent4 = true;
				
			}
			
			//頂点数と法線数等を合わせる
			var uvRepeat:Array = [];
			
			var obj:Object = { };
			var count:int = -1;
			//頂点の数だけ繰り返し
			n = indicesLocal.length;
			for (i = 0; i < n; i++) 
			{
				//頂点インデックスが同じでも法線、UVが違う場合は別の頂点にする
				var vtxIndex:int = indicesLocal[i];
				var uvIndex:int = hasUV? uvIndicesLocal[i] : -1;
				var t4Key:String = hasTangent4? tangentKeys[i] : "";
				var nrmKey:String;
				var normalIndex:int
				if (hasNormal)
				{
					normalIndex = (normalMapType == FBXConst.BY_VERTICE)? vtxIndex : i;
					nrmKey = normalKeys[normalIndex];
				}
				else
				{
					nrmKey = "";
				}
				
				var key:String = vtxIndex + "_" + nrmKey + "_" + uvIndex + "_" + t4Key;
				
				//新しい頂点だったら登録する
				if (obj[key] == null)
				{
					obj[key] = ++count;//0～
					var vt:Vector3D = verticesLocal[vtxIndex];
					vertices.push(vt.x, vt.y, vt.z);
					
					if (hasNormal)
					{
						normals.push.apply(null, normalsLocal[normalIndex]);
					}
					if (hasColor)
					{
						colors.push(colorsLocal[i][0], colorsLocal[i][1], colorsLocal[i][2], colorsLocal[i][3]);
					}
					/*
					else
					{
						colors.push(1, 1, 1, 1);
					}*/
					
					//UVがあれば追加、なければ適当に0をいれておく
					if (hasUV)
					{
						uvs.push.apply(null, uvsLocal[uvIndex]);
					}
					/*
					else
					{
						uvs.push(0, 0);
					}*/
					
					//TANGENTがあれば追加
					if (hasTangent4)
					{
						tangent4.push.apply(null, tangent4Local[i]);
					}
				}
				var index:int = obj[key];
				vertexIndices.push(index);
				localVertexIndexLink[index] = vtxIndex;
			}
			
			//三角ポリ数
			numTriangle = vertexIndices.length / 3;
			//マテリアル1個の場合はポリ数分増やす
			if (isSingleSurface)
			{
				//surfaceIndices.length;
				for (i = 0; i < numTriangle; i++) 
				{
					surfaceIndices.push(0);
				}
				isSingleSurface = false;
			}
			
			//UVのリピートチェックとか、半透明頂点アルファのチェックとか。
			rawSurfaceIndex = { };
			
			var extraSurfaceParam:Object = { };
			var extraCache:Object = { };
			
			for (i = 0; i < numTriangle; i++) 
			{
				var si:int = surfaceIndices[i];
				
				var i0:int = vertexIndices[i * 3 + 0];
				var i1:int = vertexIndices[i * 3 + 1];
				var i2:int = vertexIndices[i * 3 + 2];
				
				//3頂点のアルファがどれか1つでも1未満だったら、マテリアルを透過扱いにする為にサーフェイス番号を変える
				var transparentVertex:Boolean;
				if (hasColor)
				{
					var a0:Number = colors[i0 * 4 + 3];
					var a1:Number = colors[i1 * 4 + 3];
					var a2:Number = colors[i2 * 4 + 3];
					transparentVertex = (a0 < 1 || a1 < 1 || a2 < 1);
				}
				else
				{
					transparentVertex = false;
				}
				
				//3頂点のUVがどれか1つでも0～1の範囲外だったら、マテリアルをループさせる為にサーフェイス番号を変える
				var repeatTexture:Boolean;
				if (hasUV)
				{
					var i0u:Number = uvs[i0 * 2];
					var i0v:Number = uvs[i0 * 2 + 1];
					var i1u:Number = uvs[i1 * 2];
					var i1v:Number = uvs[i1 * 2 + 1];
					var i2u:Number = uvs[i2 * 2];
					var i2v:Number = uvs[i2 * 2 + 1];
					repeatTexture = autoRepeatTexture && (isRepeat(i0u, i0v, repeatMargin) || isRepeat(i1u, i1v, repeatMargin) || isRepeat(i2u, i2v, repeatMargin));
				}
				else
				{
					repeatTexture = false;
				}
				
				if (transparentVertex || repeatTexture)
				{
					var extraKey:String = si + "|" + transparentVertex + "|" + repeatTexture;
					if (extraCache[extraKey] == undefined)
					{
						maxSurface++;
						rawSurfaceIndex[maxSurface] = si;
						extraCache[extraKey] = maxSurface;
					}
					surfaceIndices[i] = extraCache[extraKey];
					var param:Object = extraSurfaceParam[surfaceIndices[i]] = { };
					param.hasTransparentVertex = transparentVertex;
					param.repeatTexture = repeatTexture;
				}
			}
			extraCache = null;
			
			//サーフェイスを組み直してマテリアルID順にする
			var surfaceSet:Array = [];
			n = surfaceIndices.length;
			for (i = 0; i < n; i++) 
			{
				var s:int = surfaceIndices[i];
				if (!surfaceSet[s])
				{
					surfaceSet[s] = [i];
				}
				else
				{
					surfaceSet[s].push(i);
				}
			}
			
			//サーフェイスリストで頂点インデックスの順番を組み直す
			swapVertexIndices(surfaceSet);
			var surfaceIndexCount:int = 0;
			for (i = 0; i < surfaceSet.length; i++)
			{
				if (!surfaceSet[i])
				{
					surfaceList[i] = null;
					continue;
				}
				var sf:FBXSurface = new FBXSurface();
				sf.index = i;
				sf.indexBegin = surfaceIndexCount;
				sf.numTriangle = surfaceSet[i].length;
				//サーフェイスに特殊パラメータが設定されている場合（半透明頂点アルファとか、リピート設定とか）
				var extra:Object = extraSurfaceParam[i]
				if (extra)
				{
					sf.hasTransparentVertex = extra.hasTransparentVertex;
					sf.repeatTexture = extra.repeatTexture;
				}
				surfaceList[i] = sf;
				surfaceIndexCount += sf.numTriangle * 3;
			}
			
			if (hasNormal && vertices.length != normals.length)
			{
				collector.alert("法線の数が一致しません！");
				return false;
			}
			return true;
		}
		
		private function isRepeat(u:Number, v:Number, margin:Number):Boolean 
		{
			return (u < -margin || u > 1 + margin || v < -margin || v > 1 + margin);
		}
		
		/**
		 * TangentとBinormalとNormalからTangent4を求める
		 * @param	tangent
		 * @param	binormal
		 * @param	normal
		 * @return
		 */
		private function getTangent4(tangent:Array, binormal:Array, normal:Array):Array 
		{
			var crossX:Number = normal[1] * tangent[2] - normal[2] * tangent[1];
			var crossY:Number = normal[2] * tangent[0] - normal[0] * tangent[2];
			var crossZ:Number = normal[0] * tangent[1] - normal[1] * tangent[0];
			var dot:Number = crossX * binormal[0] + crossY * binormal[1] + crossZ * binormal[2];
			var b:int = dot < 0 ? -1 : 1;
			return [tangent[0], tangent[1], tangent[2], b];
		}
		
		/**
		 * サーフェイスリストを渡して頂点インデックスの順番を組み直す
		 * @param	surfaces
		 */
		private function swapVertexIndices(surfaces:Array):void 
		{
			var vi:Vector.<uint> = vertexIndices.concat();
			vertexIndices.length = 0;
			var n:int = surfaces.length;
			for (var i:int = 0; i < n; i++)
			{
				if (!surfaces[i]) continue;
				var m:int = surfaces[i].length;
				for (var j:int = 0; j < m; j++) 
				{
					var index:int = surfaces[i][j];
					vertexIndices.push(vi[index * 3], vi[index * 3 + 1], vi[index * 3 + 2]);
				}
			}
		}
		
		/**
		 * 頂点や法線等をXYZ軸で反転する
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		override public function rescale(x:int, y:int, z:int):void 
		{
			super.rescale(x, y, z);
			var i:int;
			var n:int;
			
			n = vertices.length;
			for (i = 0; i < n; i+= 3)
			{
				if (x < 0) vertices[i] *= -1;
				if (y < 0) vertices[i + 1] *= -1;
				if (z < 0) vertices[i + 2] *= -1;
			}
			n = normals.length;
			for (i = 0; i < n; i+= 3)
			{
				if (x < 0) normals[i] *= -1;
				if (y < 0) normals[i + 1] *= -1;
				if (z < 0) normals[i + 2] *= -1;
			}
			var reverse:Boolean = x * y * z < 0;
			if (reverse)
			{
				n = vertexIndices.length;
				for (i = 0; i < n; i += 3)
				{
					var tmp:uint = vertexIndices[i];
					vertexIndices[i] = vertexIndices[i + 1];
					vertexIndices[i + 1] = tmp;
				}
			}
		}
		
		override public function setGeomMatrix(matrix:Matrix3D):void 
		{
			super.setGeomMatrix(matrix);
			var i:int;
			var n:int;
			
			n = vertices.length;
			for (i = 0; i < n; i+= 3)
			{
				var vp:Vector3D = new Vector3D(vertices[i], vertices[i + 1], vertices[i + 2]);
				vp = matrix.transformVector(vp);
				vertices[i + 0] = vp.x;
				vertices[i + 1] = vp.y;
				vertices[i + 2] = vp.z;
				if (hasNormal)
				{
					var np:Vector3D = new Vector3D(normals[i], normals[i + 1], normals[i + 2]);
					np = matrix.deltaTransformVector(np);
					normals[i + 0] = np.x;
					normals[i + 1] = np.y;
					normals[i + 2] = np.z;
				}
			}
		}
		
		override public function clone():FBXGeometry 
		{
			var geom:FBXMeshGeometry = new FBXMeshGeometry();
			geom.id = id;
			geom.ownerList = ownerList.concat();
			geom.colors = colors.concat();
			//geom.colorR = colorR.concat();
			//geom.colorG = colorG.concat();
			//geom.colorB = colorB.concat();
			geom.isSingleSurface = isSingleSurface;
			geom.meshColor = meshColor;
			geom.normals = normals.concat();
			geom.numTriangle = numTriangle;
			geom.param = param;
			geom.surfaceIndices = surfaceIndices.concat();
			geom.surfaceList = surfaceList.concat();
			geom.tangent4 = tangent4.concat();
			geom.hasTangent4 = hasTangent4;
			geom.hasColor = hasColor;
			geom.hasNormal = hasNormal;
			geom.hasUV = hasUV;
			geom.uvs = uvs.concat();
			geom.vertexIndices = vertexIndices.concat();
			geom.localVertexIndexLink = cloneDictionary(localVertexIndexLink);;
			geom.vertices = vertices.concat();
			geom.skin = skin;
			return geom;
		}
		
		private function cloneDictionary(item:Dictionary, weak:Boolean = false):Dictionary 
		{
			var result:Dictionary = new Dictionary(weak);
			for (var key:* in item) 
			{
				result[key] = item[key];
			}
			return result;
		}
		
	}

}