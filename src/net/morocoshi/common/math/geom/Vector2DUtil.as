package net.morocoshi.common.math.geom
{
	import flash.geom.Point;
	
	/**
	 * 2Dベクトル操作
	 * 
	 * @author	tencho
	 */
	public class Vector2DUtil
	{
		/**
		 * 2つのベクトルの内積をPointで求める
		 * ・標準化ベクトルにもう片方のベクトルを正射影した時の長さ
		 * ・1に近いほど同方向に平行
		 * ・-1に近いほど逆向き平行
		 * ・0に近いほど直角
		 */
		static public function dot(a:Point, b:Point):Number
		{
			return a.x * b.x + a.y * b.y;
		}
		
		/**
		 * 2つのベクトルの外積をPointで求める
		 * 結果の符号でベクトルAに対してベクトルBが左右どちらにあるか判定できる
		 * 結果が0なら2つのベクトルは平行
		 */
		static public function cross(a:Point, b:Point):Number
		{
			return a.x * b.y - a.y * b.x;
		}
		
		/**
		 * 2つのベクトルの角度をXYで求める
		 */
		static public function getAngleXY(ax:Number, ay:Number, bx:Number, by:Number):Number
		{
			var cos:Number = (ax * bx + ay * by) / (Math.sqrt(ax * ax + ay * ay) * Math.sqrt(bx * bx + by * by));
			return Math.acos(cos > 1? 1 : (cos < -1? -1 : cos));
		}
		
		/**
		 * 2つのベクトルの内積をXYで求める
		 * ・標準化ベクトルにもう片方のベクトルを正射影した時の長さ
		 * ・1に近いほど同方向に平行
		 * ・-1に近いほど逆向き平行
		 * ・0に近いほど直角
		 */
		static public function dotXY(ax:Number, ay:Number, bx:Number, by:Number):Number
		{
			return ax * bx + ay * by;
		}
		
		/**
		 * 2つのベクトルの外積をXYで求める
		 * 結果の符号でベクトルAに対してベクトルBが左右どちらにあるか判定できる
		 * 結果が0なら2つのベクトルは平行
		 */
		static public function crossXY(ax:Number, ay:Number, bx:Number, by:Number):Number
		{
			return ax * by - ay * bx;
		}
		
	}

}