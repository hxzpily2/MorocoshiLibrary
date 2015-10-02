package net.morocoshi.common.collision.solid 
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.collision.solid.bounds.AABB3D;
	import net.morocoshi.common.collision.solid.primitives.Collision3DMesh;
	import net.morocoshi.common.collision.solid.primitives.Collision3DObject;
	import net.morocoshi.common.collision.solid.primitives.Triangle3D;
	import net.morocoshi.common.collision.solid.results.Collision3DResult;
	import net.morocoshi.common.collision.solid.units.SphereUnit3D;
	import net.morocoshi.common.collision.solid.units.Unit3D;
	import net.morocoshi.common.data.Temp;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.partitioning.cell2.Cell2DItem;
	import net.morocoshi.common.partitioning.cell2.Cell2DSpacePartition;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * 1.buildPartition()
	 * 2.addObject(parseObject())
	 * 3.addUnit()
	 * 4.update()
	 * 5.collide()
	 * 
	 * @author tencho
	 */
	public class Collision3DWorld 
	{
		public var partition:Cell2DSpacePartition;
		public var unitPartition:Cell2DSpacePartition;
		
		private var tempResult:Collision3DResult;
		private var numTriangle:int;
		private var showLog:Boolean;
		private var unitList:Vector.<Unit3D>;
		private var movedTime:int;
		public var root:Collision3DObject;
		
		private const SMALL:Number = 0.000000001;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Collision3DWorld() 
		{
			numTriangle = 0;
			root = new Collision3DObject();
			root.world = this;
			partition = new Cell2DSpacePartition();
			unitPartition = new Cell2DSpacePartition();
			tempResult = new Collision3DResult();
			unitList = new Vector.<Unit3D>;
		}
		
		//--------------------------------------------------------------------------
		//
		//  空間分割初期化
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	aabb
		 * @param	w
		 * @param	h
		 */
		public function buildPartition(aabb:AABB3D, w:int = 10, h:int = 10):void
		{
			partition.build(aabb.xMin, aabb.yMin, aabb.xMax - aabb.xMin, aabb.yMax - aabb.yMin, w, h);
			unitPartition.build(aabb.xMin, aabb.yMin, aabb.xMax - aabb.xMin, aabb.yMax - aabb.yMin, w, h);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Object3Dからのパース
		//
		//--------------------------------------------------------------------------
		
		private var existMeshList:Vector.<Collision3DObject>;
		private var existAllList:Vector.<Collision3DObject>;
		
		/**
		 * Object3Dと内部の全ての子をコリジョンに変換しつつリンクさせる
		 * @param	object	
		 * @param	reg
		 * @return
		 */
		public function parseObject(object:Object3D, reg:RegExp = null):Collision3DObject
		{
			//regの例：/@(.+)/
			existMeshList = new Vector.<Collision3DObject>;
			existAllList = new Vector.<Collision3DObject>;
			var result:Collision3DObject = toCollisionObject(object, reg);
			for each (var item:Collision3DObject in existMeshList) 
			{
				var target:Collision3DObject = item;
				while (target)
				{
					VectorUtil.deleteItem(existAllList, target);
					target = target.parent;
				}
			}
			
			for each (var col:Collision3DObject in existAllList) 
			{
				if (col.parent)
				{
					col.remove();
				}
			}
			
			existMeshList = null;
			existAllList = null;
			return result;
		}
		
		/**
		 * 
		 * @param	object
		 * @param	reg
		 * @return
		 */
		private function toCollisionObject(object:Object3D, reg:RegExp):Collision3DObject
		{
			var col:Collision3DObject;
			
			if (object is Mesh)
			{
				if (reg)
				{
					var match:Array = reg.exec(object.name);
					if (match)
					{
						switch(match[1])
						{
							case "BOX": case "MESH":
								col = new Collision3DMesh();
								break;
							default:
								col = new Collision3DMesh();
						}
						existMeshList.push(col);
					}
				}
				else
				{
					col = new Collision3DMesh();
					existMeshList.push(col);
				}
			}
			
			if (col == null)
			{
				col = new Collision3DObject();
			}
			col.parseFromMesh(object as Mesh);
			col.skin = object;
			col.name = object.name;
			col.matrix.copyFrom(object.matrix);
			
			for (var child:Object3D = object.children; child; child = child.next) 
			{
				col.addChild(toCollisionObject(child, reg));
			}
			
			existAllList.push(col);
			
			return col;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 * @param	item
		 */
		public function addCellItem(item:Collision3DObject):void 
		{
			var mesh:Collision3DMesh = item as Collision3DMesh;
			if (!mesh) return;
			
			for each(var tri:Triangle3D in mesh.triangleList)
			{
				partition.addItem(tri.cellItem);
			}
		}
		
		/**
		 * 
		 * @param	item
		 */
		public function removeCellItem(item:Collision3DObject):void 
		{
			var mesh:Collision3DMesh = item as Collision3DMesh;
			if (!mesh) return;
			
			for each(var tri:Triangle3D in mesh.triangleList)
			{
				partition.removeItem(tri.cellItem);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  コリジョンの追加
		//
		//--------------------------------------------------------------------------
		
		/**
		 * コリジョンを空間に追加する
		 * @param	object
		 */
		public function addObject(object:Collision3DObject):void
		{
			root.addChild(object);
		}
		
		/**
		 * 移動球ユニットの追加
		 * @param	unit
		 */
		public function addUnit(unit:Unit3D):void
		{
			unitList.push(unit);
			unitPartition.addItem(unit.cellItem);
		}
		
		//--------------------------------------------------------------------------
		//
		//  ユニットにかかる力の更新
		//
		//--------------------------------------------------------------------------
		
		//ユニット同士の押し出しでフレームスキップ分強く押すためのｶｳﾝﾀに使う予定
		private var updateCount:int;
		
		/**
		 * 全てのユニットのupdate()を呼ぶ。この処理は毎フレーム必ず呼び出すようにする（フレームスキップされないようにする）
		 */
		public function update():void 
		{
			updateCount++;
			for (var u:int = 0; u < unitList.length; u++) 
			{
				unitList[u].update(this);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  衝突判定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 空間内に追加済みの移動ユニットをワールド内の全コリジョンと衝突判定させる。この処理はフレームスキップ可能。
		 * @param	showLog
		 */
		public function collide(showLog:Boolean):void 
		{
			this.showLog = showLog;
			movedTime++;
			//コリジョンが移動や回転していた場合、ここで計算しておく
			for (var current:Collision3DObject = root.children; current; current = current.next)
			{
				current.update(movedTime);
			}
			
			//時間を進めて衝突済みフラグをリセットする
			unitPartition.step();
			for (var u:int = 0; u < unitList.length; u++) 
			{
				//ユニット同士の押し出し
				var unit:Unit3D = unitList[u];
				unit.cellItem.updateCollision();
				for each(var item:Cell2DItem in unit.cellItem.collisionList)
				{
					if (item.checked) continue;
					
					var other:Unit3D = item.data;
					other.hit(unit, updateCount);
				}
				unit.cellItem.setChecked();
				unit.collide(this);
			}
			updateCount = 0;
		}
		
		/*
		public var debugWire:WireFrame = new WireFrame(0x000000, 1, 2);
		public function drawDebugWire(aabb:AABB3D, context3D:Context3D):void
		{
			var geomrtry:WireGeometry = debugWire.geometry;
			geomrtry.clear();
			for each(var item:Cell2DItem in partition.getCollisionList(aabb.xMin, aabb.yMin, aabb.xMax, aabb.yMax))
			{
				var tri:Triangle3D = item.data;
				tri.addWireToGeometry(geomrtry);
			}
			geomrtry.upload(context3D);
		}
		*/
		/**
		 * 指定のユニットをワールド内のコリジョンと衝突判定させる。これはUnit3D内で呼ばれる。
		 * @param	unit
		 */
		public function collideUnit(unit:Unit3D):void
		{
			log("############## 衝突判定開始 #################");
			
			var resultList:Vector.<Collision3DResult> = new Vector.<Collision3DResult>;
			var triangleList:Vector.<Triangle3D> = new Vector.<Triangle3D>;
			var infinitePlaneLink:Dictionary = new Dictionary();
			
			unit.ready();
			
			//止まるまでループ
			var loop:int = 8;
			while (--loop >= 0)
			{
				unit.updateAABB();
				
				triangleList.length = 0;
				
				//近くの衝突する可能性のある△ポリゴンを抽出
				for each(var item:Cell2DItem in partition.getCollisionList(unit.aabb.xMin, unit.aabb.yMin, unit.aabb.xMax, unit.aabb.yMax))
				{
					var tri:Triangle3D = item.data;
					triangleList.push(tri);
				}
				numTriangle = triangleList.length;
				log("衝突候補の三角ポリ数＝", numTriangle);
				
				//近くのポリゴンと衝突判定
				resultList.length = 0;
				for (var i:int = 0; i < numTriangle; i++) 
				{
					var triangle:Triangle3D = triangleList[i];
					
					if (!triangle.valid) continue;
					
					var sphereUnit:SphereUnit3D = unit as SphereUnit3D;
					//1つのポリゴンとの衝突判定をする
					//この時点では衝突点を求めるだけ
					var result:Collision3DResult;
					if (infinitePlaneLink[triangle])
					{
						//無限平面との衝突判定
						result = collidePlane(infinitePlaneLink[triangle], sphereUnit);
					}
					else
					{
						//ポリゴンのAABBと接触していなければ終了
						var a:AABB3D = triangle.aabb;
						var b:AABB3D = unit.aabb;
						if (a.xMin > b.xMax || a.yMin > b.yMax || a.zMin > b.zMax || a.xMax < b.xMin || a.yMax < b.yMin || a.zMax < b.zMin) continue;
						//元のコード：if (!triangle.aabb.hitTest(unit.aabb)) continue;
						
						//△ポリゴンとの衝突判定
						result = collideTriangle(triangle, sphereUnit);
					}
					
					log(i, "-------------", result.hit);
					if (result.hit)
					{
						resultList.push(result.clone());
					}
				}
				
				//衝突が同時に2つ以上あれば時間でソート
				if (resultList.length >= 2)
				{
					resultList.sort(resultSort);
				}
				
				if (!resultList.length)
				{
					//どのポリゴンともぶつからなかった場合
					log("@@@@@ ぶつからない");
					//最終地点へ動かして終了
					///Main.me.traceLine(unit.position, unit.displace);
					unit.finish();
					return;
				}
				
				//一番近い衝突情報を選ぶ
				var nearCollision:Collision3DResult = resultList[0];
				if (nearCollision.time < 0) nearCollision.time = 0;
				log("一番近い衝突点は＝", nearCollision.reverse, "無限平面？", nearCollision.infinity);
				
				if (nearCollision.infinity)
				{
					log("★ 無限平面と衝突！");
					//衝突したのが無限平面の場合は同時に2面と接触しているはずなので特殊処理をさせる
					unit.applyInfinitePlane(nearCollision);
				}
				else
				{
					log("★ ポリ平面と衝突！");
					if (nearCollision.thrust)
					{
						log("押し出し量：", nearCollision.thrustVector);
					}
					
					//平面との衝突処理
					//平面に沿った壁ずり加速度を設定
					unit.applyCollision(nearCollision);
				}
				///Main.me.traceAxis(nearCollision.collision, nearCollision.normal);
				
				//通常ポリゴンに衝突していたら壁ずり制限用無限平面を追加
				unit.collisionList.push(nearCollision);
				//一度接触した面は特殊処理をさせるために面情報を保持しておく
				if (nearCollision.instance)
				{
					infinitePlaneLink[nearCollision.instance] = nearCollision;
					log(nearCollision.instance, ":のポリゴン平面を追加します");
				}
				
				//%%%ここ後で有効にする
				if (unit.displace.x == 0 && unit.displace.y == 0 && unit.displace.z == 0)
				{
					log("@@@@@ 動かないので終了");
					//最終地点へ動かして終了
					unit.finish();
					return;
				}
			}
			
			//最後まで衝突しつづけた場合はストップ
			log("@@@@@ 最後まで衝突しつづけた場合はストップ");
			unit.stop();
		}
		
		/**
		 * レイとポリゴンの交差判定
		 * @param	start
		 * @param	destination
		 * @param	infinity
		 * @return
		 */
		public function intersectRay(start:Vector3D, destination:Vector3D, infinity:Boolean):Vector.<Collision3DResult> 
		{
			var results:Vector.<Collision3DResult> = new Vector.<Collision3DResult>;
			
			var xMin:Number;
			var xMax:Number;
			var yMin:Number;
			var yMax:Number;
			var zMin:Number;
			var zMax:Number;
			if (start.x < destination.x)
			{
				xMin = start.x;
				xMax = infinity? Number.POSITIVE_INFINITY : destination.x;
			}
			else
			{
				xMin = infinity? Number.NEGATIVE_INFINITY : destination.x;
				xMax = start.x;
			}
			if (start.y < destination.y)
			{
				yMin = start.y;
				yMax = infinity? Number.POSITIVE_INFINITY : destination.y;
			}
			else
			{
				yMin = infinity? Number.NEGATIVE_INFINITY : destination.y;
				yMax = start.y;
			}
			if (start.z < destination.z)
			{
				zMin = start.z;
				zMax = infinity? Number.POSITIVE_INFINITY : destination.z;
			}
			else
			{
				zMin = infinity? Number.NEGATIVE_INFINITY : destination.z;
				zMax = start.z;
			}
			
			var ray:Vector3D = destination.subtract(start);
			var length:Number = infinity? 0 : ray.length;
			ray.normalize();
			for each(var item:Cell2DItem in partition.getCollisionList(xMin, yMin, xMax, yMax))
			{
				var triangle:Triangle3D = item.data;
				//ポリゴンのAABBと接触していなければ終了
				var a:AABB3D = triangle.aabb;
				if (a.xMin > xMax || a.yMin > yMax || a.zMin > zMax || a.xMax < xMin || a.yMax < yMin || a.zMax < zMin) continue;
				
				var result:Collision3DResult = intersectRayToFace(start, ray, length, triangle, false);
				if (result == null) continue;
				
				results.push(result);
			}
			results.sort(distanceSort);
			
			return results;
		}
		
		private function distanceSort(a:Collision3DResult, b:Collision3DResult):int 
		{
			return int(a.distance > b.distance) - int(a.distance < b.distance);
		}
		
		/**
		 * レイと三角形との交差判定
		 * @param	origin	レイ放射開始地点
		 * @param	ray	レイの方向（正規化済み）
		 * @param	length	レイの長さ（0で長さ無限判定）
		 * @param	face	ポリゴンフェイス
		 * @param	doubleSided	裏向きのポリゴンも交差判定する
		 * @return
		 */
		private function intersectRayToFace(origin:Vector3D, ray:Vector3D, length:Number, face:Triangle3D, doubleSided:Boolean):Collision3DResult
		{
			//ポリゴンは頂点反時計周りでa→b→cの構成
			
			//レイの方向（正規化）
			//var rayN:Vector3D = ray.clone();
			//rayN.normalize();
			
			//法線ベクトルとレイで傾きチェック
			var vn:Number = dot(ray, face.normal);
			
			//1.平面と平行なら交差なし(計算誤差を考慮)
			//2.片面チェック時に視線と法線が同じ向き（裏側を見ている）なら交差なし
			if ((vn < SMALL && vn > -SMALL) || (vn > 0 && !doubleSided)) return null;
			
			var d:Number = dot(origin.subtract(face.a), face.normal);
			var distance:Number = -d / vn;
			
			//交差位置が視線と逆方向なら交差なし
			if (distance < 0) return null;
			if (length > 0 && distance > length) return null;
			
			//視線と平面との交点
			var hit:Vector3D = ray.clone();
			hit.scaleBy(distance);
			hit.incrementBy(origin);
			
			//交点が三角形内にあるかチェック(計算誤差を考慮)
			cross(hit.subtract(face.a), face.ab, Temp.position);
			if (dot(Temp.position, face.normal) > SMALL) return null;
			
			cross(hit.subtract(face.b), face.bc, Temp.position);
			if (dot(Temp.position, face.normal) > SMALL) return null;
			
			cross(hit.subtract(face.c), face.ca, Temp.position);
			if (dot(Temp.position, face.normal) > SMALL) return null;
			
			var data:Collision3DResult = new Collision3DResult();
			data.collision = hit;
			data.distance = distance;
			return data;
		}
		
		/**
		 * 内積
		 * @param	a
		 * @param	b
		 * @return
		 */
		static public function dot(a:Vector3D, b:Vector3D):Number
		{
			return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
		}
		
		/**
		 * 外積
		 * @param	a
		 * @param	b
		 * @param	target
		 * @return
		 */
		static public function cross(a:Vector3D, b:Vector3D, target:Vector3D):void
		{
			target.x = a.y * b.z - a.z * b.y;
			target.y = a.z * b.x - a.x * b.z;
			target.z = a.x * b.y - a.y * b.x;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function log(...args):void 
		{
			if (showLog) trace.apply(null, args);
		}
		
		private function resultSort(a:Collision3DResult, b:Collision3DResult):int 
		{
			//%%%ここどうにかする
			return int(a.time > b.time) - int(a.time < b.time);
			if (a.time != b.time)
			{
				return int(a.time > b.time) - int(a.time < b.time);
			}
			return int(a.instance.instance.moved) - int(b.instance.instance.moved);
			///return int(a.time > b.time) - int(a.time < b.time);
		}
		
		/**
		 * ブロック平面と球の当たり判定
		 * @param	plane
		 * @param	unit
		 * @return
		 */
		private function collidePlane(plane:Collision3DResult, unit:SphereUnit3D):Collision3DResult
		{
			tempResult.reset();
			tempResult.infinity = true;
			tempResult.instance = plane.instance;
			var normal:Vector3D = plane.normal;
			//[dot(unit.displace, normal)]
			var vn:Number = (unit.displace.x * normal.x) + (unit.displace.y * normal.y) + (unit.displace.z * normal.z);
			
			//球が平面法線と同じ向きに進んでいれば終了（計算誤差考慮）
			tempResult.reverse = vn >= -SMALL;
			if (tempResult.reverse)
			{
				log(plane.instance.index, "[無限平面：終了]同じ方向")
				return tempResult;
			}
			
			if (vn == 0)
			{
				throw new Error(normal.toString() + "/" + unit.displace.toString());
			}
			
			//[dot(unit.position - plane.collision, normal)];
			var ax:Number = unit.position.x - plane.collision.x;
			var ay:Number = unit.position.y - plane.collision.y;
			var az:Number = unit.position.z - plane.collision.z;
			var d:Number = (ax * normal.x) + (ay * normal.y) + (az * normal.z);
			tempResult.time = (unit.radius - d) / vn;
			//無限平面の場合、衝突時間がマイナスの場合確実にヒットするので1以下で判定（計算誤差でマイナスもある）
			tempResult.hit = (tempResult.time <= 1);
			log(plane.instance.index, "【無限平面：ヒット？】", tempResult.time.toFixed(20), tempResult.hit, tempResult.infinity);
			if (tempResult.hit)
			{
				//本来マイナスは無いはずなので下限を0にする
				if (tempResult.time < 0) tempResult.time = 0;
				tempResult.collision.x = unit.position.x + unit.displace.x * tempResult.time - normal.x * unit.radius;
				tempResult.collision.y = unit.position.y + unit.displace.y * tempResult.time - normal.y * unit.radius;
				tempResult.collision.z = unit.position.z + unit.displace.z * tempResult.time - normal.z * unit.radius;	
				tempResult.normal.x = normal.x;
				tempResult.normal.y = normal.y;
				tempResult.normal.z = normal.z;
			}
			return tempResult;
		}
		
		/**
		 * 三角ポリゴンが持つ平面との交差判定
		 * @param	triangle
		 * @param	unit
		 * @return
		 */
		private function collideTrianglePlane(triangle:Triangle3D, unit:SphereUnit3D):Collision3DResult
		{
			tempResult.reset();
			tempResult.instance = triangle;
			var normal:Vector3D = triangle.normal;
			//[dot(unit.displace, normal)]
			var vn:Number = (unit.displace.x * normal.x) + (unit.displace.y * normal.y) + (unit.displace.z * normal.z);
			
			//球が平面法線と同じ向きに進んでいれば終了（計算誤差考慮）
			//ただし動いているポリゴンは同じ向きでも交差してる可能性がある
			tempResult.reverse = vn >= -SMALL;
			if (!triangle.instance.moved && tempResult.reverse)
			{
				log(triangle.index, "[△平面：終了]同じ向き", unit.displace, normal);
				return tempResult;
			}
			
			//平面と球中心の最短距離
			//dot(unit.position - triangle.a, normal);
			var ax:Number = unit.position.x - triangle.a.x;
			var ay:Number = unit.position.y - triangle.a.y;
			var az:Number = unit.position.z - triangle.a.z;
			var d:Number = (ax * normal.x) + (ay * normal.y) + (az * normal.z);
			
			//平面にめり込んでいれば法線方向に押し出す
			if (d < unit.radius && -d < unit.radius * 0.5)
			{
				log(triangle.index, "[△平面：ヒット]めりこんでる");
				var delta:Number = unit.radius - d;
				
				tempResult.thrust = true;
				tempResult.thrustVector.x = normal.x * delta;
				tempResult.thrustVector.y = normal.y * delta;
				tempResult.thrustVector.z = normal.z * delta;
				var t:Number = delta - unit.radius;
				tempResult.collision.x = unit.position.x + normal.x * t;
				tempResult.collision.y = unit.position.y + normal.y * t;
				tempResult.collision.z = unit.position.z + normal.z * t;
				tempResult.time = 0;
				tempResult.normal.x = triangle.normal.x;
				tempResult.normal.y = triangle.normal.y;
				tempResult.normal.z = triangle.normal.z;
				tempResult.hit = true;
			}
			else if (vn != 0) //vn=0（球が動いていない）場合は、衝突しない判定にする
			{
				tempResult.time = (unit.radius - d) / vn;
				tempResult.hit = (tempResult.time >= -SMALL && tempResult.time <= 1);
				log(triangle.index, "[△平面：ヒット]めり込んでない", tempResult.hit, tempResult.time);
				//平面と衝突
				if (tempResult.hit)
				{
					tempResult.collision.x = unit.position.x + unit.displace.x * tempResult.time - triangle.normal.x * unit.radius;
					tempResult.collision.y = unit.position.y + unit.displace.y * tempResult.time - triangle.normal.y * unit.radius;
					tempResult.collision.z = unit.position.z + unit.displace.z * tempResult.time - triangle.normal.z * unit.radius;
					tempResult.normal.x = triangle.normal.x;
					tempResult.normal.y = triangle.normal.y;
					tempResult.normal.z = triangle.normal.z;
				}
			}
			return tempResult;
		}
		
		/**
		 * 三角形と球の当たり判定
		 * @param	triangle
		 * @param	unit
		 * @return
		 */
		private function collideTriangle(triangle:Triangle3D, unit:SphereUnit3D):Collision3DResult 
		{
			var result:Collision3DResult;
			
			//平面との交差判定
			result = collideTrianglePlane(triangle, unit);
			
			//平面と衝突していなければ終了
			if (!result.hit)
			{
				log(triangle.index, "[△：終了]三角平面とぶつからなかった", triangle.index);
				return result;
			}
			
			///Main.me.tracePoint(result.collision, result.instance.color);
			//衝突点が三角形内にある場合
			if (triangle.contains(result.collision))
			{
				result.instance = triangle;
				log(triangle.index, "[△：ヒット]三角形内でヒットした", triangle.index);
				return result;
			}
			
			//三角形の3つの辺に最も近い点を取得
			var nearPoint:Vector3D = triangle.getNearPoint(unit, result.collision);
			if (!nearPoint)
			{
				result.hit = false;
				return result;
			}
			///Main.me.tracePoint(nearPoint, result.instance.color, 1, 1);
			result = collideLine(unit, nearPoint);
			
			//辺と衝突しなければ終了
			if (!result.hit)
			{
				log(triangle.index, "[△：終了]辺とぶつからなかった", triangle.index);
				return result;
			}
			
			result.instance = triangle;
			log(triangle.index, "[△：ヒット]辺とヒットした", triangle.index);
			return result;
		}
		
		/**
		 * 辺上の点が生成する無限平面との交差判定
		 * @param	unit
		 * @param	point
		 * @return
		 */
		private function collideLine(unit:SphereUnit3D, point:Vector3D):Collision3DResult 
		{
			tempResult.reset();
			
			//再接近点から球の移動量を-1したレイを放射し球に衝突した時刻をチェックする
			
			//再接近点→球中心のベクトル
			var shortestLine:Vector3D = unit.position.subtract(point);
			//接近点から放射する球移動量反転ベクトル（計算用に長さ1にしてる）
			var unitVector:Vector3D = unit.displace.clone();
			unitVector.normalize();
			unitVector.scaleBy(-1);
			
			//dot(shortestLine,unitVector);
			var l:Number = (shortestLine.x * unitVector.x) + (shortestLine.y * unitVector.y) + (shortestLine.z * unitVector.z);
			
			//逆方向に進んでいたら交差無し（埋まってる場合はどうする？）
			if (l < 0)
			{
				return tempResult;
			}
			var rayLine:Vector3D = unitVector.clone();
			rayLine.scaleBy(l);
			
			//再接近点の球中心からの距離（の2乗）
			var dx:Number = shortestLine.x - rayLine.x;
			var dy:Number = shortestLine.y - rayLine.y;
			var dz:Number = shortestLine.z - rayLine.z;
			var distance2:Number = dx * dx + dy * dy + dz * dz;
			var radius2:Number = unit.radius * unit.radius;
			
			//%%%再接近点が半径より遠い場合は交差無し（計算誤差を考慮したほうがいい？）
			if (distance2 > radius2)
			{
				return tempResult;
			}
			
			//球中心～辺上の点までの距離の2乗
			var shortestLength2:Number = shortestLine.x * shortestLine.x + shortestLine.y * shortestLine.y + shortestLine.z * shortestLine.z;
			//辺上の点から衝突点までの距離
			var hitDistance:Number = Math.sqrt(shortestLength2 - distance2) - Math.sqrt(radius2 - distance2);
			
			tempResult.collision.x = point.x;
			tempResult.collision.y = point.y;
			tempResult.collision.z = point.z;
			
			//埋まってた場合
			if (shortestLength2 < radius2)
			{
				tempResult.time = 0;
				tempResult.hit = true;
				tempResult.thrust = true;
				
				tempResult.normal.x = unit.position.x - point.x;
				tempResult.normal.y = unit.position.y - point.y;
				tempResult.normal.z = unit.position.z - point.z;
				tempResult.normal.normalize();
				
				//押し出し量
				tempResult.thrustVector.x = tempResult.normal.x * unit.radius + point.x - unit.position.x;
				tempResult.thrustVector.y = tempResult.normal.y * unit.radius + point.y - unit.position.y;
				tempResult.thrustVector.z = tempResult.normal.z * unit.radius + point.z - unit.position.z;
				
				return tempResult;
			}
			
			//交差距離と移動距離で衝突時間を特定
			var d:Number = unit.displace.length;
			//球が移動してない＆めり込んでないなら終了
			if (d == 0)
			{
				return tempResult;
			}
			
			tempResult.time = hitDistance / d;
			tempResult.hit = (tempResult.time >= -SMALL && tempResult.time <= 1);
			
			//衝突してない
			if (!tempResult.hit)
			{
				return tempResult;
			}
			
			//衝突点→球中心のベクトルを正規化すると衝突点の法線になる
			//%%%ここおかしいと思う。衝突時の球の座標を求めないといけない？
			tempResult.normal.x = unit.position.x - tempResult.collision.x;
			tempResult.normal.y = unit.position.y - tempResult.collision.y;
			tempResult.normal.z = unit.position.z - tempResult.collision.z;
			tempResult.normal.normalize();
			
			return tempResult;
		}
		
	}

}