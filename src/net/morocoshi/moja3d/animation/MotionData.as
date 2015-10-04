package net.morocoshi.moja3d.animation 
{
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
		public var speedScale:Number;
		
		public function MotionData() 
		{
			id = "";
			speedScale = 1;
			animation = { };
		}
		
		public function clone():MotionData 
		{
			var result:MotionData = new MotionData();
			result.id = id;
			result.speedScale = speedScale;
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
		public function setObject(object:Object3D):void 
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				if (object.animationID == key)
				{
					anm.setObject(object);
					continue;
				}
				var child:Object3D = object.getChildByAnimationID(key, true);
				if (child)
				{
					anm.setObject(child);
				}
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
				anm.setTime(time * speedScale);
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
		
	}

}