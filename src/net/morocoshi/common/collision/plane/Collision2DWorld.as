package net.morocoshi.common.collision.plane
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.morocoshi.common.collision.plane.collisions.BaseCollision;
	import net.morocoshi.common.collision.plane.collisions.CollisionType;
	import net.morocoshi.common.collision.plane.collisions.LineCollision;
	import net.morocoshi.common.collision.plane.collisions.LineSurface;
	import net.morocoshi.common.collision.plane.units.CollisionUnit;
	import net.morocoshi.common.collision.plane.utils.Collision2DUtil;
	import net.morocoshi.common.collision.plane.wallData.IWallData;
	import net.morocoshi.common.collision.plane.wallData.LineWallData;
	import net.morocoshi.common.collision.plane.wallData.WallType;
	import net.morocoshi.common.partitioning.quadtree.QuadTree;
	import net.morocoshi.common.partitioning.quadtree.TreeData;
	
	/**
	 * 衝突判定を行うライブラリのメインクラス
	 * 
	 * ■ このクラスは、以下の目的を達成する
	 * ・2D空間を扱う。
	 * ・特定の壁データの集合を与える。
	 * ・一定サイズの円（ユニット）が、原点から目的点へ移動した場合の、壁との衝突や壁ずりを考慮した、最終地点の計算結果を返す。
	 * ・壁をすり抜けない
	 * ・壁は設定次第で片面判定にも両面判定にもできる
	 * ・ユニットが、他の動的なユニットと干渉し、ソフトに押し合う（通称：ぬるり）
	 *  IDが大きいユニットが優先して押しのけられる
	 * 
	 * ■ このクラスは、以下の目的で使用されない
	 * ・ゲームキャラクターの位置情報の保存や移動、攻撃判定など、ゲームに関わること全般
	 *  （移動オブジェクトのデータは、あくまで計算省力化のために保持される）
	 * ・移動する壁
	 * ・3D空間の扱い（アーチ状の地形は無い）
	 * ・起伏の考慮（坂を移動する場合の加速は無視する）
	 * 
	 * @author tencho
	 */
	public class Collision2DWorld 
	{
		private var _useQuadTree:Boolean = true;
		private var _collisions:Vector.<BaseCollision> = new Vector.<BaseCollision>;
		private var _units:Vector.<CollisionUnit> = new Vector.<CollisionUnit>;
		private var _bosses:Vector.<CollisionUnit> = new Vector.<CollisionUnit>;
		private var _collideData:Vector.<CollideData> = new Vector.<CollideData>;
		private var _wallTree:QuadTree;
		private var _unitTree:QuadTree;
		//空間分割の最大数（分割が多くなりすぎると逆に遅くなるので制限する）
		private const QUADTREE_LV_MAX:int = 5;
		// 初期化前のUnitのリスト
		private var _yetUnits:Vector.<CollisionUnit> = new Vector.<CollisionUnit>();
		private var overlapCount:int = 0;
		private var collidedKey:Object;
		
		private var overlap:Object;
		
		private var _fieldRectangle:Rectangle;
		
		/**
		 * コンストラクタ
		 */
		public function Collision2DWorld()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  プロパティ
		//
		//--------------------------------------------------------------------------
		
		/**壁コリジョンのリスト*/
		public function get collisions():Vector.<BaseCollision> 
		{
			return _collisions;
		}
		
		/**全ユニットのリスト*/
		public function get units():Vector.<CollisionUnit> 
		{
			return _units;
		}
		
		/**壁用四分木空間*/
		public function get wallTree():QuadTree 
		{
			return _wallTree;
		}
		
		/**キャラクター用四分木空間*/
		public function get unitTree():QuadTree 
		{
			return _unitTree;
		}
		
		/**四分木空間を使用するか*/
		public function get useQuadTree():Boolean 
		{
			return _useQuadTree;
		}
		
		public function set useQuadTree(value:Boolean):void 
		{
			_useQuadTree = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  初期化
		//
		//--------------------------------------------------------------------------
		
		/**
		 * マップの壁データを設定する
		 * @param	wallDataList	全ての壁データを含むリスト。追加や削除は行わない。
		 * @param	baseRadius	動的な円の一般的な半径。分割マップ最適化の参照値として扱う
		 */
		public function createCollision(wallDataList:Vector.<IWallData>, baseRadius:Number):void
		{
			disposeCollision();
			if (!wallDataList.length) throw new Error("壁データがありません");
			if (baseRadius < 0) throw new Error("動的な円の半径は0以上である必要があります");
			
			var points:Vector.<Point> = new Vector.<Point>;
			
			var lineSize:Number = 0;
			var cnt:int = 0;
			overlap = { };
			overlapCount = 0;
			// 壁のデータを内部で使用しやすい形にパースする
			for each (var wall:IWallData in wallDataList) 
			{
				if (wall.type == WallType.CIRCLE)
				{
					//円形の壁はまだ
				}
				if (wall.type == WallType.POLYGON)
				{
					var line:LineWallData = wall as LineWallData;
					var xy:Vector.<Number> = line.xyList;
					var l:int = xy.length - 4;
					for (var i:int = 0; i <= l; i += 2)
					{
						points.push(new Point(xy[i], xy[i + 1]));
						if (i == l) points.push(new Point(xy[i + 2], xy[i + 3]));
						cnt++;
						lineSize += Math.max(Math.abs(xy[i] - xy[i + 2]), Math.abs(xy[i + 1] - xy[i + 3]));
						var lineCol:LineCollision = new LineCollision(xy[i], xy[i + 1], xy[i + 2], xy[i + 3], line.surface);
						lineCol.originKey = getOverlapKey(xy[i], xy[i + 1]);
						lineCol.endKey = getOverlapKey(xy[i + 2], xy[i + 3]);
						_collisions.push(lineCol);
					}
				}
			}
			overlap = null;
			lineSize /= cnt;
			
			// 壁のデータから、分割マップを用意する
			//　壁用とキャラクター用で別々の四分木空間を用意する
			//　それぞれの空間の分割数は壁の平均サイズとキャラクター半径を使って算出する
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			for each(var p:Point in points)
			{
				if (p.x < minX) minX = p.x;
				if (p.x > maxX) maxX = p.x;
				if (p.y < minY) minY = p.y;
				if (p.y > maxY) maxY = p.y;
			}
			_fieldRectangle = new Rectangle(minX, minY, maxX - minX, maxY - minY);
			
			_wallTree = new QuadTree();
			_unitTree = new QuadTree();
			
			var seg:Number;
			var lv:int;
			
			//壁の空間分割（キャラクター直径と壁の平均サイズの大きい方で算出）
			seg = Math.max(maxX - minX, maxY - minY) / Math.max(lineSize, baseRadius);
			for (lv = 2; lv <= QUADTREE_LV_MAX; lv++) 
			{
				if (seg <= Math.pow(2, lv)) break;
			}
			_wallTree.init(lv - 1, minX, minY, maxX - minX, maxY - minY);
			
			//キャラクターの空間分割（キャラクター半径で算出）
			seg = Math.max(maxX - minX, maxY - minY) / baseRadius / 2;
			for (lv = 2; lv <= QUADTREE_LV_MAX; lv++) 
			{
				if (seg <= Math.pow(2, lv)) break;
			}
			_unitTree.init(lv - 1, minX, minY, maxX - minX, maxY - minY);
			
			//壁コリジョン矩形を空間に登録
			for each(var col:BaseCollision in _collisions)
			{
				_wallTree.addData(col.treeData);
			}
			
			// 初期化待ちのUnitを処理（実行順を維持するため、普通のforを使う）
			var n:int = _yetUnits.length;
			for (i = 0; i < n; i++)
			{
				addUnit_(_yetUnits[i]);
			}
			_yetUnits.length = 0;	// 消去
			
		}
		
		/**
		 * 頂点の重複を考慮したIDを返す
		 * @param	x
		 * @param	y
		 * @return
		 */
		private function getOverlapKey(x:Number, y:Number):int 
		{
			var xy:String = x + "," + y;
			if (!overlap[xy]) overlap[xy] = ++overlapCount;
			return overlap[xy];
		}
		
		//--------------------------------------------------------------------------
		//
		//  ユニットの追加や削除
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 全てのユニットを削除する
		 */
		public function removeAllUnit():void
		{
			while (_units.length)
			{
				removeUnit(_units[0]);
			}
			while (_bosses.length)
			{
				removeUnit(_bosses[0]);
			}
		}
		
		/**
		 * 全てのコリジョンを削除する
		 */
		private function disposeCollision():void
		{
			_collisions.length = 0;
		}
		
		/**
		 * 移動の対象となるユニットを配置する
		 *
		 * @param unit 追加するユニット
		 */
		public function addUnit(unit:CollisionUnit):CollisionUnit 
		{
			if (!_wallTree || !_unitTree)
			{
				// 空間初期化前なら、後で初期化するリストに入れる
				_yetUnits.push(unit);
				return unit;
			}
			return addUnit_(unit);
		}
		/** 移動の対象となるユニットを配置する本処理 */
		private function addUnit_(unit:CollisionUnit):CollisionUnit
		{
			if (_units.indexOf(unit) == -1) _units.push(unit);
			if (unit._exclusion && _bosses.indexOf(unit) == -1) _bosses.push(unit);
			updateIndex();
			_wallTree.addData(unit.wallTreeData);
			_unitTree.addData(unit.unitTreeData);
			unit._addToWorld();
			return unit;
		}
		
		/**
		 * 移動の対象となるユニットを削除する
		 * 
		 * @param unit 削除するユニット
		 */
		public function removeUnit(unit:CollisionUnit):void
		{
			var i:int;
			
			i = _units.indexOf(unit);
			if (i != -1)
			{
				_units.splice(i, 1);
				unit._removeFromWorld();
			}
			
			i = _bosses.indexOf(unit);
			if (i != -1)
			{
				_bosses.splice(i, 1);
				unit._removeFromWorld();
			}
			updateIndex();
		}
		
		/**
		 * 全ユニットのインデックス番号を更新する
		 */
		private function updateIndex():void
		{
			var n:int = _units.length;
			for (var i:int = 0; i < n; i++) 
			{
				_units[i]._index = i;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  メイン処理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * すべてのユニットが、目的位置へ移動しようとする際の壁の判定を計算し
		 * 実際の結果を代入する。
		 */
		public function update():void
		{
			var unit:CollisionUnit;
			//ぬるり処理
			for each (unit in _units) 
			{
				if (!unit.enabled) continue;
				for each (var tunit:CollisionUnit in getNearUnits(unit)) 
				{
					if (!tunit.enabled) continue;
					nururi(unit, tunit);
				}
			}
			
			//衝突判定処理
			for each (unit in _units)
			{
				//コリジョンが無効または動かないなら処理しない
				if (!unit.enabled || (!unit._velocity.x && !unit._velocity.y)) continue;
				//壁との衝突判定
				calculateCollision(unit);
			}
			
			//ボスユニットがキャラクターを強制的に押し出す
			for each (var b:CollisionUnit in _bosses)
			{
				if (!b.enabled) continue;
				for each (unit in getNearUnits(b))
				{
					if (!unit.enabled) continue;
					exclude(b, unit);
					//コリジョンが動かないなら処理しない
					if (!unit._velocity.x && !unit._velocity.y) continue;
					calculateCollision(unit);
				}
			}
		}
		
		/**
		 * 指定ユニットの衝突判定を計算して位置を更新する
		 * @param	unit
		 */
		private function calculateCollision(unit:CollisionUnit):void 
		{
			//初期ベクトルを保存する
			unit._saveVelocity();
			unit._collideList.length = 0;
			
			//壁ずり処理の関係で最低2回処理を実行する必要がある
			//四分木の絞り込みも壁ずりで変化した新しい移動ベクトルで再検索する必要がある
			var loop:int = 3;
			for (var i:int = 0; i < loop; i++) 
			{
				collidedKey = { };
				unit._updateRect();
				var targets:Vector.<BaseCollision> = getCollisions(unit);
				_collideData.length = 0;
				
				//絞り込んだオブジェクトとの交差をチェック
				for each (var tgt:BaseCollision in targets)
				{
					if (tgt is LineCollision)
					{
						if (!tgt.enabled) continue;
						var cd:CollideData = hitUnitToLine(unit, tgt as LineCollision);
						if(cd) _collideData.push(cd);
					}
				}
				
				//交差したオブジェクトがあれば位置調整＆壁ずり
				if (_collideData.length)
				{
					if (_collideData.length >= 2)
					{
						_collideData.sort(sortDistance);
					}
					moveUnit(unit, _collideData[0]);
					if (i == loop - 1)
					{
						unit._velocity.x = unit._velocity.y = 0;
					}
				}
				
				if (!unit._velocity.x && !unit._velocity.y)
				{
					break;
				}
				collidedKey = null;
			}
			unit._fixPoint();
		}
		
		private function sortDistance(a:CollideData, b:CollideData):int
		{
			return int(a.distance > b.distance) - int(a.distance < b.distance);
		}
		
		/**円と直線の交差判定処理内で一時的に使う*/
		private var collideList:Vector.<CollideData> = new Vector.<CollideData>;
		
		/**
		 * 動く円と直線を衝突判定
		 * @param	c
		 * @param	l
		 */
		private function hitUnitToLine(c:CollisionUnit, l:LineCollision):CollideData
		{
			collideList.length = 0;
			//円ユニットの初期位置
			var cx:Number = c._x;
			var cy:Number = c._y;
			//移動後の位置
			var px:Number = cx + c._velocity.x;
			var py:Number = cy + c._velocity.y;
			//ラインの始点
			var bx:Number = l.origin.x;
			var by:Number = l.origin.y;
			//ラインの終点
			var ex:Number = l.end.x;
			var ey:Number = l.end.y;
			
			//ラインと円の軌跡が交差しているかおおざっぱに矩形で判定
			if (c._sweepRect.left > l._rect.right || c._sweepRect.right < l._rect.left || c._sweepRect.top > l._rect.bottom || c._sweepRect.bottom < l._rect.top)
			{
				return null;
			}
			
			var vx:Number = c._velocity.x;
			var vy:Number = c._velocity.y;
			//ユニットの移動ベクトルの長さの二乗
			var vlength:Number = vx * vx + vy * vy;
			
			//----------------------------------------------------
			//	線分の両端との接触処理
			//----------------------------------------------------
			
			var cd:CollideData;
			var cp:Point;
			var dist:Number;
			var dx:Number;
			var dy:Number;
			//始点=0と終点=1
			for (var i:int = 0; i < 2; i++) 
			{
				//同一頂点の円との交差を既にチェックしていたらスキップ
				var key:int = (i == 0)? l.originKey : l.endKey;
				if (collidedKey[key]) continue;
				collidedKey[key] = true;
				
				var ctx:Number = (i == 0)? bx : ex;
				var cty:Number = (i == 0)? by : ey;
				//円と直線の交差位置
				var cps:Array = Collision2DUtil.getIntersectionLineCircleXY(cx, cy, px, py, ctx, cty, c.radius);
				if (cps.length > 0)
				{
					if (cps.length == 2)
					{
						var d1x:Number = cps[0].x - cx;
						var d1y:Number = cps[0].y - cy;
						var d2x:Number = cps[1].x - cx;
						var d2y:Number = cps[1].y - cy;
						cp = (d1x * d1x + d1y * d1y < d2x * d2x + d2y * d2y)? cps[0] : cps[1];
					}
					else
					{
						cp = cps[0];
					}
					dx = cp.x - cx;
					dy = cp.y - cy;
					dist = dx * dx + dy * dy;
					if (dist <= vlength)
					{
						cd = new CollideData(c, l, CollideData.CIRCLE, cp.x, cp.y, dist);
						cd.centerX = ctx;
						cd.centerY = cty;
						cd.normalX = cp.x - ctx;
						cd.normalY = cp.y - cty;
						collideList.push(cd);
					}
				}
			}
			
			//----------------------------------------------------
			// ライン上での接触処理
			//----------------------------------------------------
			
			//外積で円の初期位置がラインのどちら側にあるかチェック//ax * by - ay * bx
			var cross:Number = (cx - bx) * (ey - by) - (cy - by) * (ex - bx);
			//円がライン上にあったら処理しない
			if (cross)
			{
				var d:Number = (cross < 0)? -c.radius : c.radius;
				//ラインを円の半径分オフセットする
				var nx:Number = l.normal.x * d;
				var ny:Number = l.normal.y * d;
				//オフセットした新しいラインの始点/終点
				var lx1:Number = bx + nx, ly1:Number = by + ny;
				var lx2:Number = ex + nx, ly2:Number = ey + ny;
				
				//オフセットラインと移動ベクトルとの交差点
				cp = Collision2DUtil.getIntersection2LineXY(lx1, ly1, lx2, ly2, false, cx, cy, px, py, true);
				//移動ベクトルとラインが平行なら処理しない
				if (cp)
				{
					dx = cp.x - cx, dy = cp.y - cy;
					dist = dx * dx + dy * dy;
					if (dist <= vlength)
					{
						cd = new CollideData(c, l, CollideData.LINE, cp.x, cp.y, dist);
						cd.normalX = nx;
						cd.normalY = ny;
						collideList.push(cd);
					}
				}
			}
			if (!collideList.length) return null;
			
			if (collideList.length >= 2)
			{
				collideList.sort(sortDistance);
			}
			cd = collideList[0];
			//交差点の法線と移動ベクトルの角度を求める
			var nmx:Number = cd.normalX;
			var nmy:Number = cd.normalY;
			var cos:Number = (nmx * vx + nmy * vy) / (Math.sqrt(nmx * nmx + nmy * nmy) * Math.sqrt(vlength));
			var angle:Number = Math.acos(cos > 1? 1 : (cos < -1? -1 : cos));
			if (angle <= Math.PI / 2) return null;
			return cd;
		}
		
		//--------------------------------------------------------------------------
		//
		//  対象を絞り込む
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 対象のキャラクターと当たる可能性のあるコリジョンを返す
		 * @param	unit
		 */
		private function getCollisions(unit:CollisionUnit):Vector.<BaseCollision>
		{
			var list:Vector.<BaseCollision> = new Vector.<BaseCollision>;
			for each (var col:BaseCollision in getNearCollisions(unit)) 
			{
				//無効なコリジョンは除外する
				if (!col._enabled) continue;
				//線分コリジョンだった場合、裏を向いているものを除外する
				if (col._type == CollisionType.LINE)
				{
					var l:LineCollision = col as LineCollision;
					if (l.surface != LineSurface.BOTH)
					{
						//外積で線分に対してどちら側にいるか調べる
						var ax:Number = unit._x - l.origin.x;
						var ay:Number = unit._y - l.origin.y;
						var bx:Number = l.end.x - l.origin.x;
						var by:Number = l.end.y - l.origin.y;
						var cross:Number = ax * by - ay * bx;
						if (cross > 0 && l.surface == LineSurface.RIGHT) continue;
						if (cross < 0 && l.surface == LineSurface.LEFT) continue;
					}
				}
				//一度交差したコリジョンは除外する
				var skip:Boolean = false;
				for each (var cd:CollideData in unit._collideList) 
				{
					if (cd.collision == col)
					{
						skip = true;
						break;
					}
				}
				if (!skip) list.push(col);
			}
			return list;
		}
		
		/**
		 * 近くのユニットをリストアップ
		 * @param	unit
		 * @return
		 */
		private function getNearUnits(unit:CollisionUnit):Vector.<CollisionUnit>
		{
			var list:Vector.<CollisionUnit> = new Vector.<CollisionUnit>;
			if (_useQuadTree)
			{
				_unitTree.checkNearCollision(unit.unitTreeData);
				for each(var t:TreeData in unit.unitTreeData.collisions)
				{
					list.push(t.data);
				}
			}
			else
			{
				for each (var u:CollisionUnit in _units) 
				{
					if (u != unit) list.push(u);
				}
			}
			return list;
		}
		
		/**
		 * 近くのコリジョンをリストアップ
		 * @param	unit
		 * @return
		 */
		private function getNearCollisions(unit:CollisionUnit):Vector.<BaseCollision>
		{
			var list:Vector.<BaseCollision>;
			if (_useQuadTree)
			{
				_wallTree.checkNearCollision(unit.wallTreeData);
				list = new Vector.<BaseCollision>;
				for each(var t:TreeData in unit.wallTreeData.collisions)
				{
					if (t.data is BaseCollision) list.push(t.data);
				}
			}
			else
			{
				list = _collisions;
			}
			return list;
		}
		
		//--------------------------------------------------------------------------
		//
		//  壁ずり
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 壁ずり処理
		 * @param	c
		 * @param	near
		 */
		private function moveUnit(c:CollisionUnit, cd:CollideData):void 
		{
			//円の初期位置/移動後の位置
			var cx:Number = c._x, cy:Number = c._y;
			var px:Number = cx + c._fVelocity.x, py:Number = cy + c._fVelocity.y;
			
			c._x = cd.x;
			c._y = cd.y;
			
			//壁ずり用単位ベクトル
			var nmx:Number, nmy:Number;
			
			//対象がラインならラインに沿って移動
			if (cd.type == CollideData.LINE)
			{
				nmx = LineCollision(cd.collision).vector.x;
				nmy = LineCollision(cd.collision).vector.y;
			}
			
			//対象が円なら接線に沿って移動
			if (cd.type == CollideData.CIRCLE)
			{
				var vx:Number = cd.x - cd.centerX;
				var vy:Number = cd.y - cd.centerY;
				var vl:Number = vx * vx + vy * vy;
				if (vl != 1)
				{
					var m:Number = Math.sqrt(vl);
					vx /= m;
					vy /= m;
				}
				nmx = -vy;
				nmy = vx;
			}
			
			//壁ずり量を内積で求める
			var ax:Number = px - cd.x, ay:Number = py - cd.y;
			//dot = ax * bx + ay * by
			var t:Number = ax * nmx + ay * nmy;
			var vtx:Number = nmx * t;
			var vty:Number = nmy * t;
			
			//壁ずり制限をかける（壁ずり先に別の壁があった場合）
			for each(var ld:CollideData in c._collideList)
			{
				//(ld.normalX,ld.normalY)と(vtx,vty)の内積//dot = ax * bx + ay * by
				if (ld.normalX * vtx + ld.normalY * vty >= 0) continue;
				var cp:Point = Collision2DUtil.getIntersection2LineXY(ld.x, ld.y, ld.x + ld.vx, ld.y + ld.vy, false, c._x, c._y, c._x + vtx, c._y + vty, false);
				if (!cp) continue;
				//cpとcの距離の2乗とtの2乗を比較
				var dx:Number = cp.x - c._x;
				var dy:Number = cp.y - c._y;
				if (dx * dx + dy * dy < t * t)
				{
					vtx = cp.x - c._x;
					vty = cp.y - c._y;
				}
			}
			
			//壁ずりベクトルで移動させる
			c.setVelocity(vtx, vty);
			
			//移動制限データ(壁ずりの移動で別の壁にめり込ませない為)
			cd.vx = vtx;
			cd.vy = vty;
			c._collideList.push(cd);
		}
		
		//--------------------------------------------------------------------------
		//
		//  押し出し処理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 指定ユニットが相手ユニットを強制的に押し出す
		 * @param	unit	指定ユニット
		 * @param	target	相手ユニット
		 */
		internal function exclude(unit:CollisionUnit, target:CollisionUnit):void 
		{
			if (target._fix) return;
			
			//自分が楕円で相手がボスでない場合は、楕円処理で押し出す
			if (!target._exclusion && unit._polygon)
			{
				excludeEllipse(unit, target);
				return;
			}
			
			var dx:Number = unit._x - target._x, dy:Number = unit._y - target._y;
			var dd:Number = dx * dx + dy * dy;
			var r:Number = unit._nururiRadius + target._nururiRadius;
			var rr:Number = r * r;
			if (rr <= dd) return;
			
			var t:Number = (dd > 0)? Math.sqrt(dd) : 1;
			
			var vx:Number = -dx / t;
			var vy:Number = -dy / t;
			target.addVelocity(unit._x + vx * r - target._x, unit._y + vy * r - target._y);
		}
		
		/**
		 * unitがtargetをぬるりで押し出す
		 * ・相手と自分のぬるり率の合計と自分のぬるり率の比で相手を押し出す比率を求める
		 * ・お互いの距離が近いほど相手を押し出す力が強まる
		 * ・相手がボスユニットの場合は押し出さない
		 * @param	unit	指定ユニット
		 * @param	target	相手ユニット
		 */
		internal function nururi(unit:CollisionUnit, target:CollisionUnit):void 
		{
			if (unit._exclusion || target._exclusion || target._fix) return;
			
			var dx:Number = unit._x - target._x, dy:Number = unit._y - target._y;
			var dd:Number = dx * dx + dy * dy;
			var r:Number = unit._nururiRadius + target._nururiRadius;
			var rr:Number = r * r;
			if (rr <= dd) return;
			
			var t:Number = (dd > 0)? Math.sqrt(dd) : 1;
			var pushRate:Number = unit._nururiRate / (unit._nururiRate + target._nururiRate) || 0;
			var nearRate:Number = 1 - dd / rr;
			var per:Number = -r / 2 * pushRate * nearRate / t;
			
			target.addVelocity(dx * per, dy * per);
		}
		
		/**
		 * unitがtargetを強制的に押し出す（多角形版）
		 * @param	unit
		 * @param	target
		 */
		internal function excludeEllipse(unit:CollisionUnit, target:CollisionUnit):void 
		{
			if (target._fix) return;
			unit._polygon.x = unit._x;
			unit._polygon.y = unit._y;
			unit._polygon.rotation = unit._rotation;
			var p:Point = unit._polygon.intersectCircle(target._x, target._y, target._radius);
			if (!p) return;
			var vx:Number = p.x - target._x;
			var vy:Number = p.y - target._y;
			
			target.addVelocity(vx, vy);
		}

		public function getFieldRectangle():Rectangle
		{
			return _fieldRectangle;
		}

		
	}

}