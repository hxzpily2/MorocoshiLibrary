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
		
		public function updateParticle(particle:ParticleCell):void 
		{
		}
		
		public function clone():ParticleWind
		{
			var result:ParticleWind = new ParticleWind();
			cloneProperties(result);
			return result;
		}
		
		public function cloneProperties(target:ParticleWind):void 
		{
			target.type = type;
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