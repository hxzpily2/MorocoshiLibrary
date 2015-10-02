package net.morocoshi.moja3d.renderer 
{
	/**
	 * drawするレイヤー
	 * 
	 * @author tencho
	 */
	public class RenderLayer 
	{
		/**不透明*/
		static public const OPAQUE:uint			= parseInt("00000", 2);
		/**半透明*/
		static public const TRANSPARENT:uint	= parseInt("00001", 2);
		/**最前面*/
		static public const FOREFRONT:uint		= parseInt("00010", 2);
		/**最背面*/
		static public const BACKGROUND:uint		= parseInt("00100", 2);
		/**2Dレイヤー*/
		static public const OVERLAY:uint		= parseInt("01111", 2);
	}

}