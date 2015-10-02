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
		public var x:Number;
		public var y:Number;
		public var equally:Boolean;
		
		/**
		 * @param	x	X軸の半径
		 * @param	y	Y軸の半径
		 * @param	equally	trueで均等に分布するようになりますが若干処理が重くなります。
		 */
		public function CircleEmitter(x:Number = 0, y:Number = 0, equally:Boolean = true)
		{
			super();
			this.x = x;
			this.y = y;
			this.equally = equally;
			type = ParticleEmitterType.CIRCLE;
		}
		
		override public function getRandomPosition():Vector3D 
		{
			var v:Vector3D = super.getRandomPosition();
			var angle:Number = Math.random() * Math.PI * 2;
			var intensity:Number = Math.random();
			if (equally) intensity = Math.sqrt(intensity);
			var tx:Number = Math.cos(angle) * x * intensity;
			var ty:Number = Math.sin(angle) * y * intensity;
			v.x += xAxis.x * tx + yAxis.x * ty;
			v.y += xAxis.y * tx + yAxis.y * ty;
			v.z += xAxis.z * tx + yAxis.z * ty;
			return v;
		}
		
		override public function parse(xml:XML):void 
		{
			super.parse(xml);
			x = XMLUtil.getAttrNumber(xml.size, "x", 0);
			y = XMLUtil.getAttrNumber(xml.size, "y", 0);
			equally = XMLUtil.getNodeBoolean(xml.equally, true);
		}
		
		override public function toXML():XML 
		{
			var xml:XML = super.toXML();
			xml.size.@x = x;
			xml.size.@y = y;
			xml.equally = equally;
			return xml;
		}
		
	}

}