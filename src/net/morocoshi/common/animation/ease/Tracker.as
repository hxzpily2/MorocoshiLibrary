package net.morocoshi.common.animation.ease 
{
	/**
	 * 数値を目的の値までイージングで近づける
	 * 
	 * @author tencho
	 */
	public class Tracker 
	{
		/**現在値*/
		public var current:Number = 0;
		/**目的値*/
		public var destination:Number = 0;
		/**イージング関数に使う累乗の数。1以上。1で等速運動になる。大きいほど重くなるので注意。*/
		public var easing:Number;
		/**1秒の間に変化する距離*/
		public var speed:Number;
		
		/**
		 * @param	easing	イージング関数に使う累乗の数。1以上。1で等速運動になる。大きいほど重くなるので注意。
		 * @param	speed	1秒の間に変化する距離
		 */
		public function Tracker(easing:Number, speed:Number) 
		{
			this.easing = easing;
			this.speed = speed;
		}
		
		/**
		 * 時間を進めて現在値を目的値に近づける
		 * @param	sec	進める秒数
		 */
		public function update(sec:Number):void
		{
			if (current == destination || speed == 0) return;
			
			var t:Number = ((current >= destination)? current - destination : destination - current) / speed;
			var g:Number = Math.pow(t, 1 / easing) - sec;
			
			if (g <= 0)
			{
				current = destination;
				return;
			}
			
			current = (current - destination) / t * Math.pow(g, easing) + destination;
		}
		
		/**
		 * 現在値が目的値と一致しているか
		 */
		public function get stopping():Boolean
		{
			return current == destination;
		}
		
	}

}