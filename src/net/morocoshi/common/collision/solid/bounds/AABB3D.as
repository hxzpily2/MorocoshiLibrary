package net.morocoshi.common.collision.solid.bounds 
{
	
	/**
	 * AABB領域
	 * 
	 * @author tencho
	 */
	public class AABB3D
	{
		public var xMin:Number;
		public var xMax:Number;
		public var yMin:Number;
		public var yMax:Number;
		public var zMin:Number;
		public var zMax:Number;
		
		public function AABB3D() 
		{
		}
		
		public function reset():void
		{
			xMin = Number.MAX_VALUE;
			yMin = Number.MAX_VALUE;
			zMin = Number.MAX_VALUE;
			xMax = -Number.MAX_VALUE;
			yMax = -Number.MAX_VALUE;
			zMax = -Number.MAX_VALUE;
		}
		
		public function hitTest(aabb:AABB3D):Boolean
		{
			if (aabb.xMin > xMax || aabb.yMin > yMax || aabb.zMin > zMax || aabb.xMax < xMin || aabb.yMax < yMin || aabb.zMax < zMin) return false;
			return true;
		}
		
	}

}