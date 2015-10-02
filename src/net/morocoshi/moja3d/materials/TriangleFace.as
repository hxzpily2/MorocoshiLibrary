package net.morocoshi.moja3d.materials 
{
	/**
	 * Context3DTriangleFaceの裏表を逆にしたもの。Moja3Dではカリングが反転しているため。
	 * 
	 * @author tencho
	 */
	public class TriangleFace 
	{
		/**表面を表示*/
		static public const FRONT:String = "front";
		/**裏面を表示*/
		static public const BACK:String = "back";
		/**両面を表示*/
		static public const BOTH:String = "none";
		/**両面を非表示*/
		static public const NONE:String = "frontAndBack";
	}

}