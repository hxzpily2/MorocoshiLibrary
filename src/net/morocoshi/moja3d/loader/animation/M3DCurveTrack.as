package net.morocoshi.moja3d.loader.animation 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DCurveTrack 
	{
		public var keyList:Vector.<M3DKeyframe>;
		public var loop:Boolean;
		public var startTime:Number;
		public var endTime:Number;
		
		public function M3DCurveTrack() 
		{
		}
		
		public function clear():void
		{
			keyList = null;
		}
		
	}

}