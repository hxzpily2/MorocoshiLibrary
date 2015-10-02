package net.morocoshi.common.collision.plane.bounds 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class AABB2D 
	{
		public var xMin:Number;
		public var xMax:Number;
		public var yMin:Number;
		public var yMax:Number;
		
		public function AABB2D() 
		{
		}
		
		public function reset():void
		{
			xMin = Number.MAX_VALUE;
			yMin = Number.MAX_VALUE;
			xMax = -Number.MAX_VALUE;
			yMax = -Number.MAX_VALUE;
		}
		
	}

}