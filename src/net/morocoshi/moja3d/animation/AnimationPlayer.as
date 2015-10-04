package net.morocoshi.moja3d.animation 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class AnimationPlayer 
	{
		public var keyAnimations:Vector.<KeyframeAnimation>;
		private var _interpolationEnabled:Boolean;
		
		public function AnimationPlayer() 
		{
			keyAnimations = new Vector.<KeyframeAnimation>;
			_interpolationEnabled = true;
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
		
	}

}