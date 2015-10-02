package net.morocoshi.moja3d.loader.geometries 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DLineGeometry extends M3DGeometry 
	{
		public var segmentList:Vector.<M3DLineSegment>;
		
		public function M3DLineGeometry() 
		{
		}
		
		override public function getKey():String 
		{
			var key:Array = [];
			for (var i:int = 0; i < segmentList.length; i++) 
			{
				var pointKey:Array = [];
				var seg:M3DLineSegment = segmentList[i];
				for (var j:int = 0; j < seg.pointList.length; j++) 
				{
					pointKey.push(seg.pointList[i].x, seg.pointList[i].y, seg.pointList[i].z);
				}
				key.push(pointKey.join(","));
			}
			return "line_" + key.join("|");
		}
		
	}

}