package net.morocoshi.moja3d.particle.range 
{
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	import net.morocoshi.moja3d.particle.ParticleEmitter;
	
	use namespace moja3d;
	
	/**
	 * 楕円体の領域に発生させる
	 * 
	 * @author tencho
	 */
	public class EllipsoidRange extends ParticleRange 
	{
		public var radiusX:Number;
		public var radiusY:Number;
		public var radiusZ:Number;
		public var equally:Boolean;
		
		/**
		 * @param	radiusX	X軸の半径
		 * @param	radiusY	Y軸の半径
		 * @param	radiusZ	Z軸の半径
		 * @param	equally	trueで均等に分布するようになりますが若干処理が重くなります。
		 */
		public function EllipsoidRange(radiusX:Number = 0, radiusY:Number = 0, radiusZ:Number = 0, equally:Boolean = true) 
		{
			super();
			type = ParticleRangeType.ELLIPSOID;
			
			this.radiusX = radiusX;
			this.radiusY = radiusY;
			this.radiusZ = radiusZ;
			this.equally = equally;
		}
		
		override public function setRandomPosition(particle:ParticleCell, emitter:ParticleEmitter):void 
		{
			super.setRandomPosition(particle, emitter);
			
			var angle:Number = Math.acos(Math.random() * 2 - 1);
			var unit:Number = Math.sin(angle);
			var rotation:Number = Math.random() * Math.PI * 2;
			var tx:Number = Math.cos(rotation) * unit * radiusX;
			var ty:Number = Math.sin(rotation) * unit * radiusY;
			var tz:Number = Math.cos(angle) * radiusZ;
			var intensity:Number = Math.random();
			if (equally) intensity = Math.sqrt(intensity);
			particle.x += (emitter.xAxis.x * tx + emitter.yAxis.x * ty + emitter.zAxis.x * tz) * intensity;
			particle.y += (emitter.xAxis.y * tx + emitter.yAxis.y * ty + emitter.zAxis.y * tz) * intensity;
			particle.z += (emitter.xAxis.z * tx + emitter.yAxis.z * ty + emitter.zAxis.z * tz) * intensity;
		}
		
		override public function clone():ParticleRange 
		{
			var result:EllipsoidRange = new EllipsoidRange();
			cloneProperties(result);
			return result;
		}
		
		override public function cloneProperties(target:ParticleRange):void 
		{
			super.cloneProperties(target);
			var range:EllipsoidRange = target as EllipsoidRange;
			range.equally = equally;
			range.radiusX = radiusX;
			range.radiusY = radiusY;
			range.radiusZ = radiusZ;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			radiusX = XMLUtil.getAttrNumber(xml.size, "x", 0);
			radiusY = XMLUtil.getAttrNumber(xml.size, "y", 0);
			radiusZ = XMLUtil.getAttrNumber(xml.size, "z", 0);
			equally = XMLUtil.getNodeBoolean(xml.equally, true);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.size.@x = radiusX;
			xml.size.@y = radiusY;
			xml.size.@z = radiusZ;
			xml.equally = equally;
			return xml;
		}
		
	}

}