package net.morocoshi.common.collision.plane.units 
{
	
	/**
	 * 簡易多角形判定に使う線分データ
	 * @author tencho
	 */
	public class PolygonLine 
	{
		
		public var x1:Number;
		public var y1:Number;
		public var x2:Number;
		public var y2:Number;
		public var nx:Number;
		public var ny:Number;
		
		public var px1:Number;
		public var py1:Number;
		public var px2:Number;
		public var py2:Number;
		public var vx:Number;
		public var vy:Number;
		
		public function PolygonLine(x1:Number, y1:Number, x2:Number, y2:Number)
		{
			setPoint(x1, y1, x2, y2);
		}
		
		public function setPoint(x1:Number, y1:Number, x2:Number, y2:Number):void
		{
			this.x1 = x1;
			this.y1 = y1;
			this.x2 = x2;
			this.y2 = y2;
			vx = x1 - x2;
			vy = y1 - y2;
			nx = -vy;
			ny = vx;
			var d:Number = Math.sqrt(nx * nx + ny * ny);
			if (d != 1)
			{
				nx /= d;
				ny /= d;
			}
		}
		
		public function calculate(radius:Number):void
		{
			px1 = x1 + nx * radius;
			py1 = y1 + ny * radius;
			px2 = x2 + nx * radius;
			py2 = y2 + ny * radius;
		}
		
	}

}