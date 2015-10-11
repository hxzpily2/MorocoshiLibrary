package net.morocoshi.moja3d.particle.wind 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	
	/**
	 * 乱気流の風
	 * 
	 * @author tencho
	 */
	public class TurbulenceWind extends ParticleWind 
	{
		public var seed:int = 1;
		public var noise:Noise3D;
		public var intensityXMin:Number = -1;
		public var intensityYMin:Number = -1;
		public var intensityZMin:Number = -1;
		public var intensityXMax:Number = 1;
		public var intensityYMax:Number = 1;
		public var intensityZMax:Number = 1;
		public var size:Number = 100;
		public var segment:int = 5;
		
		public function TurbulenceWind() 
		{
			super();
			noise = new Noise3D();
			updateNoise();
			type = ParticleWindType.TURBULENCE;
		}
		
		public function updateNoise():void 
		{
			noise.init(seed, segment, segment, segment);
			noise.setSize(size, size, size);
		}
		
		override public function getVelocity(particle:ParticleCell):Vector3D 
		{
			var v:Vector3D = noise.noize(particle.x, particle.y, particle.z);
			v.x *= (intensityXMax - intensityXMin);
			v.y *= (intensityYMax - intensityYMin);
			v.z *= (intensityZMax - intensityZMin);
			v.x += intensityXMin;
			v.y += intensityYMin;
			v.z += intensityZMin;
			return v;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			seed = XMLUtil.getNodeNumber(xml.seed, 1);
			intensityXMin = XMLUtil.getAttrNumber(xml.intensityX, "min", -1);
			intensityXMax = XMLUtil.getAttrNumber(xml.intensityX, "max", 1);
			intensityYMin = XMLUtil.getAttrNumber(xml.intensityY, "min", -1);
			intensityYMax = XMLUtil.getAttrNumber(xml.intensityY, "max", 1);
			intensityZMin = XMLUtil.getAttrNumber(xml.intensityZ, "min", -1);
			intensityZMax = XMLUtil.getAttrNumber(xml.intensityZ, "max", 1);
			size = XMLUtil.getNodeNumber(xml.size, 100);
			segment = XMLUtil.getNodeNumber(xml.segment, 5);
			updateNoise();
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.seed = seed;
			xml.intensityX.@min = intensityXMin;
			xml.intensityX.@max = intensityXMax;
			xml.intensityY.@min = intensityYMin;
			xml.intensityY.@max = intensityYMax;
			xml.intensityZ.@min = intensityZMin;
			xml.intensityZ.@max = intensityZMax;
			xml.size = size;
			xml.segment = segment;
			return xml;
		}
		
	}

}