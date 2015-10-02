package net.morocoshi.moja3d.particle.emitters 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParticleEmitterType 
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
				case POINT		: EmitterClass = ParticleEmitter; break;
				case CUBE		: EmitterClass = CubeEmitter; break;
				case ELLIPSOID	: EmitterClass = EllipsoidEmitter; break;
				case CIRCLE		: EmitterClass = CircleEmitter; break;
			}
			return EmitterClass;
		}
	}

}