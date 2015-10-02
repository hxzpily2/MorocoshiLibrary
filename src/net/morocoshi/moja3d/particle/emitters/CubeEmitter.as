package net.morocoshi.moja3d.particle.emitters 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * 直方体の領域にパーティクルを発生させる
	 * 
	 * @author tencho
	 */
	public class CubeEmitter extends ParticleEmitter
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		/**
		 * 
		 * @param	x	X軸方向の幅
		 * @param	y	Y軸方向の幅
		 * @param	z	Z軸方向の幅
		 */
		public function CubeEmitter(x:Number = 0, y:Number = 0, z:Number = 0) 
		{
			super();
			type = ParticleEmitterType.CUBE;
			
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		override public function getRandomPosition():Vector3D 
		{
			var v:Vector3D = super.getRandomPosition();
			
			var tx:Number = random(-x / 2, x / 2);
			var ty:Number = random(-y / 2, y / 2);
			var tz:Number = random(-z / 2, z / 2);
			v.x += xAxis.x * tx + yAxis.x * ty + zAxis.x * tz;
			v.y += xAxis.y * tx + yAxis.y * ty + zAxis.y * tz;
			v.z += xAxis.z * tx + yAxis.z * ty + zAxis.z * tz;
			
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