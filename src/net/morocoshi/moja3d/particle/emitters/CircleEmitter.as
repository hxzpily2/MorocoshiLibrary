package net.morocoshi.moja3d.particle.emitters 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * 楕円（XY平面）の領域にパーティクルを発生させる
	 * 
	 * @author tencho
	 */
	public class CircleEmitter extends ParticleEmitter 
	{
		public var radiusX:Number;
		public var radiusY:Number;
		public var equally:Boolean;
		
		/**
		 * @param	radiusX	X軸の半径
		 * @param	radiusY	Y軸の半径
		 * @param	equally	trueで均等に分布するようになりますが若干処理が重くなります。
		 */
		public function CircleEmitter(radiusX:Number = 0, radiusY:Number = 0, equally:Boolean = true)
		{
			super();
			this.radiusX = radiusX;
			this.radiusY = radiusY;
			this.equally = equally;
			type = ParticleEmitterType.CIRCLE;
		}
		
		override public function getRandomPosition():Vector3D 
		{
			var v:Vector3D = super.getRandomPosition();
			var angle:Number = Math.random() * Math.PI * 2;
			var intensity:Number = Math.random();
			if (equally) intensity = Math.sqrt(intensity);
			var tx:Number = Math.cos(angle) * radiusX * intensity;
			var ty:Number = Math.sin(angle) * radiusY * intensity;
			v.x += xAxis.x * tx + yAxis.x * ty;
			v.y += xAxis.y * tx + yAxis.y * ty;
			v.z += xAxis.z * tx + yAxis.z * ty;
			return v;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			radiusX = XMLUtil.getAttrNumber(xml.size, "x", 0);
			radiusY = XMLUtil.getAttrNumber(xml.size, "y", 0);
			equally = XMLUtil.getNodeBoolean(xml.equally, true);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.size.@x = radiusX;
			xml.size.@y = radiusY;
			xml.equally = equally;
			return xml;
		}
		
	}

}