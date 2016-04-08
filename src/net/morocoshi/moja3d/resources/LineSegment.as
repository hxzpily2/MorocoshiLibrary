package net.morocoshi.moja3d.resources 
{
	import flash.geom.Vector3D;
	
	/**
	 * LineGeometryがもつ線分/曲線セグメント
	 * @author tencho
	 */
	public class LineSegment 
	{
		public var thickness:Number;
		public var points:Vector.<LinePoint>;
		
		public function LineSegment(thickness:Number = 1) 
		{
			this.thickness = thickness;
			points = new Vector.<LinePoint>;
		}
		
		public function addPoint(x:Number, y:Number, z:Number, color:uint = 0xffffff, alpha:Number = 1):LinePoint 
		{
			var p:LinePoint = new LinePoint(x, y, z, color, alpha);
			points.push(p);
			return p;
		}
		
		public function close():void 
		{
			if (points.length == 0) return;
			points.push(points[0]);
		}
		
	}

}