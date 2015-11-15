package net.morocoshi.moja3d.agal 
{
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import net.morocoshi.common.data.ByteArrayUtil;
	
	/**
	 * レンダリング時に各シェーダーに渡す情報
	 * 
	 * @author tencho
	 */
	public class AGALConstant 
	{
		static public const MATRIX:String = "matrix";
		static public const VECTOR:String = "vector";
		static public const BYTEARRAY:String = "bytearray";
		
		public var id:String;
		public var length:int;
		public var type:String;
		public var matrix:Matrix3D;
		public var vector:Vector.<Number>;
		public var bytes:ByteArray;
		public var transposed:Boolean;
		/**この定数が配列の一部かどうか*/
		public var listMode:Boolean;
		/**falseにするとレンダリング時に転送されなくなる*/
		public var enabled:Boolean;
		
		public function AGALConstant() 
		{
			enabled = true;
			listMode = false;
		}
		
		public function get x():Number
		{
			return vector[0];
		}
		public function set x(value:Number):void
		{
			vector[0] = value;
		}
		
		public function get y():Number
		{
			return vector[1];
		}
		public function set y(value:Number):void
		{
			vector[1] = value;
		}
		
		public function get z():Number
		{
			return vector[2];
		}
		public function set z(value:Number):void
		{
			vector[2] = value;
		}
		
		public function get w():Number
		{
			return vector[3];
		}
		public function set w(value:Number):void
		{
			vector[3] = value;
		}
		
		public function initVector(id:String, vector:Vector.<Number>):void
		{
			type = VECTOR;
			this.id = id;
			this.vector = vector;
			length = 1;
		}
		
		public function initMatrix(id:String, matrix:Matrix3D, transposed:Boolean):void
		{
			type = MATRIX;
			this.id = id;
			this.matrix = matrix;
			this.transposed = transposed;
			length = 4;
		}
		
		public function setVector(x:Number, y:Number, z:Number, w:Number):void
		{
			vector[0] = x;
			vector[1] = y;
			vector[2] = z;
			vector[3] = w;
		}
		
		public function setRGB(rgb:uint):void
		{
			vector[0] = (rgb >>> 16 & 0xFF) / 0xFF;
			vector[1] = (rgb >>> 8 & 0xFF) / 0xFF;
			vector[2] = (rgb & 0xFF) / 0xFF;
		}
		
		public function setRGBA(rgb:uint, alpha:Number):void
		{
			vector[0] = (rgb >>> 16 & 0xFF) / 0xFF;
			vector[1] = (rgb >>> 8 & 0xFF) / 0xFF;
			vector[2] = (rgb & 0xFF) / 0xFF;
			vector[3] = alpha;
		}
		
		public function dispose():void
		{
			id = null;
			type = null;
			matrix = null;
			vector = null;
			if (bytes) bytes.clear();
			bytes = null;
		}
		
		public function clone():AGALConstant 
		{
			var constant:AGALConstant = new AGALConstant();
			constant.type = type;
			constant.enabled = enabled;
			constant.id = id;
			constant.length = length;
			constant.transposed = transposed;
			constant.matrix = matrix? matrix.clone() : null;
			constant.vector = vector? vector.concat() : null;
			constant.bytes = bytes? ByteArrayUtil.clone(bytes) : null;
			return constant;
		}
		
	}

}