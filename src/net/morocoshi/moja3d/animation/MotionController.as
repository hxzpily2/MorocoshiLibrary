package net.morocoshi.moja3d.animation 
{
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import net.morocoshi.common.timers.Stopwatch;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * モーションを管理
	 * 
	 * @author tencho
	 */
	public class MotionController 
	{
		private var current:MotionData;
		private var _isPlaying:Boolean;
		private var _time:Number;
		private var _capturedTime:Number;
		private var timer:Stopwatch;
		private var fade:Number;
		public var object:Object3D;
		public var motions:Object;
		public var timeScale:Number;
		
		public function MotionController() 
		{
			_isPlaying = false;
			_time = 0;
			timeScale = 1;
			motions = { };
			timer = new Stopwatch();
		}
		
		/**
		 * モーションを割り当てるオブジェクトを設定する
		 * @param	object
		 */
		public function setObject(object:Object3D):void
		{
			this.object = object;
			for (var key:String in motions) 
			{
				var motion:MotionData = motions[key];
				motion.setObject(object);
			}
		}
		
		/**
		 * モーションを削除する
		 * @param	name
		 */
		public function removeMotion(name:String):void
		{
			delete motions[name];
		}
		
		/**
		 * モーションを追加する。追加する際に内部でcloneされる。
		 * @param	name
		 * @param	motion
		 */
		public function addMotion(name:String, motion:MotionData):void
		{
			var cloned:MotionData = motion.clone();
			cloned.name = name;
			motions[name] = cloned;
			if (object)
			{
				cloned.setObject(object);
			}
		}
		
		/**
		 * モーションを再生
		 * @param	name
		 */
		public function play(name:String, fade:Number, scale:Number = 1):void 
		{
			var motion:MotionData = motions[name];
			if (motion == null)
			{
				stop();
				return;
			}
			
			this.fade = fade;
			timer.reset();
			current = motion;
			current.timeScale = scale;
			current.capture();
			current.reset();
			current.setFadeRatio(0);
			setTime(_time);
			_capturedTime = _time;
			_time = 0;
			resume();
		}
		
		/**
		 * 一時停止を再開
		 */
		public function resume():void
		{
			_isPlaying = true;
			timer.start();
		}
		
		/**
		 * モーションの一時停止
		 */
		public function stop():void
		{
			_isPlaying = false;
			timer.stop();
		}
		
		/**
		 * 時間を指定して描画する
		 * @param	time
		 */
		public function setTime(time:Number):void 
		{
			_time = time;
			var diff:Number = _time - _capturedTime;
			if (_isPlaying)
			{
				var ratio:Number = timer.time / 1000 / fade;
				if (ratio > 1) ratio = 1;
				current.setFadeRatio(ratio);
				current.setTime(diff * timeScale);
			}
		}
		
		public function setForceTangent(tangent:int):void 
		{
			for (var key:String in motions) 
			{
				var motion:MotionData = motions[key];
				motion.setForceTangent(tangent);
			}
		}
		
	}

}