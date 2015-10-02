package net.morocoshi.moja3d.loader.animation 
{
	/**
	 * 補完タイプ
	 * 
	 * @author tencho
	 */
	public class TangentType 
	{
		/**未指定*/
		static public const NONE:int = -1;
		/**補完無し*/
		static public const STEP:int = 0;
		/**直線*/
		static public const LINER:int = 1;
		/**エルミート曲線*/
		static public const HERMITE:int = 2;
		/**ベジェ曲線*/
		static public const BEZIER:int = 3;
		
		public function TangentType() 
		{
		}
		
	}

}