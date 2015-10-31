package net.morocoshi.moja3d.particle 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.particle.animators.ParticleAnimator;
	import net.morocoshi.moja3d.particle.range.ParticleRange;
	import net.morocoshi.moja3d.particle.wind.ParticleWind;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ParticleEmitter extends Object3D 
	{
		/**エミッタが稼働しているか*/
		public var enabled:Boolean = true;
		/**パーティクルの幅*/
		public var particleWidth:Number = 1;
		/**パーティクルの高さ*/
		public var particleHeight:Number = 1;
		
		moja3d var position:Vector3D = new Vector3D();
		moja3d var xAxis:Vector3D = new Vector3D(1, 0, 0);
		moja3d var yAxis:Vector3D = new Vector3D(0, 1, 0);
		moja3d var zAxis:Vector3D = new Vector3D(0, 0, 1);
		
		moja3d var _animator:ParticleAnimator;
		moja3d var _range:ParticleRange = new ParticleRange();
		moja3d var _birthRate:Number = 1;
		moja3d var _wind:ParticleWind;
		
		/**birthRateの逆数。パーティクルを生成する時間の間隔*/
		moja3d var birthTime:Number = 1;
		moja3d var lastBirth:int;
		
		public function ParticleEmitter() 
		{
			super();
		}
		
		override public function clone():Object3D 
		{
			var result:ParticleEmitter = new ParticleEmitter();
			cloneProperties(result);
			return result;
		}
		
		override public function reference():Object3D 
		{
			var result:ParticleEmitter = new ParticleEmitter();
			referenceProperties(result);
			return result;
		}
		
		override public function referenceProperties(target:Object3D):void
		{
			super.cloneProperties(target);
			var emitter:ParticleEmitter = target as ParticleEmitter;
			emitter.animator = animator;
			emitter.range = range;
			emitter.wind = wind;
			emitter.particleWidth = particleWidth;
			emitter.particleHeight = particleHeight;
			emitter.birthTime = birthTime;
			emitter.enabled = enabled;
		}
		
		override public function cloneProperties(target:Object3D):void 
		{
			super.cloneProperties(target);
			var emitter:ParticleEmitter = target as ParticleEmitter;
			emitter.animator = animator.clone();
			emitter.range = range.clone();
			emitter.wind = wind? wind.clone() : null;
			emitter.particleWidth = particleWidth;
			emitter.particleHeight = particleHeight;
			emitter.birthTime = birthTime;
			emitter.enabled = enabled;
		}
		
		public function updateMatrix(system:ParticleSystem):void 
		{
			var systemMatrix:Matrix3D = system.worldMatrix.clone();
			var emitterMatrix:Matrix3D = worldMatrix.clone();
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
		
		/**
		 * パーティクルの動きを管理するクラス
		 */
		public function get animator():ParticleAnimator 
		{
			return _animator;
		}
		
		public function set animator(value:ParticleAnimator):void 
		{
			_animator = value;
		}
		
		/**
		 * パーティクル発生範囲を管理するクラス
		 */
		public function get range():ParticleRange 
		{
			return _range;
		}
		
		public function set range(value:ParticleRange):void 
		{
			_range = value;
		}
		
		/**
		 * 1秒間にいくつパーティクルを生成するか
		 */
		public function get birthRate():Number 
		{
			return _birthRate;
		}
		
		public function set birthRate(value:Number):void 
		{
			_birthRate = value;
			lastBirth = 0;
			birthTime = 1 / _birthRate;
		}
		
		public function get wind():ParticleWind 
		{
			return _wind;
		}
		
		public function set wind(value:ParticleWind):void 
		{
			_wind = value;
		}
		
	}

}