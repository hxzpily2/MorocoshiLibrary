package net.morocoshi.moja3d.particle.wind 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class ParticleWindType 
	{
		
		static public const NONE:String = "none";
		static public const TURBULENCE:String = "turbulence";
		
		static public function getClass(type:String):Class 
		{
			var WindClass:Class;
			switch(type)
			{
				case NONE		: WindClass = ParticleWind; break;
				case TURBULENCE	: WindClass = TurbulenceWind; break;
			}
			return WindClass;
		}
		
	}

}