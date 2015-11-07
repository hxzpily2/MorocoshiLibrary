package net.morocoshi.moja3d.particle.range 
{
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	import net.morocoshi.moja3d.particle.ParticleEmitter;
	
	use namespace moja3d;
	
	/**
	 * 直方体の領域にパーティクルを発生させる
	 * 
	 * @author tencho
	 */
	public class CubeRange extends ParticleRange
	{
		public var sizeX:Number;
		public var sizeY:Number;
		public var sizeZ:Number;
		
		/**
		 * 
		 * @param	sizeX	X軸方向の幅
		 * @param	sizeY	Y軸方向の幅
		 * @param	sizeZ	Z軸方向の幅
		 */
		public function CubeRange(sizeX:Number = 0, sizeY:Number = 0, sizeZ:Number = 0) 
		{
			super();
			type = ParticleRangeType.CUBE;
			
			this.sizeX = sizeX;
			this.sizeY = sizeY;
			this.sizeZ = sizeZ;
		}
		
		override public function setRandomPosition(particle:ParticleCell, emitter:ParticleEmitter, per:Number):void 
		{
			super.setRandomPosition(particle, emitter, per);
			
			var tx:Number = random(-sizeX / 2, sizeX / 2);
			var ty:Number = random(-sizeY / 2, sizeY / 2);
			var tz:Number = random(-sizeZ / 2, sizeZ / 2);
			particle.x += emitter.xAxis.x * tx + emitter.yAxis.x * ty + emitter.zAxis.x * tz;
			particle.y += emitter.xAxis.y * tx + emitter.yAxis.y * ty + emitter.zAxis.y * tz;
			particle.z += emitter.xAxis.z * tx + emitter.yAxis.z * ty + emitter.zAxis.z * tz;
		}
		
		override public function clone():ParticleRange 
		{
			var result:CubeRange = new CubeRange();
			cloneProperties(result);
			return result;
		}
		
		override public function cloneProperties(target:ParticleRange):void 
		{
			super.cloneProperties(target);
			var range:CubeRange = target as CubeRange;
			range.sizeX = sizeX;
			range.sizeY = sizeY;
			range.sizeZ = sizeZ;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			sizeX = XMLUtil.getAttrNumber(xml.size, "x", 0);
			sizeY = XMLUtil.getAttrNumber(xml.size, "y", 0);
			sizeZ = XMLUtil.getAttrNumber(xml.size, "z", 0);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.size.@x = sizeX;
			xml.size.@y = sizeY;
			xml.size.@z = sizeZ;
			return xml;
		}
		
	}

}