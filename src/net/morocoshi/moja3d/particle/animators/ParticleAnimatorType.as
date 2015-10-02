package net.morocoshi.moja3d.particle.animators 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParticleAnimatorType 
	{
		
		static public const BASIC:String = "basic";
		static public const SPRAY:String = "spray";
		
		static public function getClass(type:String):Class 
		{
			var AnimatorClass:Class;
			switch(type)
			{
				case BASIC	: AnimatorClass = ParticleAnimator; break;
				case SPRAY	: AnimatorClass = SprayParticleAnimator; break;
			}
			return AnimatorClass;
		}
		
	}

}