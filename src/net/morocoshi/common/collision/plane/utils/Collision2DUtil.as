package net.morocoshi.common.collision.plane.utils 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import net.morocoshi.common.collision.plane.bounds.AABB2D;
	
	/**
	 * 各種衝突判定処理（そのうちCollision2DWorldに統合するかも）
	 * 
	 * @author tencho
	 */
	public class Collision2DUtil 
	{
		
		static private var point:Point = new Point();
		
		public function Collision2DUtil() 
		{
		}
		
		/**
		 * 点と直線の最短距離をXYで求める
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @param	px
		 * @param	py
		 * @param	square	Math.sqrt()を省略して結果を二乗する
		 * @return
		 */
		static public function getDistancePointLineXY(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number, square:Boolean = false):Number
		{
			var ax:Number = x2 - x1, ay:Number = y2 - y1;
			var bx:Number = px - x1, by:Number = py - y1;
			var c:Number = ax * by - ay * bx;
			var l:Number = ax * ax + ay * ay;
			if (!square)
			{
				if (c < 0) c = -c;
				l = Math.sqrt(l);
			}
			else
			{
				c = c * c;
			}
			return c / l;
		}
		
		/**
		 * 直線とある点から下ろした垂線との交点を求める
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @param	px
		 * @param	py
		 * @return
		 */
		static public function getIntersectionLinePerpXY(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number):Point
		{
			var vx:Number = x2 - x1, vy:Number = y2 - y1;
			var tx:Number = px - x1, ty:Number = py - y1;
			if (!vx && !vy) return null;
			
			var m:Number = vx * vx + vy * vy;
			if (m != 1)
			{
				m = Math.sqrt(m);
				vx /= m, vy /= m;
			}
			
			var d:Number = (vx * ty - vy * tx) / Math.sqrt(vx * vx + vy * vy);
			var nx:Number = vy, ny:Number = -vx;
			return new Point(px + nx * d, py + ny * d);
		}
		
		/**
		 * 線分/直線の交点をXYで求める（先端が接触していても交差とみなす）
		 * @param	ax1	ラインAの始点X
		 * @param	ay1	ラインAの始点Y
		 * @param	ax2	ラインAの終点X
		 * @param	ay2	ラインAの終点Y
		 * @param	segment1	ラインAを線分とする
		 * @param	bx1	ラインBの始点X
		 * @param	by1	ラインBの始点Y
		 * @param	bx2	ラインBの終点X
		 * @param	by2	ラインBの終点Y
		 * @param	segment2	ラインBを線分とする
		 * @return
		 */
		static public function getIntersection2LineXY(ax1:Number, ay1:Number, ax2:Number, ay2:Number, segment1:Boolean, bx1:Number, by1:Number, bx2:Number, by2:Number, segment2:Boolean):Point
		{
			if (segment1 && ((ax1 - ax2) * (by1 - ay1) + (ay1 - ay2) * (ax1 - bx1)) * ((ax1 - ax2) * (by2 - ay1) + (ay1 - ay2) * (ax1 - bx2)) > 0) return null;
			if (segment2 && ((bx1 - bx2) * (ay1 - by1) + (by1 - by2) * (bx1 - ax1)) * ((bx1 - bx2) * (ay2 - by1) + (by1 - by2) * (bx1 - ax2)) > 0) return null;
			var v1x:Number = ax2 - ax1, v1y:Number = ay2 - ay1;
			var v2x:Number = bx1 - ax1, v2y:Number = by1 - ay1;
			var v3x:Number = bx2 - bx1, v3y:Number = by2 - by1;
			var cross:Number = v3x * v1y - v3y * v1x;
			if (!cross) return null;
			var scale:Number = (v3x * v2y - v3y * v2x) / cross;
			return new Point(v1x * scale + ax1, v1y * scale + ay1);
		}
		
		/**
		 * 直線と円の交点をXYで求める
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 * @param	cx
		 * @param	cy
		 * @param	r
		 * @return
		 */
		static public function getIntersectionLineCircleXY(x1:Number, y1:Number, x2:Number, y2:Number, cx:Number, cy:Number, r:Number):Array
		{
			var vx:Number = x2 - x1, vy:Number = y2 - y1;
			var tx:Number = cx - x1, ty:Number = cy - y1;
			if (!vx && !vy) return [];
			var m:Number = vx * vx + vy * vy;
			if (m != 1)
			{
				m = Math.sqrt(m);
				vx /= m, vy /= m;
			}
			var d:Number = (vx * ty - vy * tx) / Math.sqrt(vx * vx + vy * vy);
			var px:Number = cx + vy * d, py:Number = cy - vx * d;
			if (d < 0) d = -d;
			if (d > r) return [];
			if (r == d) return [new Point(px, py)];
			var s:Number = Math.sqrt(r * r - d * d);
			var p1:Point = new Point(px - vx * s, py - vy * s);
			var p2:Point = new Point(px + vx * s, py + vy * s);
			if (s == 0) return [p1];
			else return [p1, p2];
		}
		
		/**
		 * （※調整中）楕円と点の衝突判定をして、衝突している場合は点が押し出された座標を返す
		 * @param	ex	楕円の中心X
		 * @param	ey	楕円の中心Y
		 * @param	rx	楕円の横径
		 * @param	ry	楕円の縦径
		 * @param	rad	楕円の角度
		 * @param	px	点X
		 * @param	py	点Y
		 * @return
		 */
		static public function intersectEllipsePoint(ex:Number, ey:Number, rx:Number, ry:Number, rad:Number, px:Number, py:Number):Point
		{
			/*
			var dx:Number = px - ex;
			var dy:Number = py - ey;
			var ppx:Number = dx * Math.cos(rad) + dy * Math.sin(rad);
			var ppy:Number = (dx * Math.sin(rad) + dy * Math.cos(rad)) * scale;
			*/
			
			var cos:Number = Math.cos(rad);
			var sin:Number = Math.sin(rad);
			var scale:Number = rx / ry;
			
			var a:Number = cos;
			var b:Number = sin;
			var c:Number = -scale * sin;
			var d:Number = scale * cos;
			var tx:Number = -ex * cos - ey * sin;
			var ty:Number = (ex * sin - ey * cos) * scale;
			
			//空間を楕円→円にして点の座標に反映
			var matrix:Matrix = new Matrix(a, c, b, d, tx, ty);
			point.x = px;
			point.y = py;
			var pp:Point = matrix.transformPoint(point);
			
			var dx:Number = pp.x;
			var dy:Number = pp.y;
			var intersect:Boolean = (dx * dx + dy * dy <= rx * rx);
			if (!intersect) return null;
			//円周上に押し出す
			pp.normalize(rx);
			
			//空間を円→楕円に戻して円周点の座標に反映する
			matrix.invert();
			pp = matrix.transformPoint(pp);
			return pp;
		}
		
		/**
		 * 
		 * @param	a
		 * @param	b
		 * @return
		 */
		static public function intersect2Aabb(a:AABB2D, b:AABB2D):Boolean
		{
			return !(a.xMin > b.xMax || a.yMin > b.yMax || a.xMax < b.xMin || a.yMax < b.yMin);
		}
		
	}

}