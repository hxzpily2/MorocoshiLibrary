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
		static public const TYPE_MATERIAL:String = "material";
		static public const TYPE_CURVE:String = "curve";
		static public const TYPE_MATRIX:String = "matrix";
		static public const TYPE_MOTIONLESS_MATRIX:String = "motionlessMatrix";
		/***/
		public var type:String;
		
		/**[type=TYPE_MATERIAL時使用]UVオフセットデータ*/
		public var material:M3DTrackUV;
		/**[type=TYPE_CURVE時使用]位置カーブデータ*/
		public var position:M3DTrackXYZ;
		/**[type=TYPE_CURVE時使用]回転カーブデータ*/
		public var rotation:M3DTrackXYZ;
		/**[type=TYPE_CURVE時使用]スケールカーブデータ*/
		public var scale:M3DTrackXYZ;
		/**[type=TYPE_MATRIX時使用]Matrix3Dデータ*/
		public var matrix:M3DMatrixTrack;
		/**[type=TYPE_MOTIONLESS_MATRIX時使用]*/
		public var defaultMatrix:Vector.<Number>;
		/**[type=TYPE_CURVE時使用]足りない要素をここから使う*/
		public var defaultRotation:Vector3D;
		
		public function M3DAnimation() 
		{
		}
		
	}

}