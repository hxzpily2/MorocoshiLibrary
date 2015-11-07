package net.morocoshi.moja3d.particle.range 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	import net.morocoshi.moja3d.particle.ParticleEmitter;
	
	use namespace moja3d;
	
	/**
	 * パーティクルの発生位置を決める
	 * 
	 * @author tencho
	 */
	public class ParticleRange
	{
		public var type:String;
		
		public function ParticleRange() 
		{
			type = ParticleRangeType.POINT;
		}
		
		/**
		 * 新規パーティクル生成位置を取得
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		public function setRandomPosition(particle:ParticleCell, emitter:ParticleEmitter, per:Number):void
		{
			var per2:Number = 1 - per;
			particle.x = emitter.position.x * per + emitter.prevPosition.x * per2;
			particle.y = emitter.position.y * per + emitter.prevPosition.y * per2;
			particle.z = emitter.position.z * per + emitter.prevPosition.z * per2;
		}
		
		public function clone():ParticleRange 
		{
			var result:ParticleRange = new ParticleRange();
			cloneProperties(result);
			return result;
		}
		
		public function cloneProperties(target:ParticleRange):void 
		{
			target.type = type;
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
		
		protected function randomInt(min:int, max:int):int
		{
			if (min == max) return min;
			return min + int(Math.random() * (max - min + 1));
		}
		
		protected function random(min:Number, max:Number):Number
		{
			if (min == max) return min;
			return min + Math.random() * (max - min);
		}
		
	}

}