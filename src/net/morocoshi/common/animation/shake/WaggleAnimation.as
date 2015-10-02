package net.morocoshi.common.animation.shake 
{
	import net.morocoshi.common.math.random.MT;
	
	/**
	 * カメラシェイク用の揺れのアニメーションカーブ
	 * 
	 * @author tencho
	 */
	public class WaggleAnimation 
	{
		/**波の振幅が1に近づくほど最大振幅値に収束していく[0～1]初期値=0*/
		public var increase:Number;
		/**乱数生成器*/
		private var mt:MT;
		/**事前に計算しておくカーブのキーフレーム情報*/
		private var curveKey:Vector.<Number>;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		/**
		 * 
		 * @param	seed	乱数生成用のシード値。
		 * @param	numCycle	一連のカーブがループするまでの波の数。これの数だけ乱数計算が必要になる。
		 */
		public function WaggleAnimation(seed:uint, numCycle:int) 
		{
			curveKey = new Vector.<Number>;
			init(seed, numCycle);
		}
		
		//--------------------------------------------------------------------------
		//
		//  初期化
		//
		//--------------------------------------------------------------------------
		
		public function init(seed:uint, numCycle:int):void
		{
			//事前にカーブを形成する為のキーフレームを生成しておく
			curveKey.length = 0;
			mt = new MT();
			mt.initialize(seed);
			var m:int = 1;
			for (var i:int = 0; i < numCycle; i++) 
			{
				curveKey.push(mt.random() * m);
				m *= -1;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  データの取得
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 時間指定で揺れ値(-1～1)を取得。時間は0以上で整数位置がキーフレームの位置。2つのキーの間はコサインカーブで補完される。
		 * @param	time
		 * @return
		 */
		public function getValue(time:Number):Number
		{
			var length:int = curveKey.length;
			var t:int = int(time);
			var index0:int = t % length;
			var index1:int = (t + 1) % length;
			var diff:Number = time - t;
			var rate:Number = 1 - (Math.cos(diff * Math.PI) * 0.5 + 0.5);
			
			var v0:Number;
			var v1:Number;
			if (increase == 0)
			{
				v0 = curveKey[index0];
				v1 = curveKey[index1];
			}
			else
			{
				v0 = (curveKey[index0] > 0)? 1 : -1;
				v1 = (curveKey[index1] > 0)? 1 : -1;
				if (increase != 1)
				{
					v0 = v0 * increase + curveKey[index0] * (1 - increase);
					v1 = v1 * increase + curveKey[index1] * (1 - increase);
				}
			}
			var value:Number = v0 + (v1 - v0) * rate;
			return value;
		}
		
	}

}