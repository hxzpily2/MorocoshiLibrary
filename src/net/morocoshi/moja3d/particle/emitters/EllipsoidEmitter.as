package net.morocoshi.moja3d.particle.emitters 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * 楕円体の領域に発生させる
	 * 
	 * @author tencho
	 */
	public class EllipsoidEmitter extends ParticleEmitter 
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var equally:Boolean;
		
		/**
		 * @param	x	X軸の半径
		 * @param	y	Y軸の半径
		 * @param	z	Z軸の半径
		 * @param	equally	trueで均等に分布するようになりますが若干処理が重くなります。
		 */
		public function EllipsoidEmitter(x:Number = 0, y:Number = 0, z:Number = 0, equally:Boolean = true) 
		{
			super();
			type = ParticleEmitterType.ELLIPSOID;
			
			this.x = x;
			this.y = y;
			this.z = z;
			this.equally = equally;
		}
		
		override public function getRandomPosition():Vector3D 
		{
			var v:Vector3D = super.getRandomPosition();
			
			var angle:Number = Math.acos(Math.random() * 2 - 1);
			var unit:Number = Math.sin(angle);
			var rotation:Number = Math.random() * Math.PI * 2;
			var tx:Number = Math.cos(rotation) * unit * x;
			var ty:Number = Math.sin(rotation) * unit * y;
			var tz:Number = Math.cos(angle) * z;
			var intensity:Number = Math.random();
			if (equally) intensity = Math.sqrt(intensity);
			v.x += (xAxis.x * tx + yAxis.x * ty + zAxis.x * tz) * intensity;
			v.y += (xAxis.y * tx + yAxis.y * ty + zAxis.y * tz) * intensity;
			v.z += (xAxis.z * tx + yAxis.z * ty + zAxis.z * tz) * intensity;
			return v;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			x = XMLUtil.getAttrNumber(xml.size, "x", 0);
			y = XMLUtil.getAttrNumber(xml.size, "y", 0);
			z = XMLUtil.getAttrNumber(xml.size, "z", 0);
			equally = XMLUtil.getNodeBoolean(xml.equally, true);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.size.@x = x;
			xml.size.@y = y;
			xml.size.@z = z;
			xml.equally = equally;
			return xml;
		}
		
	}

}