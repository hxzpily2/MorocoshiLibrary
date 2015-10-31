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
		private var power:Vector3D;
		public var noise:Noise3D;
		public var intensityXMin:Number = -1;
		public var intensityYMin:Number = -1;
		public var intensityZMin:Number = -1;
		public var intensityXMax:Number = 1;
		public var intensityYMax:Number = 1;
		public var intensityZMax:Number = 1;
		
		public function TurbulenceWind() 
		{
			super();
			type = ParticleWindType.TURBULENCE;
			noise = new Noise3D();
			power = new Vector3D();
		}
		
		public function setNoise(seed:int, size:Number, segment:int):void 
		{
			noise.init(seed, segment, segment, segment);
			noise.setSize(size, size, size);
		}
		
		public function setIntensityX(min:Number, max:Number = NaN):void
		{
			intensityXMin = min;
			intensityXMax = isNaN(max)? min : max;
		}
		
		public function setIntensityY(min:Number, max:Number = NaN):void
		{
			intensityYMin = min;
			intensityYMax = isNaN(max)? min : max;
		}
		
		public function setIntensityZ(min:Number, max:Number = NaN):void
		{
			intensityZMin = min;
			intensityZMax = isNaN(max)? min : max;
		}
		
		override public function updateParticle(particle:ParticleCell):void 
		{
			var t:Number = particle.time - particle.prevTime;
			noise.noize(particle.x, particle.y, particle.z, power);
			particle.vx += t * ((intensityXMax - intensityXMin) * power.x + intensityXMin);
			particle.vy += t * ((intensityYMax - intensityYMin) * power.y + intensityYMin);
			particle.vz += t * ((intensityZMax - intensityZMin) * power.z + intensityZMin);
		}
		
		public function setIntensity(intensity:Number):void 
		{
			intensityXMin = -intensity;
			intensityXMax = intensity;
			intensityYMin = -intensity;
			intensityYMax = intensity;
			intensityZMin = -intensity;
			intensityZMax = intensity;
		}
		
		override public function clone():ParticleWind 
		{
			var result:TurbulenceWind = new TurbulenceWind();
			cloneProperties(result);
			return result;
		}
		
		override public function cloneProperties(target:ParticleWind):void 
		{
			super.cloneProperties(target);
			var wind:TurbulenceWind = target as TurbulenceWind;
			wind.intensityXMin = intensityXMin;
			wind.intensityXMax = intensityXMax;
			wind.intensityYMin = intensityYMin;
			wind.intensityYMax = intensityYMax;
			wind.intensityZMin = intensityZMin;
			wind.intensityZMax = intensityZMax;
			wind.noise = noise.clone();
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			var seed:int = XMLUtil.getNodeNumber(xml.seed, 1);
			var size:Number = XMLUtil.getNodeNumber(xml.size, 1);
			var segment:int = XMLUtil.getNodeNumber(xml.segment, 1);
			setNoise(seed, size, segment);
			intensityXMin = XMLUtil.getAttrNumber(xml.intensityX, "min", -1);
			intensityXMax = XMLUtil.getAttrNumber(xml.intensityX, "max", 1);
			intensityYMin = XMLUtil.getAttrNumber(xml.intensityY, "min", -1);
			intensityYMax = XMLUtil.getAttrNumber(xml.intensityY, "max", 1);
			intensityZMin = XMLUtil.getAttrNumber(xml.intensityZ, "min", -1);
			intensityZMax = XMLUtil.getAttrNumber(xml.intensityZ, "max", 1);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.seed = noise.seed;
			xml.size = noise.size[0];
			xml.segment = noise.segment[0];
			xml.intensityX.@min = intensityXMin;
			xml.intensityX.@max = intensityXMax;
			xml.intensityY.@min = intensityYMin;
			xml.intensityY.@max = intensityYMax;
			xml.intensityZ.@min = intensityZMin;
			xml.intensityZ.@max = intensityZMax;
			return xml;
		}
		
	}

}