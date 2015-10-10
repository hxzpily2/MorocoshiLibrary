package net.morocoshi.moja3d.animation 
{
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
		private var blendTime:Number;
		private var _interpolationEnabled:Boolean;
		public var object:Object3D;
		public var motions:Object;
		public var timeScale:Number;
		
		public function MotionController() 
		{
			_interpolationEnabled = true;
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
			if (object == null)
			{
				throw new Error("MotionController.setObject()にnullを渡す事はできません！");
			}
			
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
		 * @param	motionID
		 * @param	data
		 */
		public function addMotion(motionID:String, data:MotionData):void
		{
			var motionData:MotionData = data.clone();
			motionData.id = motionID;
			motionData.setInterpolationEnabled(_interpolationEnabled);
			motions[motionID] = motionData;
			if (object)
			{
				motionData.setObject(object);
			}
		}
		
		/**
		 * モーションを再生
		 * @param	motionID	再生するモーションID
		 * @param	blendTime	モーションブレンドにかける時間（秒）
		 * @param	speedScale	モーションの速度の倍率
		 */
		public function play(motionID:String, blendTime:Number, speedScale:Number = 1):void 
		{
			var motion:MotionData = motions[motionID];
			if (motion == null)
			{
				stop();
				return;
			}
			
			if (current == null)
			{
				blendTime = 0;
			}
			
			this.blendTime = blendTime;
			timer.reset();
			
			current = motion;
			current.speedScale = speedScale;
			current.capture();
			current.reset();
			current.setBlendRatio(0);
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
				var ratio:Number = timer.time / 1000 / blendTime;
				if (ratio > 1) ratio = 1;
				current.setBlendRatio(ratio);
				current.setTime(diff * timeScale);
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
			for (var key:String in motions) 
			{
				var motion:MotionData = motions[key];
				motion.setInterpolationEnabled(_interpolationEnabled);
			}
		}
		
	}

}