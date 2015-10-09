package net.morocoshi.common.math.geom 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.loader.geometries.M3DMeshGeometry;
	
	/**
	 * TANGENT4の再計算をする
	 * 
	 * @author tencho
	 */
	public class TangentUtil 
	{
		/**
		 * M3DジオメトリのTANGENT4を再計算
		 * @param	geom
		 */
		static public function calcMeshTangentM3DGeometry(geom:M3DMeshGeometry):void
		{
			var tangentCache:Object = { };
			
			var uv:Vector.<Number> = geom.uvs;
			var pos:Vector.<Number> = geom.vertices;
			var nml:Vector.<Number> = geom.normals;
			var indices:Vector.<uint> = geom.vertexIndices;
			
			var posList:Vector.<Vector3D> = new Vector.<Vector3D>;
			var uvList:Vector.<Point> = new Vector.<Point>;
			var nmlList:Vector.<Vector3D> = new Vector.<Vector3D>;
			
			var i:int;
			var n:int;
			
			n = pos.length;
			for (i = 0; i < n; i += 3)
			{
				posList.push(new Vector3D(pos[i], pos[i + 1], pos[i + 2]));
			}
			n = uv.length;
			for (i = 0; i < n; i += 2)
			{
				uvList.push(new Point(uv[i], uv[i + 1]));
			}
			n = nml.length;
			for (i = 0; i < n; i += 3)
			{
				nmlList.push(new Vector3D(nml[i], nml[i + 1], nml[i + 2]));
			}
			
			var tangentData:Vector.<Number> = new Vector.<Number>(4 * pos.length / 3, true);
			//頂点3つごとにちぇっくする
			for (i = 0; i < indices.length; i+=3) 
			{
				for (var j:int = 0; j < 3; j++) 
				{
					var index:int = indices[i + j];
					//同一インデックスは使いまわす？これタンジェント情報だけ違う場合に対応できない？
					if (tangentCache[index])
					{
						//continue;
					}
					//インデックス番号3つ
					var i0:int = indices[i + (j + 0) % 3];
					var i1:int = indices[i + (j + 1) % 3];
					var i2:int = indices[i + (j + 2) % 3];
					var t4:Vector3D = calcTangentBinormal(posList[i0], posList[i1], posList[i2], uvList[i0], uvList[i1], uvList[i2], nmlList[i0]);
					if (t4 == null)
					{
						t4 = new Vector3D(0, 0, 1, 1);
					}
					tangentData[index * 4 + 0] = t4.x;
					tangentData[index * 4 + 1] = t4.y;
					tangentData[index * 4 + 2] = t4.z;
					tangentData[index * 4 + 3] = t4.w;
					tangentCache[index] = t4;
				}
			}
			geom.tangents = tangentData;
		}
		
		static public function calcTangentBinormalArray(p0:Vector3D, p1:Vector3D, p2:Vector3D, uv0:Array, uv1:Array, uv2:Array, normal:Array):Vector3D
		{
			var uvp0:Point = new Point(uv0[0], uv0[1]);
			var uvp1:Point = new Point(uv1[0], uv1[1]);
			var uvp2:Point = new Point(uv2[0], uv2[1]);
			var normalv:Vector3D = new Vector3D(normal[0], normal[1], normal[2]);
			return calcTangentBinormal(p0, p1, p2, uvp0, uvp1, uvp2, normalv);
		}
		
		/**
		 * ローカル空間での頂点座標（ポリゴン描画順）とUV値から指定座標でのU軸（Tangent）及びV軸（Binormal）を算出
		 * 多分一番正しい結果になると思う
		 * @param	p0
		 * @param	p1
		 * @param	p2
		 * @param	uv0
		 * @param	uv1
		 * @param	uv2
		 * @return
		 */
		static public function calcTangentBinormal(p0:Vector3D, p1:Vector3D, p2:Vector3D, uv0:Point, uv1:Point, uv2:Point, normal:Vector3D, log:Array = null):Vector3D
		{
			var cp0:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(p0.x, uv0.x, uv0.y), new Vector3D(p0.y, uv0.x, uv0.y), new Vector3D(p0.z, uv0.x, uv0.y)]);
			var cp1:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(p1.x, uv1.x, uv1.y), new Vector3D(p1.y, uv1.x, uv1.y), new Vector3D(p1.z, uv1.x, uv1.y)]);
			var cp2:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(p2.x, uv2.x, uv2.y), new Vector3D(p2.y, uv2.x, uv2.y), new Vector3D(p2.z, uv2.x, uv2.y)]);
			var u:Vector.<Number> = new Vector.<Number>;
			var v:Vector.<Number> = new Vector.<Number>;
			for (var i:int = 0; i < 3; i++)
			{
				var v1:Vector3D = cp1[i].subtract(cp0[i]);
				var v2:Vector3D = cp2[i].subtract(cp1[i]);
				var abc:Vector3D = v1.crossProduct(v2);
				if (!abc.x)
				{
					return null;// new Vector3D(0, 0, 0, 1);
				}
				u[i] = -abc.y / abc.x;
				v[i] = -abc.z / abc.x;
			}
			
			//※tangent軸は本来この方法で算出するらしい・・・けど、うまくいかないので
			//var tangent:Vector3D = new Vector3D(u[0], u[1], u[2]);
			//tangent.normalize();
			
			var binormal:Vector3D = new Vector3D(v[0], v[1], v[2]);
			binormal.normalize();
			
			//※binormalとnormalに垂直な軸にしてみたら綺麗になった（正確でない可能性）
			var tangent:Vector3D = normal.crossProduct(binormal);
			tangent.normalize();
			
			//tangentとbinormalとnormalから4番目の数値を決定して、tangentの3データのうしろにくっつける
			//※binormalはいらなくなる
			return getTangent4(tangent, binormal, normal);
		}
		
		/**
		 * TangentとBinormalと法線ベクトルからTangent4を計算
		 * @param	tangent
		 * @param	binormal
		 * @param	normal
		 * @return
		 */
		static private function getTangent4(tangent:Vector3D, binormal:Vector3D, normal:Vector3D):Vector3D 
		{
			var crossX:Number = normal.y * tangent.z - normal.z * tangent.y;
			var crossY:Number = normal.z * tangent.x - normal.x * tangent.z;
			var crossZ:Number = normal.x * tangent.y - normal.y * tangent.x;
			var dot:Number = crossX * binormal.x + crossY * binormal.y + crossZ * binormal.z;
			var t4:int = dot < 0 ? -1 : 1;
			return new Vector3D(tangent.x, tangent.y, tangent.z, t4);
		}
		
		/**
		* 2つのベクトルの内積を返します。
		* (内積：2つのベクトルがどれだけ平行に近いかを示す数値)
		* ・ 1 に近いほど同じ向きで平行
		* ・ 0 に近いほど直角
		* ・-1 に近いほど逆向きで平行
		*/
		static public function dot(a:Vector3D, b:Vector3D):Number
		{
			return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
		}
		
		/**
		* 2つのベクトルの外積を返します。
		* (外積：2つのベクトルで作られる面に垂直なベクトル(=法線)。)
		*/
		static public function cross(a:Vector3D, b:Vector3D):Vector3D
		{
			return new Vector3D((a.y * b.z) - (a.z * b.y), (a.z * b.x) - (a.x * b.z), (a.x * b.y) - (a.y * b.x));
		}
		
		/**
		 * スケーリングした新しいベクトルを取得
		 * @param	v
		 * @param	scale
		 * @return
		 */
		static public function getScaled(v:Vector3D, scale:Number):Vector3D
		{
			var sv:Vector3D = v.clone();
			sv.scaleBy(scale);
			return sv;
		}
		
		//--------------------------------------------------------------------------
		//
		//  古い関数
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 指定MeshのTANGENT4を再計算（MAYA版）
		 * @param	mesh
		 */
		/*
		static public function _calcMeshTangentMaya(mesh:Mesh):void
		{
			var uvs:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
			var pos:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var nml:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.NORMAL);
			var idx:Vector.<uint> = mesh.geometry.indices;
			
			var posList:Vector.<Vector3D> = new Vector.<Vector3D>;
			var uvsList:Vector.<Point> = new Vector.<Point>;
			var nmlList:Vector.<Vector3D> = new Vector.<Vector3D>;
			//var idxList:Vector.<Vector3D> = new Vector.<Vector3D>;
			
			var i:int;
			for (i = 0; i < pos.length; i += 3)
			{
				posList.push(new Vector3D(pos[i], pos[i + 1], pos[i + 2]));
			}
			for (i = 0; i < uvs.length; i += 2)
			{
				uvsList.push(new Point(uvs[i], uvs[i + 1]));
			}
			for (i = 0; i < nml.length; i += 3)
			{
				nmlList.push(new Vector3D(nml[i], nml[i + 1], nml[i + 2]));
			}
			var tgt:Vector.<Number> = new Vector.<Number>(mesh.geometry.getAttributeValues(VertexAttributes.TANGENT4).length);
			for (i = 0; i < idx.length; i += 3)
			{
				var i0:int = idx[i];
				var i1:int = idx[i + 1];
				var i2:int = idx[i + 2];
				var v:Vector.<Vector3D> = Vector.<Vector3D>([posList[i0], posList[i1], posList[i2]]);
				var n:Vector.<Vector3D> = Vector.<Vector3D>([nmlList[i0], nmlList[i1], nmlList[i2]]);
				var t:Vector.<Point> = Vector.<Point>([uvsList[i0], uvsList[i1], uvsList[i2]]);
				var tg3:Vector.<Vector3D> = _calcTangentMaya(v, t, n);
				var cnt:int = 0;
				for each(var tg:Vector3D in tg3)
				{
					var ii:int = [i0, i1, i2][cnt] * 4;
					tgt[ii + 0] = tg.x;
					tgt[ii + 1] = tg.y;
					tgt[ii + 2] = tg.z;
					tgt[ii + 3] = tg.w;
					cnt++;
				}
			}
			mesh.geometry.setAttributeValues(VertexAttributes.TANGENT4, tgt);
		}
		*/
		/**
		 * 指定MeshのTANGENT4を再計算（正しくない）
		 * @param	mesh
		 */
		/*
		static public function _calcMeshTangent(mesh:Mesh):void
		{
			var uvs:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
			var pos:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var nml:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.NORMAL);
			
			var indices:Vector.<uint> = mesh.geometry.indices;
			var posList:Vector.<Vector3D> = new Vector.<Vector3D>;
			var uvList:Vector.<Point> = new Vector.<Point>;
			var nmlList:Vector.<Vector3D> = new Vector.<Vector3D>;
			
			var i:int;
			for (i = 0; i < pos.length; i += 3)
			{
				posList.push(new Vector3D(pos[i], pos[i + 1], pos[i + 2]));
			}
			for (i = 0; i < uvs.length; i += 2)
			{
				uvList.push(new Point(uvs[i], uvs[i + 1]));
			}
			for (i = 0; i < nml.length; i += 3)
			{
				nmlList.push(new Vector3D(nml[i], nml[i + 1], nml[i + 2]));
			}
			
			var tgt:Vector.<Number> = _calcTangent(mesh.geometry.indices, posList, uvList, nmlList);
			mesh.geometry.setAttributeValues(VertexAttributes.TANGENT4, tgt);
		}
		*/
		
		/**
		 * TANGENT4を再計算（MAYA版、正しくない）
		 * @param	indices
		 * @param	vertex
		 * @param	uvs
		 * @param	normals
		 * @return
		 */
		static public function _calcTangentMaya($v:Vector.<Vector3D>, $t:Vector.<Point>, $n:Vector.<Vector3D>):Vector.<Vector3D>
		{
			//var tangent:Vector.<Number> = new Vector.<Number>;
			var $edge1:Vector3D = new Vector3D();
			var $edge2:Vector3D = new Vector3D();
			var $crossP:Vector3D = new Vector3D();
			var $tangentArray:Vector.<Vector3D> = new Vector.<Vector3D>;
			$tangentArray.push(new Vector3D());
			$tangentArray.push(new Vector3D());
			$tangentArray.push(new Vector3D());
			
			//float $tangentArray[3][3];
			//==============================================
			// x, s, t
			// S & T vectors get used several times in this vector,
			// but are only computed once.
			//==============================================
			$edge1.x = $v[1].x - $v[0].x;
			$edge1.y = $t[1].x - $t[0].x; // s-vector - don't need to compute this multiple times
			$edge1.z = $t[1].y - $t[0].y; // t-vector
			$edge2.x = $v[2].x - $v[0].x;
			$edge2.y = $t[2].x - $t[0].x; // another s-vector
			$edge2.z = $t[2].y - $t[0].y; // another t-vector
			$crossP = cross($edge1, $edge2);
			$crossP.normalize();
			var $degnerateUVTangentPlane:Boolean = $crossP.x == 0;
			if ($degnerateUVTangentPlane) $crossP.x = 1;
			var $tanX:Number = -$crossP.y / $crossP.x;
			$tangentArray[0].x = $tanX;
			$tangentArray[1].x = $tanX;
			$tangentArray[2].x = $tanX;
			
			//--------------------------------------------------------
			// y, s, t
			//--------------------------------------------------------
			$edge1.x = $v[1].y - $v[0].y;
			$edge2.x = $v[2].y - $v[0].y;
			$edge2.y = $t[2].x - $t[0].x;
			$edge2.z = $t[2].y - $t[0].y;
			$crossP = cross($edge1, $edge2);
			$crossP.normalize();
			if ($crossP.x == 0) $crossP.x = 1;
			var $tanY:Number = -$crossP.y / $crossP.x;
			$tangentArray[0].y = $tanY;
			$tangentArray[1].y = $tanY;
			$tangentArray[2].y = $tanY;
			//------------------------------------------------------
			// z, s, t
			//------------------------------------------------------
			$edge1.x = $v[1].z - $v[0].z;
			$edge2.x = $v[2].z - $v[0].z;
			$edge2.y = $t[2].x - $t[0].x;
			$edge2.z = $t[2].y - $t[0].y;
			$crossP = cross($edge1, $edge2);
			$crossP.normalize();
			if ($crossP.x == 0) $crossP.x = 1;
			var $tanZ:Number = -$crossP.y / $crossP.x;
			$tangentArray[0].z = $tanZ;
			$tangentArray[1].z = $tanZ;
			$tangentArray[2].z = $tanZ;
			// Orthnonormalize to normal
			for(var i:int = 0; i < 3; i++)
			{
				var d:Number = dot($tangentArray[i], $n[i]);
				$tangentArray[i] = $tangentArray[i].subtract(getScaled($n[i], d));
			}
			// Normalize tangents
			$tangentArray[0].normalize();
			$tangentArray[1].normalize();
			$tangentArray[2].normalize();
			for(i = 0; i < 3; i++)
			{
				$tangentArray[i].w = (dot($tangentArray[i], $n[i]) > 0)? -1 : 1;
			}
			return $tangentArray;
		}
		
		/**
		 * TANGENT4を再計算(古い)
		 * @param	indices
		 * @param	vertex
		 * @param	uvs
		 * @param	normals
		 * @return
		 */
		static public function _calcTangent(indices:Vector.<uint>, vertex:Vector.<Vector3D>, uvs:Vector.<Point>, normals:Vector.<Vector3D>):Vector.<Number>
		{
			var tangent:Vector.<Number> = new Vector.<Number>;
			var numTriangle:int = indices.length / 3;
			var numVertex:int = vertex.length;
			
			var tan1:Vector.<Vector3D> = new Vector.<Vector3D>;
			var tan2:Vector.<Vector3D> = new Vector.<Vector3D>;
			
			var i:int;
			for (i = 0; i < vertex.length; i++) 
			{
				tan1.push(new Vector3D());
				tan2.push(new Vector3D());
			}
			
			var max:int = indices.length;
			for (i = 0; i < max; i += 3)
			{
				var i1:Number = indices[i];
				var i2:Number = indices[i + 1];
				var i3:Number = indices[i + 2];
				
				var v1:Vector3D = vertex[i1];
				var v2:Vector3D = vertex[i2];
				var v3:Vector3D = vertex[i3];
				
				var w1:Point = uvs[i1];
				var w2:Point = uvs[i2];
				var w3:Point = uvs[i3];
				
				var x1:Number = v2.x - v1.x;
				var x2:Number = v3.x - v1.x;
				var y1:Number = v2.y - v1.y;
				var y2:Number = v3.y - v1.y;
				var z1:Number = v2.z - v1.z;
				var z2:Number = v3.z - v1.z;
				
				var s1:Number = w2.x - w1.x;
				var s2:Number = w3.x - w1.x;
				var t1:Number = w2.y - w1.y;
				var t2:Number = w3.y - w1.y;
				
				var r:Number = 1 / (s1 * t2 - s2 * t1);
				var sdir:Vector3D = new Vector3D((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r);
				var tdir:Vector3D = new Vector3D((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r);
				tan1[i1].incrementBy(sdir);
				tan1[i2].incrementBy(sdir);
				tan1[i3].incrementBy(sdir);
				
				tan2[i1].incrementBy(tdir);
				tan2[i2].incrementBy(tdir);
				tan2[i3].incrementBy(tdir);
			}
			
			for (i = 0; i < numVertex; i++)
			{
				var n:Vector3D = normals[i];
				var t:Vector3D = tan1[i];
				var tgt:Vector3D = t.subtract(getScaled(n, dot(n, t)));
				tgt.normalize();
				var w:Number = dot(cross(n, t), tan2[i]) < 0 ? -1 : 1;
				tangent.push(tgt.x, tgt.y, tgt.z, w);
			}
			return tangent;
		}
		
	}

}