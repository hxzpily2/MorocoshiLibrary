package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.common.data.DataUtil;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.renderer.RenderLayer;
	
	use namespace moja3d;
	
	/**
	 * マテリアルサーフェイス
	 * 
	 * @author tencho
	 */
	public class Surface 
	{
		/**頂点インデックスの開始位置。ポリゴン数x3*/
		public var firstIndex:int;
		/**ポリゴン数*/
		public var numTriangles:int;
		/**マテリアル*/
		moja3d var _material:Material;
		/**頂点アルファで半透明になっているサーフェイス用*/
		public var layer:uint;
		/**合成ジオメトリ用*/
		private var linkedSurfaceList:Vector.<Surface>;
		
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
			_material = material;
			layer = RenderLayer.OPAQUE;
		}
		
		public function get material():Material 
		{
			return _material;
		}
		
		public function set material(value:Material):void 
		{
			_material = value;
			if (linkedSurfaceList)
			{
				for each(var surface:Surface in linkedSurfaceList)
				{
					surface._material = _material;
				}
			}
		}
		
		/**
		 * メモリ解放
		 */
		public function finaly():void
		{
			firstIndex = 0;
			numTriangles = 0;
			_material = null;
			layer = 0;
			if (linkedSurfaceList)
			{
				for each(var surface:Surface in linkedSurfaceList)
				{
					surface.finaly();
				}
				DataUtil.deleteVector(linkedSurfaceList);
				linkedSurfaceList = null;
			}
		}
		
		/**
		 * 
		 * @param	surfacesList
		 */
		public function linkSurfaces(surfacesList:Vector.<Vector.<Surface>>):void
		{
			linkedSurfaceList = new Vector.<Surface>;
			for each(var surfaces:Vector.<Surface> in surfacesList)
			for each(var surface:Surface in surfaces)
			{
				if (_material === surface._material)
				{
					linkedSurfaceList.push(surface);
				}
			}
		}
		
	}

}