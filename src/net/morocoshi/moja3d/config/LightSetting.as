package net.morocoshi.moja3d.config 
{
	/**
	 * ライト関連の設定
	 * 
	 * @author ...
	 */
	public class LightSetting 
	{
		/**平行光源の最大数*/
		static public var numDirectionalLights:int = 2;
		/**点光源の最大数*/
		static public var numOmniLights:int = 0;
		/**平行光源のデプスシャドウの最大数*/
		static public var numDirectionalShadow:int = 1;
		/**デフォルトでメッシュオブジェクトが影を落とすかどうか*/
		static public var defaultCastShadow:Boolean = true;
		/**デフォルトでメッシュオブジェクトが光筋を伸ばすかどうか*/
		static public var defaultCastLight:Boolean = false;
		/**
		 * 
		 */
		public function LightSetting() 
		{
		}
		
	}

}