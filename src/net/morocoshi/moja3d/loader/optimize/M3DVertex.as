package net.morocoshi.moja3d.loader.optimize 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DVertex 
	{
		public var vertex:Array;
		public var normal:Array;
		public var uv:Array;
		public var tangent4:Array;
		public var color:Array;
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
			if (tangent4) result.push("1:" + tangent4.join(","));
			if (vertex) result.push("2:" + vertex.join(","));
			if (normal) result.push("3:" + normal.join(","));
			if (weight1) result.push("4:" + weight1.join(","));
			if (color) result.push("5:" + color.join(","));
			if (boneIndex1) result.push("6:" + boneIndex1.join(","));
			if (uv) result.push("7:" + uv.join(","));
			if (weight2) result.push("8:" + weight2.join(","));
			if (boneIndex2) result.push("9:" + boneIndex2.join(","));
			return result.join("_");
		}
		
	}

}