package net.morocoshi.moja3d.particle.emitters 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.particle.ParticleSystem;
	
	use namespace moja3d;
	
	/**
	 * パーティクルの発生位置を決める
	 * 
	 * @author tencho
	 */
	public class ParticleEmitter extends Object3D
	{
		public var type:String;
		public var system:ParticleSystem;
		public var position:Vector3D = new Vector3D();
		public var xAxis:Vector3D = new Vector3D(1, 0, 0);
		public var yAxis:Vector3D = new Vector3D(0, 1, 0);
		public var zAxis:Vector3D = new Vector3D(0, 0, 1);
		
		public function ParticleEmitter() 
		{
			super();
			type = ParticleEmitterType.POINT;
		}
		
		/**
		 * 新規パーティクル生成位置を取得
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		public function getRandomPosition():Vector3D
		{
			var v:Vector3D = new Vector3D(position.x, position.y, position.z);
			return v;
		}
		
		/**
		 * 
		 * @param	system
		 * @param	container
		 */
		public function updateMatrix():void 
		{
			var systemMatrix:Matrix3D = system.worldMatrix.clone();
			var emitterMatrix:Matrix3D = _worldMatrix.clone();
			systemMatrix.invert();
			emitterMatrix.append(systemMatrix);
			var rawData:Vector.<Number> = emitterMatrix.rawData;
			xAxis.x = rawData[0];
			xAxis.y = rawData[1];
			xAxis.z = rawData[2];
			yAxis.x = rawData[4];
			yAxis.y = rawData[5];
			yAxis.z = rawData[6];
			zAxis.x = rawData[8];
			zAxis.y = rawData[9];
			zAxis.z = rawData[10];
			position.x = rawData[12];
			position.y = rawData[13];
			position.z = rawData[14];
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