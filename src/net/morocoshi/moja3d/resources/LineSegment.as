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
		public var pointList:Vector.<LinePoint>;
		
		public function LineSegment() 
		{
			thickness = 1;
			pointList = new Vector.<LinePoint>;
		}
		
	}

}