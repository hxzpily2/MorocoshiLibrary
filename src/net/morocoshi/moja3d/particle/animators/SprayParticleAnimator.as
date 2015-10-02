package net.morocoshi.moja3d.particle.animators 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.particle.emitters.ParticleEmitter;
	
	/**
	 * エミッターのZ軸方向に初速を加えます。Z軸を中心にした広がりを指定可能。（例：噴水やスプレー等）
	 * 
	 * @author tencho
	 */
	public class SprayParticleAnimator extends ParticleAnimator
	{
		public var equally:Boolean = false;
		public var sprayIntensityMin:Number = 0;
		public var sprayIntensityMax:Number = 0;
		public var sprayRangeMin:Number = 0;
		public var sprayRangeMax:Number = 0;
		
		public function SprayParticleAnimator() 
		{
			super();
			type = ParticleAnimatorType.SPRAY;
		}
		
		override public function getEmitVelocity():Vector3D 
		{
			var v:Vector3D = new Vector3D();
			var intensity:Number = random(sprayIntensityMin, sprayIntensityMax);
			var em:ParticleEmitter = system.emitter;
			if (!sprayRangeMin && !sprayRangeMax)
			{
				v.x = em.zAxis.x * intensity;
				v.y = em.zAxis.y * intensity;
				v.z = em.zAxis.z * intensity;
			}
			else
			{
				var angle:Number;
				if (sprayRangeMin == sprayRangeMax)
				{
					angle = sprayRangeMin;
				}
				else if (!equally)
				{
					//偏りが多いが軽いランダム角度
					angle = random(sprayRangeMin, sprayRangeMax);
				}
				else
				{
					//偏りが少ないが重いランダム角度
					var cosMin:Number = Math.cos(sprayRangeMin);
					var cosMax:Number = Math.cos(sprayRangeMax);
					angle = Math.acos(random(cosMin, cosMax));
				}
				var tz:Number = Math.cos(angle);
				var unit:Number = Math.sin(angle);
				var rotation:Number = Math.random() * Math.PI * 2;
				var tx:Number = Math.cos(rotation) * unit;
				var ty:Number = Math.sin(rotation) * unit;
				v.x = (em.xAxis.x * tx + em.yAxis.x * ty + em.zAxis.x * tz) * intensity;
				v.y = (em.xAxis.y * tx + em.yAxis.y * ty + em.zAxis.y * tz) * intensity;
				v.z = (em.xAxis.z * tx + em.yAxis.z * ty + em.zAxis.z * tz) * intensity;
			}
			return v;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			equally = XMLUtil.getNodeBoolean(xml.equally, false);
			sprayIntensityMin = XMLUtil.getAttrNumber(xml.sprayIntensity, "min", 0);
			sprayIntensityMax = XMLUtil.getAttrNumber(xml.sprayIntensity, "max", 0);
			sprayRangeMin = XMLUtil.getAttrNumber(xml.sprayRange, "min", 0);
			sprayRangeMax = XMLUtil.getAttrNumber(xml.sprayRange, "max", 0);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			delete xml.velocityMin;
			delete xml.velocityMax;
			xml.equally = equally;
			xml.sprayIntensity.@min = sprayIntensityMin;
			xml.sprayIntensity.@max = sprayIntensityMax;
			xml.sprayRange.@min = sprayRangeMin;
			xml.sprayRange.@max = sprayRangeMax;
			return xml;
		}
		
	}

}