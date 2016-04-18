package net.morocoshi.moja3d.animation 
{
	import flash.events.EventDispatcher;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.timers.Stopwatch;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * モーションを管理
	 * 
	 * @author tencho
	 */
	public class MotionController extends EventDispatcher
	{
		public var objectList:Vector.<Object3D>;
		public var motions:Object;
		
		//ブレンドモード用タイマー
		private var blendTimer:Stopwatch;
		//モーション再生位置用タイマー
		private var motionTimer:Stopwatch;
		//再生中のモーションの速度
		private var currentMotionSpeed:Number;
		//ブレンドにかける時間（秒）
		private var blendTime:Number;
		//再生回数
		private var numLoop:int;
		
		private var _current:MotionData;
		private var _interpolationEnabled:Boolean;
		private var _isPlaying:Boolean;
		private var _timeScale:Number;
		private var updateOrder:Boolean;
		private var lastMotionTime:Number;
		private var lastBlend:Number;
		
		public function MotionController() 
		{
			motions = { };
			objectList = new Vector.<Object3D>;
			blendTimer = new Stopwatch();
			motionTimer = new Stopwatch();
			
			lastMotionTime = -1;
			lastBlend = -1;
			_interpolationEnabled = true;
			_isPlaying = false;
			updateOrder = false;
			_timeScale = 1;
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
			
			//既に登録済みのオブジェクトだったら処理を進めない
			if (VectorUtil.attachItemDiff(objectList, object) == false) return;
			
			for (var key:String in motions) 
			{
				var motion:MotionData = motions[key];
				motion.linkObject(object);
			}
		}
		
		public function removeObject(object:Object3D):void
		{
			if (object == null)
			{
				throw new Error("MotionController.removeObject()にnullを渡す事はできません！");
			}
			
			VectorUtil.deleteItem(objectList, object);
			
			for (var key:String in motions) 
			{
				var motion:MotionData = motions[key];
				motion.unlinkObject(object);
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
			if (trimEnd == 0 || trimEnd > motionData.endTime) trimEnd = motionData.endTime;
			if (trimStart < 0) trimStart = 0;
			if (trimStart != 0 || trimEnd != motionData.endTime)
			{
				motionData.setStartTime(trimStart);
				motionData.setEndTime(trimEnd);
			}
			motionData.id = motionID;
			motionData.setInterpolationEnabled(_interpolationEnabled);
			motionData.loop = false;
			motions[motionID] = motionData;
			
			for each (var object:Object3D in objectList) 
			{
				motionData.linkObject(object);
			}
		}
		
		/**
		 * モーションの無いオブジェクトのデフォルト姿勢をチェックする
		 */
		public function fixMotionlessNodes():void 
		{
			var exists:Object = { };
			var motionKey:String;
			var animationKey:String;
			var motion:MotionData;
			for (motionKey in motions) 
			{
				motion = motions[motionKey];
				for (animationKey in motion.animation) 
				{
					exists[animationKey] = KeyframeAnimation(motion.animation[animationKey]).targetList;
				}
			}
			for (motionKey in motions) 
			{
				motion = motions[motionKey];
				for (animationKey in exists)
				{
					if (motion.animation[animationKey] || exists[animationKey] == null) continue;
					var animation:KeyframeAnimation = new KeyframeAnimation(KeyframeAnimation.TYPE_MOTIONLESS_MATRIX);
					animation.linkObject(exists[animationKey]);
					motion.animation[animationKey] = animation;
				}
			}
		}
		
		/**
		 * モーションを変更する
		 * @param	motionID	変更するモーションのID
		 * @param	blendTime	モーションブレンドにかける時間（秒）
		 * @param	loop		再生回数。0で無限ループ
		 * @param	speedScale	モーションの速度の倍率
		 */
		public function changeMotion(motionID:String, blendTime:Number, loop:int = 0, speedScale:Number = 1):void 
		{
			var motion:MotionData = motions[motionID];
			if (motion == null)
			{
				return;
			}
			
			if (_current == null)
			{
				blendTime = 0;
			}
			
			this.blendTime = blendTime;
			this.numLoop = loop;
			
			motionTimer.reset();
			blendTimer.reset();
			blendTimer.start();
			
			_current = motion;
			_current.capture();
			_current.reset();
			_current.setBlendRatio(0);
			
			currentMotionSpeed = speedScale;
			motionTimer.speed = currentMotionSpeed * _timeScale;
			
			updateOrder = true;
			update();
		}
		
		/**
		 * モーションを再生
		 */
		public function play():void
		{
			motionTimer.start();
		}
		
		/**
		 * モーションを一時停止
		 */
		public function stop():void
		{
			motionTimer.stop();
		}
		
		/**
		 * モーション位置をフレーム（1～）で指定
		 * @param	frame
		 * @param	frameRate
		 */
		public function setFrame(frame:Number, frameRate:Number = 30):void
		{
			motionTimer.time = 1000 / frameRate * (frame - 1);
		}
		
		/**
		 * モーション位置をフレーム（1～）で取得
		 * @param	frameRate
		 * @return
		 */
		public function getFrame(frameRate:Number = 30):Number
		{
			if (current == null) return 1;
			
			var length:Number = current.timeLength;
			return ((motionTimer.time / 1000) % length * frameRate) + 1;
		}
		
		/**
		 * モーション位置を秒で指定。play()してupdate()で更新する場合はこれは必要ない。
		 * @param	time
		 */
		public function setTime(time:Number):void
		{
			motionTimer.time = time * 1000;
		}
		
		/**
		 * モーション位置を秒で取得
		 * @return
		 */
		public function getTime():Number
		{
			if (current == null) return 0;
			
			var length:Number = current.timeLength;
			return (motionTimer.time / 1000) % length;
		}
		
		/**
		 * 現在再生中のモーションを描画に反映する。これで更新する場合はsetTime()を呼び出す必要はない。
		 */
		public function update():void 
		{
			var blend:Number = (blendTime == 0)? 1 : blendTimer.time / 1000 / blendTime;
			if (blend > 1) blend = 1;
			_current.setBlendRatio(blend);
			
			if (updateOrder || lastMotionTime != motionTimer.time || lastBlend != blend)
			{
				updateOrder = false;
				lastMotionTime = motionTimer.time;
				lastBlend = blend;
				
				var sec:Number = motionTimer.time / 1000;
				if (numLoop > 0 && sec / _current.timeLength >= numLoop)
				{
					_current.setTime(_current.endTime);
					stop();
					dispatchEvent(new MotionEvent(MotionEvent.MOTION_COMPLETE));
				}
				else
				{
					//dispatchEvent(new MotionEvent(MotionEvent.MOTION_LOOP));
					sec %= _current.timeLength;
					_current.setTime(_current.startTime + sec);
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
		
		/**
		 * モーション再生やブレンド処理などこのクラス内で扱う全ての処理に影響する時間のスケール
		 */
		public function get timeScale():Number 
		{
			return _timeScale;
		}
		
		public function set timeScale(value:Number):void 
		{
			_timeScale = value;
			blendTimer.speed = _timeScale;
			motionTimer.speed = currentMotionSpeed * _timeScale;
		}
		
		/**
		 * 現在再生中のモーションデータ
		 */
		public function get current():MotionData 
		{
			return _current;
		}
		
	}

}