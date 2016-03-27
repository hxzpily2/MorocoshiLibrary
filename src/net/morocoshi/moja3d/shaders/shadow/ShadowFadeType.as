package net.morocoshi.moja3d.shaders.shadow 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ShadowFadeType 
	{
		/**シャドウ範囲の中心点から外側に向かってフェードする*/
		static public const RADIAL_GRADIENT:String = "radialGradient";
		/**シャドウ範囲の中心点から外側に向かってフェードする*/
		static public const DIAMOND_GRADIENT:String = "diamondGradient";
		/**シャドウ範囲内のみ影を描画*/
		static public const CLIP_BORDER:String = "clipBorder";
		/**カメラ距離でフェードする*/
		static public const CASCADE:String = "cascade";
		
		public function ShadowFadeType() 
		{
		}
		
	}

}