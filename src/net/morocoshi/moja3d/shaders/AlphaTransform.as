package net.morocoshi.moja3d.shaders 
{
	/**
	 * シェーダーの計算によって半透明ピクセルが出るかどうかの判別用
	 * 
	 * @author tencho
	 */
	public class AlphaTransform 
	{
		/**不透明度は変化しない*/
		static public const UNCHANGE:uint = 0;
		/**不透明度は1にされる*/
		static public const SET_OPAQUE:uint = 1;
		/**不透明度は1未満にされる*/
		static public const SET_TRANSPARENT:uint = 2;
		/**不透明度は0～1にされる*/
		static public const SET_MIXTURE:uint = 3;
		/**不透明度に1未満が乗算される*/
		static public const MUL_TRANSPARENT:uint = 4;
		/**不透明度の値は予測不能になる*/
		static public const SET_UNKNOWN:uint = 5;
		
	}

}