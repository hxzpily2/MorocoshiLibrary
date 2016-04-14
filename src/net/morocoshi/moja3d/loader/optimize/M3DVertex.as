package net.morocoshi.moja3d.loader.optimize 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DVertex 
	{
		public var vertex:Array;
		public var uv:Array;
		public var normal:Array;
		public var color:Array;
		public var tangent4:Array;
		public var weight1:Array;
		public var weight2:Array;
		public var boneIndex1:Array;
		public var boneIndex2:Array;
		
		public function M3DVertex() 
		{
		}
		
		public function getKey():String
		{
			var result:Array = [];
			if (vertex)		result.push("1:" + vertex.join(","));
			if (uv)			result.push("2:" + uv.join(","));
			if (normal)		result.push("3:" + normal.join(","));
			if (color)		result.push("4:" + color.join(","));
			if (tangent4)	result.push("5:" + tangent4.join(","));
			if (boneIndex1) result.push("6:" + boneIndex1.join(","));
			if (boneIndex2) result.push("7:" + boneIndex2.join(","));
			if (weight1)	result.push("8:" + weight1.join(","));
			if (weight2)	result.push("9:" + weight2.join(","));
			return result.join("_");
		}
		
	}

}