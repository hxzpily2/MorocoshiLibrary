package net.morocoshi.moja3d.resources 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	/**
	 * ...
	 * @author tencho
	 */
	public class LineGeometry extends Geometry 
	{
		public var segmentList:Vector.<LineSegment>;
		public function LineGeometry() 
		{
			super();
			segmentList = new Vector.<LineSegment>;
		}
		
		override public function calculateBounds(boundingBox:BoundingBox):void 
		{
			var minX:Number = Number.MAX_VALUE;
			var minY:Number = Number.MAX_VALUE;
			var minZ:Number = Number.MAX_VALUE;
			var maxX:Number = -Number.MAX_VALUE;
			var maxY:Number = -Number.MAX_VALUE;
			var maxZ:Number = -Number.MAX_VALUE;
			
			var n:int = segmentList.length;
			for (var i:int = 0; i < n; i++)
			{
				var segment:LineSegment = segmentList[i];
				var m:int = segment.pointList.length;
				for (var j:int = 0; j < m; j++)
				{
					var p:Vector3D = segment.pointList[j];
					if (minX > p.x) minX = p.x;
					if (minY > p.y) minY = p.y;
					if (minZ > p.z) minZ = p.z;
					if (maxX < p.x) maxX = p.x;
					if (maxY < p.y) maxY = p.y;
					if (maxZ < p.z) maxZ = p.z;
				}
			}
			
			boundingBox.minX = minX;
			boundingBox.minY = minY;
			boundingBox.minZ = minZ;
			boundingBox.maxX = maxX;
			boundingBox.maxY = maxY;
			boundingBox.maxZ = maxZ;
		}
		
	}

}