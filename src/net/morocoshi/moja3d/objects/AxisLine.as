package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.resources.LineSegment;
	
	/**
	 * XYZ軸
	 * 
	 * @author tencho
	 */
	public class AxisLine extends Line3D 
	{
		private var xAxis:LineSegment;
		private var yAxis:LineSegment;
		private var zAxis:LineSegment;
		private var _size:Number;
		private var _thickness:Number;
		
		public function AxisLine(size:Number, thickness:Number = 1) 
		{
			super();
			_thickness = thickness;
			xAxis = lineGeometry.addSegment(thickness);
			yAxis = lineGeometry.addSegment(thickness);
			zAxis = lineGeometry.addSegment(thickness);
			xAxis.addPoint(0, 0, 0, 0xff0000);
			xAxis.addPoint(1, 0, 0, 0xff0000);
			yAxis.addPoint(0, 0, 0, 0x00ff00);
			yAxis.addPoint(0, 1, 0, 0x00ff00);
			zAxis.addPoint(0, 0, 0, 0x0000ff);
			zAxis.addPoint(0, 0, 1, 0x0000ff);
			setScale(size);
		}
		
		public function get thickness():Number 
		{
			return _thickness;
		}
		
		public function set thickness(value:Number):void 
		{
			_thickness = value;
			xAxis.thickness = value;
			yAxis.thickness = value;
			zAxis.thickness = value;
		}
		
	}

}