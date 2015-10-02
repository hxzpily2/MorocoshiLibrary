package net.morocoshi.moja3d.animation 
{
	import net.morocoshi.moja3d.objects.Object3D;
	/**
	 * ...
	 * @author tencho
	 */
	public class MotionData 
	{
		public var name:String;
		public var animation:Object;
		public var timeScale:Number;
		public function MotionData() 
		{
			name = "";
			timeScale = 1;
			animation = { };
		}
		
		public function clone():MotionData 
		{
			var result:MotionData = new MotionData();
			result.name = name;
			result.timeScale = timeScale;
			for (var key:String in animation) 
			{
				result.animation[key] = animation[key].clone();
			}
			return result;
		}
		
		/**
		 * 親を含む全ての子オブジェクトをチェックし、名前が一致するものをそれぞれのアニメーションデータに関連付ける。
		 * @param	object	チェックするルートオブジェクト。このオブジェクトが持つ全ての子をチェックする。
		 */
		public function setObject(object:Object3D):void 
		{
			for (var key:String in animation) 
			{
				var child:Object3D = object.getChildByAnimationID(key, true);
				if (child)
				{
					var anm:KeyframeAnimation = animation[key];
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
				anm.setTime(time * timeScale);
			}
		}
		
		public function setFadeRatio(ratio:Number):void
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.fadeRatio = ratio;
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
		
		public function setForceTangent(tangent:int):void 
		{
			for (var key:String in animation) 
			{
				var anm:KeyframeAnimation = animation[key];
				anm.setForceTangent(tangent);
			}
		}
		
	}

}