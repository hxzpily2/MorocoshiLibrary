package net.morocoshi.moja3d.resources 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FilterGeometry extends Geometry 
	{
		
		public function FilterGeometry() 
		{
			super();
			
			var vertices:Vector.<Number> = new <Number>[
				-1, -1, 0.5,
				1, -1, 0.5,
				-1, 1, 0.5,
				1, 1, 0.5
			];
			var uvs:Vector.<Number> = new <Number>[
				0, 1,
				1, 1,
				0, 0,
				1, 0
			];
			var indices:Vector.<uint> = new <uint>[0, 1, 2, 1, 3, 2];
			
			addVertices(VertexAttribute.POSITION, 3, vertices);
			addVertices(VertexAttribute.UV, 2, uvs);
			vertexIndices = indices;
		}
		
	}

}