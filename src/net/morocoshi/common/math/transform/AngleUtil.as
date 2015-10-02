package net.morocoshi.common.math.transform 
{
	/**
	 * 角度の処理
	 * 
	 * @author tencho
	 */
	public class AngleUtil 
	{
		static public const RADIAN30:Number = Math.PI / 6;
		static public const RADIAN45:Number = Math.PI * 0.25;
		static public const RADIAN90:Number = Math.PI * 0.5;
		static public const RADIAN180:Number = Math.PI;
		static public const RADIAN360:Number = Math.PI * 2;
		
		static public const TO_DEGREE:Number = 180 / Math.PI;
		static public const TO_RADIAN:Number = Math.PI / 180;
		
		/**
		* radianをtargetに最も近いラジアン角になるように360度単位でずらした角度を返す
		* @param	radian 変換したい元の角度値
		* @param	target この角度との距離が最も近い位置に変換する
		* @return
		*/
		static public function toNearRadian(radian:Number, target:Number):Number
		{
			var diff:Number = radian - target;
			diff = (diff % RADIAN360 + RADIAN360) % RADIAN360;
			if (diff > RADIAN180) diff -= RADIAN360;
			return diff + target;
		}
		
		/**
		 * 
		 * @param	degree
		 * @param	target
		 * @return
		 */
		static public function toNearDegree(degree:Number, target:Number):Number
		{
			var diff:Number = degree - target;
			diff = (diff % 360 + 360) % 360;
			if (diff > 180) diff -= 360;
			return diff + target;
		}
		
		/**
		 * 2つの近いほうの角度をDEGREE角で返す
		 * @param	d1
		 * @param	d2
		 * @return
		 */
		static public function getNearDegree(d1:Number, d2:Number):Number 
		{
			d1 = toNearDegree(d1, d2);
			var result:Number = d1 - d2;
			if (result < 0) result = -result;
			return result;
		}
		
	}

}