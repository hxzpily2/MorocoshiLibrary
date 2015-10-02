package net.morocoshi.common.loaders.fbx.expoters 
{
	import net.morocoshi.moja3d.loader.animation.TangentType;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FEKeyFrame 
	{
		public var time:Number;
		public var value:Number;
		public var nextWeight:Number = 0;
		public var nextAngle:Number = 0;
		public var prevWeight:Number = 0;
		public var prevAngle:Number = 0;
		public var tangent:int = TangentType.LINER;
		
		public function FEKeyFrame() 
		{
		}
		
	}

}