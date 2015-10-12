package net.morocoshi.moja3d.animation 
{
	import flash.events.EventDispatcher;
	import net.morocoshi.common.timers.Stopwatch;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * モーションを管理
	 * 
	 * @author tencho
	 */
	public class MotionController extends EventDispatcher
	{
		private var current:MotionData;
		private var _isPlaying:Boolean;
		private var _time:Number;
		private var _capturedTime:Number;
		private var timer:Stopwatch;
		private var blendTime:Number;
		private var _interpolationEnabled:Boolean;
		private var numLoop:int;
		private var firstTime:Boolean;
		public var object:Object3D;
		public var motions:Object;
		public var timeScale:Number;
		
		public function MotionController() 
		{
			_interpolationEnabled = true;
			firstTime = true;
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
		 * @param	motionID	登録名。再生時に使用するID。
		 * @param	data	モーションデータ
		 * @param	trimStart	モーションデータをトリミングする場合の開始時間（秒）
		 * @param	trimEnd	モーションデータをトリミングする場合の終了時間（秒）
		 */
		public function addMotion(motionID:String, data:MotionData, trimStart:Number = 0, trimEnd:Number = 0):void
		{
			var motionData:MotionData = data.clone();
			if (trimEnd != 0)
			{
				motionData.setStartTime(trimStart);
				motionData.setEndTime(trimEnd);
			}
			motionData.id = motionID;
			motionData.setInterpolationEnabled(_interpolationEnabled);
			motionData.loop = false;
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
		 * @param	numLoop		ループ回数。0で無限ループ
		 * @param	speedScale	モーションの速度の倍率
		 */
		public function play(motionID:String, blendTime:Number, numLoop:int = 0, speedScale:Number = 1):void 
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
			this.numLoop = numLoop;
			timer.reset();
			
			current = motion;
			current.capture();
			current.reset();
			current.setBlendRatio(0);
			
			timeScale = speedScale;
			firstTime = true;
			resume();
			setTime(_time);
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
		 * 時間（秒）を指定して描画する
		 * @param	time
		 */
		public function setTime(time:Number):void 
		{
			_time = time;
			var diff:Number = _time - _capturedTime;
			if (_isPlaying)
			{
				if (firstTime)
				{
					firstTime = false;
					_capturedTime = _time;
					diff = 0;
				}
				var ratio:Number = (blendTime == 0)? 1 : timer.time / 1000 / blendTime;
				if (ratio > 1) ratio = 1;
				current.setBlendRatio(ratio);
				var sec:Number = diff * timeScale;
				var motionlength:Number = (current.endTime - current.startTime);
				if (numLoop > 0 && sec / motionlength >= numLoop)
				{
					current.setTime(current.endTime);
					stop();
					dispatchEvent(new MotionEvent(MotionEvent.MOTION_COMPLETE));
				}
				else
				{
					//dispatchEvent(new MotionEvent(MotionEvent.MOTION_LOOP));
					sec %= motionlength;
					current.setTime(sec);
				}
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