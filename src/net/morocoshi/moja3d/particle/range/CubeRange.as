package net.morocoshi.moja3d.particle.range 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.particle.ParticleEmitter;
	
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
		
		override public function getRandomPosition(emitter:ParticleEmitter):Vector3D 
		{
			var v:Vector3D = super.getRandomPosition(emitter);
			
			var tx:Number = random(-sizeX / 2, sizeX / 2);
			var ty:Number = random(-sizeY / 2, sizeY / 2);
			var tz:Number = random(-sizeZ / 2, sizeZ / 2);
			v.x += emitter.xAxis.x * tx + emitter.yAxis.x * ty + emitter.zAxis.x * tz;
			v.y += emitter.xAxis.y * tx + emitter.yAxis.y * ty + emitter.zAxis.y * tz;
			v.z += emitter.xAxis.z * tx + emitter.yAxis.z * ty + emitter.zAxis.z * tz;
			
			return v;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			x = XMLUtil.getAttrNumber(xml.size, "x", 0);
			y = XMLUtil.getAttrNumber(xml.size, "y", 0);
			z = XMLUtil.getAttrNumber(xml.size, "z", 0);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.size.@x = x;
			xml.size.@y = y;
			xml.size.@z = z;
			return xml;
		}
		
	}

}