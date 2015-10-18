package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.materials.Material;
	/**
	 * UnionMeshのメッシュ統合処理で使う一時データ
	 * 
	 * @author tencho
	 */
	public class UnionData 
	{
		public var material:Material;
		public var vertexIndices:Vector.<uint>;
		public var vertex:Vector.<Number>;
		public var uv:Vector.<Number>;
		public var normal:Vector.<Number>;
		public var tangent4:Vector.<Number>;
		public var color:Vector.<Number>;
		public var vertexCount:int = 0;
		
		public function UnionData(material:Material) 
		{
			this.material = material;
			
			vertexIndices = new Vector.<uint>;
			vertex = new Vector.<Number>;
			uv = new Vector.<Number>;
			normal = new Vector.<Number>;
			tangent4 = new Vector.<Number>;
			color = new Vector.<Number>;
		}
		
		public function offsetVertexIndices(offset:int):void 
		{
			var n:int = vertexIndices.length;
			for (var i:int = 0; i < n; i++) 
			{
				vertexIndices[i] += offset;
			}
		}
		
	}

}