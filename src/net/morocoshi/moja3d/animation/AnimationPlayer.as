package net.morocoshi.moja3d.animation 
{
	import net.morocoshi.moja3d.moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AnimationPlayer 
	{
		public var keyAnimations:Vector.<KeyframeAnimation>;
		private var _loop:Boolean;
		private var _interpolationEnabled:Boolean;
		private var _timeLength:Number;
		public var _startTime:Number;
		public var _endTime:Number;
		
		public function AnimationPlayer() 
		{
			_startTime = 0;
			_endTime = 0;
			_timeLength = 0;
			_loop = true;
			keyAnimations = new Vector.<KeyframeAnimation>;
			_interpolationEnabled = true;
		}
		
		public function clear():void
		{
			var animation:KeyframeAnimation;
			if (keyAnimations)
			{
				for each(animation in keyAnimations)
				{
					animation.clear();
				}
			}
			animation = null;
			keyAnimations = null;
		}
		
		public function setTime(time:Number):void
		{
			var n:int = keyAnimations.length;
			for (var i:int = 0; i < n; i++) 
			{
				keyAnimations[i].setTime(time);
			}
		}
		
		/**
		 * キーフレーム間を線形補完するかどうか
		 * @param	enabled
		 */
		public function get interpolationEnabled():Boolean 
		{
			return _interpolationEnabled;
		}
		
		public function set interpolationEnabled(value:Boolean):void 
		{
			_interpolationEnabled = value;
			var n:int = keyAnimations.length;
			for (var i:int = 0; i < n; i++) 
			{
				keyAnimations[i].setInterpolationEnabled(_interpolationEnabled);
			}
		}
		
		/**
		 * 全アニメーションの開始＆終了時間をチェックし、一番長いものをモーションの時間とする
		 */
		moja3d function checkTime():void
		{
			var min:Number = Number.MAX_VALUE;
			var max:Number = 0;
			for each(var anm:KeyframeAnimation in keyAnimations) 
			{
				var startEnd:Array = anm.getStartEndTime();
				var start:Number = startEnd[0];
				var end:Number = startEnd[1];
				if (min > start) min = start;
				if (max < end) max = end;
			}
			if (min > max)
			{
				min = max;
			}
			startTime = min;
			endTime = max;
		}
		
		public function get loop():Boolean 
		{
			return _loop;
		}
		
		public function set loop(value:Boolean):void 
		{
			_loop = value;
			var n:int = keyAnimations.length;
			for (var i:int = 0; i < n; i++) 
			{
				keyAnimations[i].setLoop(value);
			}
		}
		
		private function updateTimeLength():void 
		{
			_timeLength = _endTime - _startTime;
		}
		
		public function get startTime():Number 
		{
			return _startTime;
		}
		
		public function set startTime(value:Number):void 
		{
			_startTime = value;
			updateTimeLength();
		}
		
		public function get endTime():Number 
		{
			return _endTime;
		}
		
		public function set endTime(value:Number):void 
		{
			_endTime = value;
			updateTimeLength();
		}
		
		public function get timeLength():Number 
		{
			return _timeLength;
		}
		
	}

}