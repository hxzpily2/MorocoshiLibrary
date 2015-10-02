package net.morocoshi.moja3d.loader.animation 
{
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DAnimation 
	{
		static public const TYPE_CURVE:String = "curve";
		static public const TYPE_MATRIX:String = "matrix";
		/***/
		public var type:String;
		
		/**[type=TYPE_CURVE時使用]位置カーブデータ*/
		public var position:M3DCurveAnimation;
		/**[type=TYPE_CURVE時使用]回転カーブデータ*/
		public var rotation:M3DCurveAnimation;
		/**[type=TYPE_CURVE時使用]スケールカーブデータ*/
		public var scale:M3DCurveAnimation;
		/**[type=TYPE_MATRIX時使用]Matrix3Dデータ*/
		public var matrix:M3DMatrixTrack;
		/**[type=TYPE_CURVE時使用]足りない要素をここから使う*/
		public var defaultRotation:Vector3D;
		
		public function M3DAnimation() 
		{
		}
		
	}

}