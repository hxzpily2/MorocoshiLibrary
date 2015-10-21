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
	 * @author tencho
	 */
	public class ParticleEmitter extends Object3D 
	{
		/**エミッタが稼働しているか*/
		public var enabled:Boolean = true;
		/**パーティクルの幅*/
		public var particleWidth:Number = 10;
		/**パーティクルの高さ*/
		public var particleHeight:Number = 10;
		
		public var position:Vector3D = new Vector3D();
		public var xAxis:Vector3D = new Vector3D(1, 0, 0);
		public var yAxis:Vector3D = new Vector3D(0, 1, 0);
		public var zAxis:Vector3D = new Vector3D(0, 0, 1);
		
		private var _animator:ParticleAnimator;
		private var _range:ParticleRange;
		private var _wind:ParticleWind;
		private var _birthRate:Number = 1;
		
		moja3d var totalTime:Number = 0;
		moja3d var birthTime:Number = 1;
		moja3d var lastBirth:int;
		
		public function ParticleEmitter() 
		{
			super();
		}
		
		public function updateMatrix(system:ParticleSystem):void 
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
		
		public function getRandomPosition():Vector3D 
		{
			return _range.getRandomPosition(this);
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
			/*
			if (_range)
			{
				_range.system = null;
			}*/
			_range = value;
			/*
			_range.system = this;
			if (_range.parent == null)
			{
				addChild(_range);
			}*/
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
			totalTime = 0;
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