package net.morocoshi.common.loaders.fbx.geometries 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParseCollector;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * シェイプジオメトリ
	 * 
	 * @author tencho
	 */
	public class FBXLineGeometry extends FBXGeometry 
	{
		public var segmentList:Vector.<FBXLineSegment>;
		public function FBXLineGeometry() 
		{
			super();
		}
		
		override public function parse(node:FBXNode):void 
		{
			super.parse(node);
			
			segmentList = new Vector.<FBXLineSegment>;
			var points:Array = node.Points[0][0].a[0];
			var indices:Array = node.PointsIndex[0][0].a[0];
			var n:int = indices.length;
			var segment:FBXLineSegment = new FBXLineSegment();
			for (var i:int = 0; i < n; i++) 
			{
				var t:int = indices[i];
				var end:Boolean = false;
				if (t < 0)
				{
					t = t * -1 - 1;
					end = true;
				}
				segment.addPoint(points[t * 3], points[t * 3 + 1], points[t * 3 + 2]);
				if (end)
				{
					segmentList.push(segment);
					segment = new FBXLineSegment();
				}
			}
		}
		
		override public function setGeomMatrix(matrix:Matrix3D):void 
		{
			for each (var seg:FBXLineSegment in segmentList) 
			{
				var n:int = seg.pointList.length;
				for (var i:int = 0; i < n; i++) 
				{
					seg.pointList[i] = matrix.transformVector(seg.pointList[i]);
				}
			}
		}
		
		override public function rescale(x:int, y:int, z:int):void 
		{
			for each (var seg:FBXLineSegment in segmentList) 
			{
				var n:int = seg.pointList.length;
				for (var i:int = 0; i < n; i++) 
				{
					seg.pointList[i].x *= x;
					seg.pointList[i].y *= y;
					seg.pointList[i].z *= z;
				}
			}
		}
		
		override public function clone():FBXGeometry 
		{
			var geom:FBXLineGeometry = new FBXLineGeometry();
			geom.id = id;
			geom.ownerList = ownerList.concat();
			geom.param = param;
			geom.segmentList = new Vector.<FBXLineSegment>;
			var n:int = segmentList.length;
			for (var i:int = 0; i < n; i++) 
			{
				geom.segmentList.push(segmentList[i].clone());
			}
			return geom;
		}
		
	}

}