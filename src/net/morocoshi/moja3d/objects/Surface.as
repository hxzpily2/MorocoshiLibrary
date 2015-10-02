package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	
	/**
	 * マテリアルサーフェイス
	 * 
	 * @author tencho
	 */
	public class Surface 
	{
		public var firstIndex:int;
		public var numTriangles:int;
		public var material:Material;
		/**頂点アルファで半透明になっているサーフェイス用*/
		public var layer:uint;
		
		/**
		 * 
		 * @param	material	マテリアル
		 * @param	firstIndex	頂点インデックスの開始位置。ポリ数*3
		 * @param	numTriangles	ポリゴン数
		 */
		public function Surface(material:Material = null, firstIndex:int = 0, numTriangles:int = -1) 
		{
			this.firstIndex = firstIndex;
			this.numTriangles = numTriangles;
			this.material = material;
			layer = RenderLayer.OPAQUE;
		}
		
	}

}