package net.morocoshi.common.collision.plane.units 
{
	import flash.geom.Point;
	import net.morocoshi.common.collision.plane.utils.Collision2DUtil;
	
	/**
	 * モンスター用多角形コリジョン
	 * 
	 * @author tencho
	 */
	public class PolygonCollision 
	{
		public var x:Number;
		public var y:Number;
		public var rotation:Number;
		public var radias:Number;
		public var lineList:Vector.<PolygonLine>;
		private var prevRadius:Number;
		
		/**
		 * コンストラクタ
		 */
		public function PolygonCollision() 
		{
			x = 0;
			y = 0;
			radias = 0;
			rotation = 0;
			lineList = new Vector.<PolygonLine>;
		}
		
		/**
		 * 頂点リストで多角形を設定
		 * @param	pointList
		 */
		public function setPointList(pointList:Vector.<Number>):void 
		{
			var x1:Number;
			var y1:Number;
			lineList.length = 0;
			var n:int = pointList.length;
			radias = 0;
			for (var i:int = 0; i < n; i += 2) 
			{
				var x2:Number = pointList[i];
				var y2:Number = pointList[i + 1];
				var d:Number = x2 * x2 + y2 * y2;
				if (radias < d) radias = d;
				if (i > 0)
				{
					lineList.push(new PolygonLine(x1, y1, x2, y2));
				}
				x1 = x2;
				y1 = y2;
			}
			if (radias > 0) radias = Math.sqrt(radias);
		}
		
		/**
		 * 円との交差判定をして、円をコリジョン外に押し出す
		 * @param	px
		 * @param	py
		 * @param	radius
		 * @return
		 */
		public function intersectCircle(px:Number, py:Number, radius:Number):Point
		{
			var line:PolygonLine;
			//前回と半径サイズが違ったら多角形のオフセットを再計算
			if (prevRadius != radius)
			{
				for each (line in lineList) 
				{
					line.calculate(radius);
				}
			}
			prevRadius = radius;
			//頂点座標を変換する
			var cos:Number = Math.cos(-rotation);
			var sin:Number = Math.sin(-rotation);
			var gx:Number = px - x;
			var gy:Number = py - y;
			var tx:Number = gx * cos - gy * sin;
			var ty:Number = gx * sin + gy * cos;
			//点が多角形内に含まれるか
			for each (line in lineList) 
			{
				if (cross(line.vx, line.vy, line.px1 - tx, line.py1 - ty) <= 0)
				{
					return null;
				}
			}
			//押し出し
			var nearLine:PolygonLine;
			var min:Number = Number.MAX_VALUE;
			for each (line in lineList) 
			{
				var d:Number = Collision2DUtil.getDistancePointLineXY(line.px1, line.py1, line.px2, line.py2, tx, ty, true)
				if (min > d)
				{
					nearLine = line;
					min = d;
				}
			}
			
			var nx:Number;
			var ny:Number;
			var l:Number;
			
			if (dot(-nearLine.vx, -nearLine.vy, tx - nearLine.x1, ty - nearLine.y1) < 0)
			{
				//直線の先端の円周上に点を移動させる
				nx = tx - nearLine.x1;
				ny = ty - nearLine.y1;
				l = nx * nx + ny * ny;
				if (l >= radius * radius) return null;
				l = Math.sqrt(l);
				nx = nx / l * radius + nearLine.x1;
				ny = ny / l * radius + nearLine.y1;
			}
			else if (dot(nearLine.vx, nearLine.vy, tx - nearLine.x2, ty - nearLine.y2) < 0)
			{
				//直線の先端の円周上に点を移動させる
				nx = tx - nearLine.x2;
				ny = ty - nearLine.y2;
				l = nx * nx + ny * ny;
				if (l >= radius * radius) return null;
				l = Math.sqrt(l);
				nx = nx / l * radius + nearLine.x2;
				ny = ny / l * radius + nearLine.y2;
			}
			else
			{
				//最も近いライン上に点を移動させる
				min = Math.sqrt(min);
				nx = tx + nearLine.nx * min;
				ny = ty + nearLine.ny * min;
			}
			
			cos = Math.cos(rotation);
			sin = Math.sin(rotation);
			var mx:Number = nx * cos - ny * sin;
			var my:Number = nx * sin + ny * cos;
			mx += x;
			my += y;
			
			return new Point(mx, my);
		}
		
		//内積
		private function dot(ax:Number, ay:Number, bx:Number, by:Number):Number
		{
			return ax * bx + ay * by;
		}
		
		//外積
		private function cross(ax:Number, ay:Number, bx:Number, by:Number):Number
		{
			return ax * by - ay * bx;
		}
		
	}

}