package net.morocoshi.common.math.geom 
{
	/**
	 * リサイズタイプ
	 * 
	 * @author tencho
	 */
	public class ScaleMode
	{
		
		/**アスペクト比を保ちつつ枠の隙間を完全に埋める合うようにリサイズする。*/
		static public const FULL:String = "full";
		/**アスペクト比を保ちつつ枠に合うようにリサイズする。*/
		static public const AUTO:String = "auto";
		/**アスペクト比を保ちつつ枠に合うようにリサイズする。枠より小さい画像はリサイズしない。*/
		static public const AUTO_SMALL:String = "autoSmall";
		/**アスペクト比を保ちつつ枠に合うようにリサイズする。枠より大きい画像はリサイズしない。*/
		static public const AUTO_LARGE:String = "autoLarge";
		/**アスペクト比を無視して枠に合うようにリサイズする。*/
		static public const FIT:String = "fit";
		/**リサイズしない。*/
		static public const NONE:String = "none";
		
	}

}