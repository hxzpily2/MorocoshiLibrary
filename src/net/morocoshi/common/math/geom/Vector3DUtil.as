package net.morocoshi.common.math.geom
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 * Vector3D系処理
	 * 
	 * @author tencho
	 */
	public class Vector3DUtil
	{
		static public const toRAD:Number = Math.PI / 180;
		
		/**
		* 2つのベクトルの内積を返します。
		* (内積：2つのベクトルがどれだけ平行に近いかを示す数値)
		* ・ 1 に近いほど同じ向きで平行
		* ・ 0 に近いほど直角
		* ・-1 に近いほど逆向きで平行
		*/
		static public function dot(a:Vector3D, b:Vector3D):Number
		{
			return (a.x * b.x) + (a.y * b.y) + (a.z * b.z);
		}
		
		/**
		* 2つのベクトルの外積を返します。
		* (外積：2つのベクトルで作られる面に垂直なベクトル(=法線)。)
		*/
		static public function cross(a:Vector3D, b:Vector3D):Vector3D
		{
			return new Vector3D((a.y * b.z) - (a.z * b.y), (a.z * b.x) - (a.x * b.z), (a.x * b.y) - (a.y * b.x));
		}
		
		/**
		 * ベクトルのxyzを設定する
		 * @param	v
		 * @param	x
		 * @param	y
		 * @param	z
		 */
		static public function setXYZ(v:Vector3D, x:Number, y:Number, z:Number):void
		{
			v.x = x;
			v.y = y;
			v.z = z;
		}
		
		/**
		 * fromのxyzwをtoへコピーする
		 * @param	from
		 * @param	to
		 */
		static public function copy(from:Vector3D, to:Vector3D):void
		{
			to.x = from.x;
			to.y = from.y;
			to.z = from.z;
			to.w = from.w;
		}
		
		/**
		 * 2つのベクトルの角度をラジアン角で返す。
		 * Vector3D.angleBetween()がNaNを返す時があるのでそれの修正版。
		 * @param	a
		 * @param	b
		 * @return
		 */
		static public function getAngle(a:Vector3D, b:Vector3D):Number
		{
			var dot:Number = (a.x * b.x + a.y * b.y + a.z * b.z) / (a.length * b.length);
			if (dot > 1) dot = 1;
			else if (dot < -1) dot = -1;
			return Math.acos(dot);
		}
		
		/**
		 * 2つの「単位」ベクトルの角度をラジアン角で返す。（getAngleより少し速い）
		 * @param	a
		 * @param	b
		 * @return
		 */
		static public function getAngleUnit(a:Vector3D, b:Vector3D):Number
		{
			var dot:Number = (a.x * b.x + a.y * b.y + a.z * b.z);
			if (dot > 1) dot = 1;
			else if (dot < -1) dot = -1;
			return Math.acos(dot);
		}
		
		/**
		 * 指定の長さにした新しいベクトルを取得
		 * @param	v
		 * @param	length
		 * @return
		 */
		static public function getResized(v:Vector3D, length:Number):Vector3D
		{
			var sv:Vector3D = v.clone();
			sv.normalize();
			sv.scaleBy(length);
			return sv;
		}
		
		/**
		 * スケーリングした新しいベクトルを取得
		 * @param	v
		 * @param	scale
		 * @return
		 */
		static public function getScaled(v:Vector3D, scale:Number):Vector3D
		{
			var sv:Vector3D = v.clone();
			sv.scaleBy(scale);
			return sv;
		}
		
		/**
		 * 球面座標を取得
		 * @param	rotation	横方向角度
		 * @param	angle	縦方向角度
		 * @param	radius	半径
		 * @return
		 */
		static public function getGlobePoint(rotation:Number, angle:Number, radius:Number):Vector3D
		{
			var cos:Number = Math.cos(angle * toRAD);
			var px:Number = Math.cos(rotation * toRAD) * radius * cos;
			var py:Number = Math.sin(angle * toRAD) * radius;
			var pz:Number = Math.sin(rotation * toRAD) * radius * cos;
			return new Vector3D(px, py, pz);
		}
		
		static public function mix(a:Vector3D, b:Vector3D, per:Number):Vector3D
		{
			var per2:Number = 1 - per;
			var v:Vector3D = new Vector3D();
			v.x = a.x * per2 + b.x * per;
			v.y = a.y * per2 + b.y * per;
			v.z = a.z * per2 + b.z * per;
			return v;
		}
		
		/**
		 * ベクトルaとベクトルbを足した結果をベクトルvに設定する
		 * @param	v
		 * @param	a
		 * @param	b
		 */
		static public function add(v:Vector3D, a:Vector3D, b:Vector3D):void 
		{
			v.x = a.x + b.x;
			v.y = a.y + b.y;
			v.z = a.z + b.z;
		}
		
	}

}