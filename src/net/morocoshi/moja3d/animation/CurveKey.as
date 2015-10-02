package net.morocoshi.moja3d.animation 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class CurveKey 
	{
		public var time:Number;
		public var value:Number;
		public var tangent:int;
		
		public var nextCtrlTime:Number = 0;
		public var nextCtrlValue:Number = 0;
		public var prevCtrlTime:Number = 0;
		public var prevCtrlValue:Number = 0;
		
		public function CurveKey() 
		{
		}
		
		/**
		 * 後方のコントロールポイントが伸びているか
		 */
		public function get isCurvePointPrev():Boolean 
		{
			return !!(prevCtrlTime || prevCtrlValue);
		}
		
		/**
		 * 前方のコントロールポイントが伸びているか
		 */
		public function get isCurvePointNext():Boolean 
		{
			return !!(nextCtrlTime || nextCtrlValue);
		}
		
	}

}