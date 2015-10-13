package net.morocoshi.moja3d.particle.range 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.particle.ParticleEmitter;
	import net.morocoshi.moja3d.particle.ParticleSystem;
	
	use namespace moja3d;
	
	/**
	 * パーティクルの発生位置を決める
	 * 
	 * @author tencho
	 */
	public class ParticleRange extends Object3D
	{
		public var type:String;
		//public var system:ParticleSystem;
		
		public function ParticleRange() 
		{
			super();
			type = ParticleRangeType.POINT;
		}
		
		/**
		 * 新規パーティクル生成位置を取得
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		public function getRandomPosition(emitter:ParticleEmitter):Vector3D
		{
			var v:Vector3D = new Vector3D(emitter.position.x, emitter.position.y, emitter.position.z);
			return v;
		}
		
		public function parse(xml:XML):void
		{
		}
		
		public function toXML():XML
		{
			var xml:XML = <emitter />;
			xml.type = type;
			return xml;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		public function randomInt(min:int, max:int):int
		{
			if (min == max) return min;
			return min + int(Math.random() * (max - min + 1));
		}
		
		public function random(min:Number, max:Number):Number
		{
			if (min == max) return min;
			return min + Math.random() * (max - min);
		}
		
	}

}