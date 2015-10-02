package net.morocoshi.common.math.geom
{
	import flash.geom.Point;
	
	/**
	 * 直線処理
	 * 
	 * @author	tencho
	 */
	public class LineUtil
	{
		/**
		 * 線分/直線の交点をPointで求める（先端が接触していても交差とみなす）
		 */
		static public function getIntersection2Line(a1:Point, a2:Point, segment1:Boolean, b1:Point, b2:Point, segment2:Boolean):Point
		{
			return getIntersection2LineXY(a1.x, a1.y, a2.x, a2.y, segment1, b1.x, b1.y, b2.x, b2.y, segment2);
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
		 * 線分/直線が交差しているかPointで調べる（先端が接触していても交差とみなす）
		 */
		static public function intersect2Line(a1:Point, a2:Point, segment1:Boolean, b1:Point, b2:Point, segment2:Boolean):Boolean
		{
			return intersect2LineXY(a1.x, a1.y, a2.x, a2.y, segment1, b1.x, b1.y, b2.x, b2.y, segment2);
		}
		
		/**
		 * 線分/直線が交差しているかXYで調べる（先端が接触していても交差とみなす）
		 */
		static public function intersect2LineXY(ax1:Number, ay1:Number, ax2:Number, ay2:Number, segment1:Boolean, bx1:Number, by1:Number, bx2:Number, by2:Number, segment2:Boolean):Boolean
		{
			if (segment1 && ((ax1 - ax2) * (by1 - ay1) + (ay1 - ay2) * (ax1 - bx1)) * ((ax1 - ax2) * (by2 - ay1) + (ay1 - ay2) * (ax1 - bx2)) > 0) return false;
			if (segment2 && ((bx1 - bx2) * (ay1 - by1) + (by1 - by2) * (bx1 - ax1)) * ((bx1 - bx2) * (ay2 - by1) + (by1 - by2) * (bx1 - ax2)) > 0) return false;
			return true;
		}
		
		/**
		 * 点と線分の最短距離をPointで求める
		 * @param	a	線分の始点
		 * @param	b	線分の終点
		 * @param	p	点
		 * @param	square	Math.sqrt()を省略して結果を二乗する
		 * @return
		 */
		static public function getDistancePointSegment(a:Point, b:Point, p:Point, square:Boolean = false):Number
		{
			return getDistancePointSegmentXY(a.x, a.y, b.x, b.y, p.x, p.y, square);
		}
		
		/**
		 * 点と線分の最短距離をXYで求める
		 * @param	x1	線分の始点X
		 * @param	y1	線分の始点Y
		 * @param	x2	線分の終点X
		 * @param	y2	線分の終点Y
		 * @param	px	点X
		 * @param	py	点Y
		 * @param	square	Math.sqrt()を省略して結果を二乗する
		 * @return
		 */
		static public function getDistancePointSegmentXY(x1:Number, y1:Number, x2:Number, y2:Number, px:Number, py:Number, square:Boolean = false):Number
		{
			var dx:Number = x2 - x1, dy:Number = y2 - y1;
			var t:Number = -(dx * (x1 - px) + dy * (y1 - py)) / (dx * dx + dy * dy);
			t = (t < 0)? 0 : (t > 1)? 1 : t;
			var tx:Number = x1 + dx * t;
			var ty:Number = y1 + dy * t;
			var l:Number = (px - tx) * (px - tx) + (py - ty) * (py - ty);
			return (square)? l : Math.sqrt(l);
		}
		
		/**
		 * 点と直線の最短距離をPointで求める
		 * @param	a
		 * @param	b
		 * @param	p
		 * @param	square	Math.sqrt()を省略して結果を二乗する
		 * @return
		 */
		static public function getDistancePointLine(a:Point, b:Point, p:Point, square:Boolean = false):Number
		{
			return getDistancePointLineXY(a.x, a.y, b.x, b.y, p.x, p.y, square);
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
		 * 直線とある点から下ろした垂線との交点をPointで求める
		 * @param	a
		 * @param	b
		 * @param	p
		 * @return
		 */
		static public function getIntersectionLinePerp(a:Point, b:Point, p:Point):Point
		{
			return getIntersectionLinePerpXY(a.x, a.y, b.x, b.y, p.x, p.y);
		}
		
		/**
		 * 直線とある点から下ろした垂線との交点をXYで求める
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
		
	}

}