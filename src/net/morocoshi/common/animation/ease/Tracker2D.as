package net.morocoshi.common.animation.ease 
{
	/**
	 * 2D座標を目的の座標までイージングで近づける
	 * 
	 * @author tencho
	 */
	public class Tracker2D 
	{
		private var tx:Tracker;
		private var ty:Tracker;
		
		/**1秒の間に変化する距離*/
		public var speed:Number;
		
		/**
		 * @param	easing	イージング関数に使う累乗の数。1以上。1で等速運動になる。大きいほど重くなるので注意。
		 * @param	speed	1秒の間に変化する距離
		 */
		public function Tracker2D(easing:Number, speed:Number) 
		{
			this.speed = speed;
			tx = new Tracker(easing, speed);
			ty = new Tracker(easing, speed);
		}
		
		/**
		 * 時間を進めて現在座標を目的座標に近づける
		 * @param	sec	進める秒数
		 */
		public function update(sec:Number):void
		{
			tx.speed = speed;
			ty.speed = speed;
			var dx:Number = (tx.destination >= tx.current)? tx.destination - tx.current : tx.current - tx.destination;
			var dy:Number = (ty.destination >= ty.current)? ty.destination - ty.current : ty.current - ty.destination;
			var d:Number = 1 / Math.sqrt(dx * dx + dy * dy);
			if (d)
			{
				tx.speed *= dx * d;
				ty.speed *= dy * d;
			}
			tx.update(sec);
			ty.update(sec);
		}
		
		/**
		 * 現在座標を設定する
		 * @param	x
		 * @param	y
		 */
		public function setCurrent(x:Number, y:Number):void 
		{
			tx.current = x;
			tx.current = y;
		}
		
		/**
		 * 目的座標を設定する
		 * @param	x
		 * @param	y
		 */
		public function setDestination(x:Number, y:Number):void 
		{
			tx.destination = x;
			ty.destination = y;
		}
		
		/**
		 * 現在座標が目的座標と一致しているか
		 */
		public function get stopping():Boolean
		{
			return tx.stopping && ty.stopping;
		}
		
		/**
		 * イージング関数に使う累乗の数。1以上。1で等速運動になる。大きいほど重くなるので注意。
		 */
		public function get easing():Number
		{
			return tx.easing;
		}
		
		public function set easing(value:Number):void
		{
			tx.easing = ty.easing = value;
		}
		
		public function get x():Number
		{
			return tx.current;
		}
		
		public function set x(value:Number):void
		{
			tx.current = value;
		}
		
		public function get y():Number
		{
			return ty.current;
		}
		
		public function set y(value:Number):void
		{
			ty.current = value;
		}
		
		public function get dx():Number
		{
			return tx.destination;
		}
		
		public function set dx(value:Number):void
		{
			tx.destination = value;
		}
		
		public function get dy():Number
		{
			return ty.destination;
		}
		
		public function set dy(value:Number):void
		{
			ty.destination = value;
		}
		
	}

}