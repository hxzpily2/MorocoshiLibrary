package net.morocoshi.common.data
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public class Temp
	{
		static public var byteArray:ByteArray = new ByteArray();
		static public var point:Point = new Point();
		static public var position:Vector3D = new Vector3D();
		static public var matrix2D:Matrix = new Matrix();
		static public var matrix3D:Matrix3D = new Matrix3D();
		static public var bitmapData:BitmapData;
		
		public function Temp()
		{
		}
	}
}