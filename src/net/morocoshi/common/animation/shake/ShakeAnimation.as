package net.morocoshi.common.animation.shake 
{
	import net.morocoshi.common.math.random.MT;
	
	/**
	 * WaggleAnimationを合成して複雑な振動に対応
	 * 
	 * @author tencho
	 */
	public class ShakeAnimation 
	{
		private var _increase:Number;
		private var animationList:Vector.<WaggleAnimation>;
		private var scaleStep:Number;
		
		public function ShakeAnimation() 
		{
			animationList = new Vector.<WaggleAnimation>;
		}
		
		/**
		 * 
		 * @param	startSeed	開始乱数シード値。
		 * @param	numCycle	一連のカーブがループするまでの波の数。これの数だけ乱数計算が必要になる。
		 * @param	layers		カーブを合成する数。多いほど複雑な振動になる。
		 * @param	increase	波の振幅が1に近づくほど最大振幅値に収束していく[0～1]
		 */
		public function init(seed:int, numCycle:int, layers:int, increase:Number):void
		{
			animationList.length = 0;
			var mt:MT = new MT();
			mt.initialize(seed);
			scaleStep = 1 + 1 / layers;
			for (var i:int = 0; i < layers; i++) 
			{
				var id:uint = mt.randomUint();
				var animation:WaggleAnimation = new WaggleAnimation(id, numCycle + i);
				animationList.push(animation);
			}
			this.increase = increase;
		}
		
		public function getValue(time:Number):Number
		{
			var value:Number = 0;
			var n:int = animationList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var animation:WaggleAnimation = animationList[i];
				value += animation.getValue(time * scaleStep * (i + 1));
			}
			value /= n;
			return value;
		}
		
		public function get increase():Number 
		{
			return _increase;
		}
		
		public function set increase(value:Number):void 
		{
			_increase = value;
			var n:int = animationList.length;
			for (var i:int = 0; i < n; i++) 
			{
				animationList[i].increase = _increase;
			}
		}
		
	}

}