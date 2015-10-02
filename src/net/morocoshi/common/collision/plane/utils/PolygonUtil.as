package net.morocoshi.common.collision.plane.utils 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class PolygonUtil 
	{
		
		static public function createEllipse(radiusX:Number, radiusY:Number, segments:int):Vector.<Number>
		{
			if (segments <= 1) throw new Error("多角形の角数が不正です");
			var pointList:Vector.<Number> = new Vector.<Number>;
			for (var i:int = 0; i <= segments; i++) 
			{
				var rad:Number = Math.PI * 2 / segments * i;
				var x1:Number = Math.cos(rad) * radiusX;
				var y1:Number = Math.sin(rad) * radiusY;
				pointList.push(x1, y1);
			}
			return pointList;
		}
		
	}

}