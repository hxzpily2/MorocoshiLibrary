package net.morocoshi.moja3d.shaders 
{
	/**
	 * ピクセルの透過状況
	 * 
	 * @author tencho
	 */
	public class AlphaState 
	{
		/**透明要素が不明*/
		static public const UNKNOWN:uint = 0;
		/**不透明ピクセルのみ*/
		static public const OPAQUE:int = 1;
		/**半透明ピクセルのみ*/
		static public const TRANSPARENT:int = 2;
		/**不透明と半透明が混在*/
		static public const MIXTURE:int = 3;
		
	}

}