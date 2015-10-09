package net.morocoshi.moja3d.loader.geometries 
{
	import net.morocoshi.moja3d.loader.materials.M3DSurface;
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DCombinedGeometry extends M3DGeometry 
	{
		/**M3DMeshGeometryのIDのリスト。スキンは分割されている可能性があるため。*/
		public var geometryIDList:Vector.<int>;
		/**Vector.＜M3DSurface＞のリスト*/
		//public var surfacesList:Array;
		
		public function M3DCombinedGeometry() 
		{
			super();
			geometryIDList = new Vector.<int>;
			//surfacesList = [];
		}
		
	}

}