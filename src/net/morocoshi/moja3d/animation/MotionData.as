package net.morocoshi.moja3d.animation 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MotionData 
	{
		public var id:String;
		public var animation:Object;
		public var startTime:Number;
		public var endTime:Number;
		private var _loop:Boolean;
		
		public function MotionData() 
		{
			id = "";
			startTime = 0;
			endTime = 0;
			_loop = true;
			animation = { };
		}
		
		public function clear():void
		{
			var anm:KeyframeAnimation;
			if (animation)
			{
				for (var key:String in animation) 
				{
					anm = animation[key];
					anm.clear();
				}
			}
			anm = null;
			animation = null;
		}
		
		public function clone():MotionData 
		{
			var result:MotionData = new MotionData();
			result.id = id;
			result.startTime = startTime;
			result.endTime = endTime;
			for (var key:String in animation) 
			{
				result.animation[key] = animation[key].clone();
			}
			return result;
		}
		
		/**
		 * 親を含む全ての子オブジェクトをチェックし、アニメーションIDが一致するものをそれぞれのアニメーションデータに関連付ける。
		 * @param	object	チェックするルートオブジェクト。このオブジェクトが持つ全ての子をチェックする。
		 */
		public function linkObject(object:Object3D):void 
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				if (object.animationID == key)
				{
					anm.linkObject(object);
					continue;
				}
				var child:Object3D = object.getChildByAnimationID(key, true);
				if (child)
				{
					anm.linkObject(child);
				}
			}
		}
		
		public function unlinkObject(object:Object3D):void
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				if (object.animationID == key)
				{
					anm.unlinkObject(object);
					continue;
				}
				var child:Object3D = object.getChildByAnimationID(key, true);
				if (child)
				{
					anm.unlinkObject(child);
				}
			}
		}
		
		/**
		 * 全アニメーションの開始＆終了時間をチェックし、一番長いものをモーションの時間とする
		 */
		moja3d function checkTime():void
		{
			startTime = Number.MAX_VALUE;
			endTime = 0;
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				var startEnd:Array = anm.getStartEndTime();
				var start:Number = startEnd[0];
				var end:Number = startEnd[1];
				if (startTime > start) startTime = start;
				if (endTime < end) endTime = end;
			}
			if (startTime > endTime)
			{
				startTime = endTime;
			}
		}
		
		public function reset():void 
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.reset();
			}
		}
		
		/**
		 * 秒単位で全てのアニメーションの時間をシークする
		 * @param	time
		 */
		public function setTime(time:Number):void 
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.setTime(time);
			}
		}
		
		public function setBlendRatio(ratio:Number):void
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.blendRatio = ratio;
			}
		}
		
		public function capture():void 
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.capture();
			}
		}
		
		/**
		 * キーフレーム間の線形補完の有無を設定
		 * @param	enabled
		 */
		public function setInterpolationEnabled(enabled:Boolean):void 
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.setInterpolationEnabled(enabled);
			}
		}
		
		public function setStartTime(time:Number):void 
		{
			startTime = time;
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.setStartTime(time);
			}
		}
		
		public function setEndTime(time:Number):void 
		{
			endTime = time;
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.setEndTime(time);
			}
		}
		
		/**
		 * モーションの長さ（秒）。モーションの終了時間から開始時間を引いたものです。
		 */
		public function get timeLength():Number
		{
			return endTime - startTime;
		}
		
		public function get loop():Boolean 
		{
			return _loop;
		}
		
		public function set loop(value:Boolean):void 
		{
			_loop = value;
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.setLoop(value);
			}
		}
		
	}

}