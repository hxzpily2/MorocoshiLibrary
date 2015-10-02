package net.morocoshi.common.collision.plane.collisions
{
	
	/**
	 * 線分のどちら側に当たり判定があるかを決める数値
	 * @author	tencho
	 */
	public class LineSurface 
	{
		
		/**始点→終点ベクトルに対して右側にコリジョンを持たせる*/
		static public const RIGHT:int = 0;
		/**始点→終点ベクトルに対して左側にコリジョンを持たせる*/
		static public const LEFT:int = 1;
		/**両面にコリジョンを持たせる*/
		static public const BOTH:int = 2;
		
		public function LineSurface() 
		{
		}
		
	}

}