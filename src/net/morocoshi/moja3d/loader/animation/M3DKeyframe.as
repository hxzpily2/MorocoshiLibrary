package net.morocoshi.moja3d.loader.animation 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DKeyframe 
	{
		/**時間*/
		public var time:Number;
		/**値*/
		public var value:Number;
		/**補完タイプ*/
		public var tangent:int;
		
		/**[tangent=TangentType.BEZIER時に使用]ベジェハンドル*/
		public var nextTime:Number;
		/**[tangent=TangentType.BEZIER時に使用]ベジェハンドル*/
		public var nextValue:Number;
		/**[tangent=TangentType.BEZIER時に使用]ベジェハンドル*/
		public var prevTime:Number;
		/**[tangent=TangentType.BEZIER時に使用]ベジェハンドル*/
		public var prevValue:Number;
		
		public function M3DKeyframe() 
		{
		}
		
	}

}