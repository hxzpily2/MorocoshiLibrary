package net.morocoshi.moja3d.loader.objects 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DLight extends M3DObject 
	{
		
		static public const OMNI:int = 0;
		static public const DIRECTIONAL:int = 1;
		static public const SPOT:int = 2;
		static public const AMBIENT:int = 3;
		
		public var type:int;
		public var color:uint;
		public var fadeStart:Number;
		public var fadeEnd:Number;
		public var intensity:Number;
		public var innerAngle:Number;
		public var outerAngle:Number;
		
		public function M3DLight() 
		{
		}
		
	}

}