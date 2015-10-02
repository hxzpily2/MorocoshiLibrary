package net.morocoshi.moja3d.shaders 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AlphaMode 
	{
		/**半透明要素は全くなし*/
		static public const NONE:uint = 1;
		/**不透明と半透明が混ざっている可能性がある*/
		static public const MIX:uint = 3;
		/**全てが半透明*/
		static public const ALL:uint = 2;
		
		public function AlphaMode() 
		{
		}
		
	}

}