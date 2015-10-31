package net.morocoshi.moja3d.particle.cells 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class ParticleList 
	{
		public var root:ParticleData;
		public var length:int;
		
		public function ParticleList() 
		{
			length = 0;
		}
		
		public function remove(particle:ParticleData):void
		{
			if (root == particle)
			{
				root = particle.next;
			}
			if (particle.next) particle.next.prev = particle.prev;
			if (particle.prev) particle.prev.next = particle.next;
			particle.next = null;
			particle.prev = null;
			length--;
		}
		
		public function add(particle:ParticleData):void 
		{
			if (root)
			{
				root.prev = particle;
				particle.next = root;
			}
			root = particle;
			length++;
		}
		
	}

}