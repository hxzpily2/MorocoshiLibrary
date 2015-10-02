package net.morocoshi.common.math.random
{
	public class MT
	{
		private const N:uint = 624;
		private const M:uint = 397;
		private const Q:uint = 35173;
		private const F:uint = 0xffff;
		private var x:uint;
		private var y:uint;
		private var z:uint;
		private var tw:Vector.<uint> = new Vector.<uint>(N, true);
		private var _seed:uint;
		
		static private var _instance:MT = new MT();
		
		/**
		 * MersenneTwister
		 * 
		 * @see http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/SFMT/index-jp.html
		 */
		public function MT()
		{
		}
		
		
		/**
		 * シード値（0～）で初期化する
		 */
		public function initialize(seed:uint):void
		{
			var i:int, n:Number, k:Number, g:Number, t:Number;
			tw[0] = _seed = seed;
			for (i = 1; i < N; i++)
			{
				g = Q * (k = (n = tw[i - 1] ^ (tw[i - 1] >>> 30)) & F);
				t = ((((g >>> 16) + Q * (n >>> 16)) & F) + 27655 * k) & F;
				tw[i] = ((t << 16) | (g & F)) + i & 0xffffffff;
			}
			x = 0, y = 1, z = M;
		}
		
		/**
		 * 現在のシード値
		 */
		public function get seed():uint
		{
			return _seed;
		}
		
		static public function get instance():MT 
		{
			return _instance;
		}
		
		/**
		 * ランダムに0～0.999999・・・・の値を生成
		 * @return
		 */
		public function random():Number
		{
			var r:uint = (tw[x] & 0x80000000) | (tw[y] & 0x7fffffff);
			r = tw[x] = tw[z] ^ (r >>> 1) ^ ((r & 1) * 0x9908b0df);
			if (++x == N) x = 0;
			if (++y == N) y = 0;
			if (++z == N) z = 0;
			r ^= (r >>> 11);
			r ^= (r << 7) & 0x9d2c5680;
			r ^= (r << 15) & 0xefc60000;
			r ^= (r >>> 18);
			return r / 4294967296;//=uint.MAX_VALUE+1
		}
		
		/**
		 * ランダムに0～4294967295(uint.MAX_VALUE)の値を生成
		 * @return
		 */
		public function randomUint():uint
		{
			var r:uint = (tw[x] & 0x80000000) | (tw[y] & 0x7fffffff);
			r = tw[x] = tw[z] ^ (r >>> 1) ^ ((r & 1) * 0x9908b0df);
			if (++x == N) x = 0;
			if (++y == N) y = 0;
			if (++z == N) z = 0;
			r ^= (r >>> 11);
			r ^= (r << 7) & 0x9d2c5680;
			r ^= (r << 15) & 0xefc60000;
			r ^= (r >>> 18);
			return r;
		}
		
	}
	
}
