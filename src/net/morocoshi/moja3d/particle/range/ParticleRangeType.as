package net.morocoshi.moja3d.particle.range 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParticleRangeType 
	{
		static public const POINT:String = "point";
		static public const CUBE:String = "cube";
		static public const ELLIPSOID:String = "ellipsoid";
		static public const CIRCLE:String = "circle";
		
		static public function getClass(type:String):Class 
		{
			var EmitterClass:Class;
			switch(type)
			{
				case POINT		: EmitterClass = ParticleRange; break;
				case CUBE		: EmitterClass = CubeRange; break;
				case ELLIPSOID	: EmitterClass = EllipsoidRange; break;
				case CIRCLE		: EmitterClass = CircleRange; break;
			}
			return EmitterClass;
		}
	}

}