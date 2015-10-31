package net.morocoshi.moja3d.particle.cells 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParticleData 
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		public var width:Number = 5;
		public var height:Number = 5;
		public var u0:Number = 0;
		public var u1:Number = 1;
		public var v0:Number = 0;
		public var v1:Number = 1;
		public var alpha:Number = 1;
		public var rotation:Number = 0;
		public var next:ParticleData;
		public var prev:ParticleData;
		
		public function ParticleData() 
		{
		}
		
	}

}