package net.morocoshi.common.collision.plane.wallData
{
	
	/**
	 * 線分による壁のデータ。
	 * 繋がった、複数の壁の集合体
	 * 
	 * @author tencho
	 */
	public class LineWallData implements IWallData
	{
		private var _type:int = WallType.POLYGON;
		private var _xyList:Vector.<Number>;
		private var _surface:int;
		
		/**
		 * 
		 * @param	xyList	xyの混合リスト。実際の壁の数はxyList.length / 2 - 1となる。[x0, y0, x1, y1, x2....]:type;
		 * @param	surface	コリジョンを持たせる面の向き。 [0:始点→終点ベクトルに対して右、1：始点→終点ベクトルに対して左、2：両面] LineSurfaceクラスでも設定できる。
		 */
		public function LineWallData(xyList:Vector.<Number>, surface:int)
		{
			_xyList = xyList.concat();
			_surface = surface;
		}
		
		public function get type():int 
		{
			return _type;
		}
		
		public function get surface():int 
		{
			return _surface;
		}
		
		public function get xyList():Vector.<Number> 
		{
			return _xyList;
		}
		
	}
	
}
