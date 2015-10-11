package net.morocoshi.moja3d.shaders 
{
	/**
	 * シェーダーの計算によって半透明ピクセルが出るかどうかの判別用
	 * 
	 * @author tencho
	 */
	public class AlphaMode 
	{
		/**半透明要素は全くなし*/
		static public const NONE:uint = 1;
		/**全てが半透明*/
		static public const ALL:uint = 2;
		/**不透明と半透明が混ざっている可能性がある*/
		static public const MIX:uint = 3;
		
		public function AlphaMode() 
		{
		}
		
	}

}