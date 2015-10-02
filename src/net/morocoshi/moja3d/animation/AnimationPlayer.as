package net.morocoshi.moja3d.animation 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class AnimationPlayer 
	{
		public var keyAnimations:Vector.<KeyframeAnimation>;
		
		public function AnimationPlayer() 
		{
			keyAnimations = new Vector.<KeyframeAnimation>;
		}
		
		public function setTime(time:Number):void
		{
			var n:int = keyAnimations.length;
			for (var i:int = 0; i < n; i++) 
			{
				keyAnimations[i].setTime(time);
			}
		}
		
		public function setForceTangent(tangent:int):void
		{
			var n:int = keyAnimations.length;
			for (var i:int = 0; i < n; i++) 
			{
				keyAnimations[i].setForceTangent(tangent);
			}
		}
		
	}

}