package net.morocoshi.moja3d.animation 
{
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AnimationCurveNode 
	{
		public var x:AnimationCurveTrack;
		public var y:AnimationCurveTrack;
		public var z:AnimationCurveTrack;
		public var defaultValue:Vector3D;
		
		public function AnimationCurveNode() 
		{
			defaultValue = new Vector3D();
		}
		
		public function clear():void
		{
			if (x) x.clear();
			if (y) y.clear();
			if (z) z.clear();
			x = null;
			y = null;
			z = null;
			defaultValue = null;
		}
		
		public function reset():void
		{
			if (x) x.reset();
			if (y) y.reset();
			if (z) z.reset();
		}
		
		public function getVector3D(time:Number):Vector3D
		{
			var v:Vector3D = new Vector3D();
			v.x = x? x.getValue(time) : defaultValue.x;
			v.y = y? y.getValue(time) : defaultValue.y;
			v.z = z? z.getValue(time) : defaultValue.z;
			return v;
		}
		
		public function clone():AnimationCurveNode 
		{
			var result:AnimationCurveNode = new AnimationCurveNode();
			result.defaultValue = defaultValue.clone();
			result.x = x? x.clone() : null;
			result.y = y? y.clone() : null;
			result.z = z? z.clone() : null;
			return result;
		}
		
		/**
		 * キーフレーム間の線形補完の有無を設定
		 * @param	enabled
		 */
		public function setInterpolationEnabled(enabled:Boolean):void 
		{
			if (x) x.interpolationEnabled = enabled;
			if (y) y.interpolationEnabled = enabled;
			if (z) z.interpolationEnabled = enabled;			
		}
		
		public function setStartTime(time:Number):void 
		{
			if (x) x.startTime = time;
			if (y) y.startTime = time;
			if (z) z.startTime = time;
		}
		
		public function setEndTime(time:Number):void 
		{
			if (x) x.endTime = time;
			if (y) y.endTime = time;
			if (z) z.endTime = time;
		}
		
	}

}