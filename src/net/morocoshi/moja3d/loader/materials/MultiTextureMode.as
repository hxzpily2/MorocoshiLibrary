package net.morocoshi.moja3d.loader.materials 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class MultiTextureMode 
	{
		
		static public const NORMAL:int = 0;
		static public const IGNORE_RGB:int = 1;
		static public const IGNORE_ALPHA:int = 2;
		static public const IGNORE_RGBA:int = 3;
		
		static public function getLabel(mode:int):String
		{
			switch(mode)
			{
				case NORMAL:		return "通常の書き出し";
				case IGNORE_ALPHA:	return "透過のみ無効";
				case IGNORE_RGB:	return "カラーのみ無効";
				case IGNORE_RGBA:	return "カラーと透過を無効";
			}
			return "----";
		}
		
	}

}