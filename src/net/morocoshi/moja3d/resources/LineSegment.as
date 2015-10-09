package net.morocoshi.moja3d.resources 
{
	import flash.geom.Vector3D;
	
	/**
	 * LineGeometryがもつ線分/曲線セグメント
	 * @author tencho
	 */
	public class LineSegment 
	{
		public var pointList:Vector.<Vector3D>;
		
		public function LineSegment() 
		{
			pointList = new Vector.<Vector3D>;
		}
		
	}

}