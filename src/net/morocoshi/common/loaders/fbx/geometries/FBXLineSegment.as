package net.morocoshi.common.loaders.fbx.geometries 
{
	import flash.geom.Vector3D;
	
	/**
	 * シェイプの頂点リスト
	 * 
	 * @author tencho
	 */
	public class FBXLineSegment 
	{
		
		public var pointList:Vector.<Vector3D>;
		
		public function FBXLineSegment() 
		{
			pointList = new Vector.<Vector3D>;
		}
		
		public function addPoint(x:Number, y:Number, z:Number):void 
		{
			pointList.push(new Vector3D(x, y, z));
		}
		
		public function clone():FBXLineSegment 
		{
			var seg:FBXLineSegment = new FBXLineSegment();
			var n:int = pointList.length;
			for (var i:int = 0; i < n; i++) 
			{
				seg.pointList.push(pointList[i].clone());
			}
			return seg;
		}
		
	}

}