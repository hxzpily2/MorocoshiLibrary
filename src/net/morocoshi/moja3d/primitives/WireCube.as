package net.morocoshi.moja3d.primitives 
{
	import net.morocoshi.moja3d.objects.Line3D;
	import net.morocoshi.moja3d.resources.LineSegment;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class WireCube extends Line3D 
	{
		
		public function WireCube(sizeX:Number, sizeY:Number, sizeZ:Number, thickness:Number = 1, color:uint = 0xffffff, alpha:Number = 1) 
		{
			super();
			var sx:Number = sizeX * 0.5;
			var sy:Number = sizeY * 0.5;
			var sz:Number = sizeZ * 0.5;
			var segment:LineSegment;
			
			for each(var p:Array in [[1, 1], [-1, 1], [-1, -1], [1, -1]])
			{
				segment = lineGeometry.addSegment(thickness);
				segment.addPoint(sx * p[0], sy * p[1], +sz, color, alpha);
				segment.addPoint(sx * p[0], sy * p[1], -sz, color, alpha);
				segment = lineGeometry.addSegment(thickness);
				segment.addPoint(sx * p[0], +sy, sz * p[1], color, alpha);
				segment.addPoint(sx * p[0], -sy, sz * p[1], color, alpha);
				segment = lineGeometry.addSegment(thickness);
				segment.addPoint(+sx, sy * p[0], sz * p[1], color, alpha);
				segment.addPoint(-sx, sy * p[0], sz * p[1], color, alpha);
			}
		}
		
	}

}