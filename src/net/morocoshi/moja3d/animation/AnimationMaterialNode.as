package net.morocoshi.moja3d.animation 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AnimationMaterialNode 
	{
		public var offsetU:AnimationCurveTrack;
		public var offsetV:AnimationCurveTrack;
		
		public function AnimationMaterialNode() 
		{
		}
		
		public function reset():void
		{
			if (offsetU) offsetU.reset();
			if (offsetV) offsetV.reset();
		}
		
		public function clone():AnimationMaterialNode 
		{
			var result:AnimationMaterialNode = new AnimationMaterialNode();
			result.offsetU = offsetU? offsetU.clone() : null;
			result.offsetV = offsetV? offsetV.clone() : null;
			return result;
		}
		
		/**
		 * キーフレーム間の線形補完の有無を設定
		 * @param	enabled
		 */
		public function setInterpolationEnabled(enabled:Boolean):void 
		{
			if (offsetU) offsetU.interpolationEnabled = enabled;
			if (offsetV) offsetV.interpolationEnabled = enabled;
		}
		
	}

}