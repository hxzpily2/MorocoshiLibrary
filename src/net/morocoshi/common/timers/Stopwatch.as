package net.morocoshi.common.timers 
{
	import flash.utils.getTimer;
	
	/**
	 * 時間をミリ秒で計測する
	 * 
	 * @author tencho
	 */
	public class Stopwatch 
	{
		private var _time:int = 0;
		private var _lastTime:int;
		private var _isPlaying:Boolean = false;
		
		/**
		 * コンストラクタ
		 */
		public function Stopwatch() 
		{
		}
		
		/**
		 * 時間を0にする
		 */
		public function reset():void
		{
			_time = 0;
			_lastTime = getTimer();
		}
		
		/**
		 * 計測開始
		 */
		public function start():void
		{
			if (_isPlaying) return;
			_lastTime = getTimer();
			_isPlaying = true;
		}
		
		/**
		 * 一時停止
		 */
		public function stop():void
		{
			if (!_isPlaying) return;
			checkTime();
			_isPlaying = false;
		}
		
		private function checkTime():void 
		{
			if (_isPlaying) _time += getTimer() - _lastTime;
		}
		
		/**
		 * 現在時間（ミリ秒）
		 */
		public function get time():int
		{
			var t:int = _isPlaying? _time + getTimer() - _lastTime : _time;
			return t;
		}
		
		/**
		 * 再生中か
		 */
		public function get isPlaying():Boolean { return _isPlaying; }
		public function set isPlaying(value:Boolean):void
		{
			if (value) start();
			else stop();
		}
		
	}

}