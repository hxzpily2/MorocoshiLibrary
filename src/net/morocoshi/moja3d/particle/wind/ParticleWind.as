package net.morocoshi.moja3d.particle.wind 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParticleWind 
	{
		public var type:String;
		
		public function ParticleWind() 
		{
			type = ParticleWindType.NONE;
		}
		
		public function getVelocity(particle:ParticleCell):Vector3D
		{
			return new Vector3D();
		}
		
		public function updateParticle(particle:ParticleCell):void 
		{
			particle.velocity.incrementBy(getVelocity(particle));
		}
		
		public function parse(xml:XML):void
		{
		}
		
		public function toXML():XML
		{
			var xml:XML = <wind />;
			xml.type = type;
			return xml;
		}
		
	}

}