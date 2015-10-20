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
		private var _time:Number = 0;
		private var _lastTime:Number;
		private var _isPlaying:Boolean = false;
		private var _speed:Number = 1;
		
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
			_time += (getTimer() - _lastTime) * _speed;
			_lastTime = getTimer();
			_isPlaying = false;
		}
		
		/**
		 * 現在時間（ミリ秒）
		 */
		public function get time():Number
		{
			var t:int = _isPlaying? _time + (getTimer() - _lastTime) * _speed : _time;
			return t;
		}
		public function set time(value:Number):void
		{
			_time = value;
			_lastTime = getTimer();
		}
		
		/**
		 * 再生中か
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		public function set isPlaying(value:Boolean):void
		{
			if (value) start();
			else stop();
		}
		
		public function get speed():Number 
		{
			return _speed;
		}
		
		public function set speed(value:Number):void 
		{
			if (_speed == value) return;
			
			if (_isPlaying)
			{
				_time += (getTimer() - _lastTime) * _speed;
				_lastTime = getTimer();
			}
			_speed = value;
		}
		
	}

}