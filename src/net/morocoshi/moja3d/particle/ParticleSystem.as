package net.morocoshi.moja3d.particle 
{
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.objects.Particle3D;
	import net.morocoshi.moja3d.particle.animators.ParticleAnimator;
	import net.morocoshi.moja3d.particle.animators.ParticleAnimatorType;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	import net.morocoshi.moja3d.particle.emitters.ParticleEmitter;
	import net.morocoshi.moja3d.particle.emitters.ParticleEmitterType;
	import net.morocoshi.moja3d.particle.wind.ParticleWind;
	import net.morocoshi.moja3d.particle.wind.ParticleWindType;
	
	/**
	 * パーティクルを管理するクラス。パーティクルが表示されるコンテナの役割も果たす。
	 * 
	 * @author tencho
	 */
	public class ParticleSystem extends Particle3D
	{
		/**エミッタが稼働しているか*/
		public var enabled:Boolean = true;
		/**パーティクルの幅*/
		public var particleWidth:Number = 10;
		/**パーティクルの高さ*/
		public var particleHeight:Number = 10;
		/**パーティクルの同時発生限界数（-1で無制限）*/
		public var limit:int = -1;
		
		private var particleCache:Vector.<ParticleCell> = new Vector.<ParticleCell>;
		private var _animator:ParticleAnimator;
		private var _emitter:ParticleEmitter;
		private var _wind:ParticleWind;
		private var _birthRate:Number = 1;
		private var totalTime:Number = 0;
		private var birthTime:Number = 1;
		private var lastBirth:int;
		private var sprite:Sprite = new Sprite();
		private var context3D:Context3D;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function ParticleSystem(material:Material = null) 
		{
			super(material);
		}
		
		//--------------------------------------------------------------------------
		//
		//  getter/setter
		//
		//--------------------------------------------------------------------------
		
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
			if (_animator)
			{
				_animator.system = null;
			}
			_animator = value;
			_animator.system = this;
		}
		
		/**
		 * パーティクル発生範囲を管理するクラス
		 */
		public function get emitter():ParticleEmitter 
		{
			return _emitter;
		}
		
		public function set emitter(value:ParticleEmitter):void 
		{
			if (_emitter)
			{
				_emitter.system = null;
			}
			_emitter = value;
			_emitter.system = this;
			if (_emitter.parent == null)
			{
				addChild(_emitter);
			}
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
		
		//--------------------------------------------------------------------------
		//
		//  設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * パーティクルのサイズ、マテリアルを設定する
		 * @param	width
		 * @param	height
		 * @param	material
		 */
		public function setParticle(width:Number, height:Number):void
		{
			particleWidth = width;
			particleHeight = height;
		}
		
		public function setContetx3D(context3D:Context3D):void
		{
			this.context3D = context3D;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * パーティクル発生開始
		 * @param	birthRate
		 */
		public function startAutoUpdate():void
		{
			sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * パーティクルの停止
		 */
		public function stopAutoUpdate():void
		{
			sprite.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			if (context3D)
			{
				update(context3D);
			}
		}
		
		/**
		 * パーティクルを1個生成する
		 * @return
		 */
		public function emit():ParticleCell
		{
			if (limit != -1 && particles.length >= limit)
			{
				return null;
			}
			
			var particle:ParticleCell;
			//もしキャッシュにパーティクルがあればそれを再利用する
			if (particleCache.length)
			{
				particle = particleCache.pop();
				///particle.width = particleWidth;
				///particle.height = particleHeight;
			}
			else
			{
				//キャッシュにない場合は新しく生成する
				particle = new ParticleCell();
			}
			particle.latestIndex = 0;
			particles.push(particle);
				
			var position:Vector3D = emitter.getRandomPosition();
			particle.x = position.x;
			particle.y = position.y;
			particle.z = position.z;
			animator.emitParticle(particle);
			return particle;
		}
		
		//--------------------------------------------------------------------------
		//
		//  削除
		//
		//--------------------------------------------------------------------------
		
		/**
		 * パーティクルを全削除して停止する。
		 */
		public function disposeParticles():void
		{
			enabled = false;
			stopAutoUpdate();
			removeAllParticles();
			particleCache.length = 0;
		}
		
		/**
		 * 全てのパーティクルを削除する
		 */
		public function removeAllParticles():void 
		{
			var n:int = particles.length;
			for (var i:int = 0; i < n; i++) 
			{
				particleCache.push(particles[i]);
			}
			particles.length = 0;
		}
		
		//--------------------------------------------------------------------------
		//
		//  更新
		//
		//--------------------------------------------------------------------------
		
		override public function update(context3D:Context3D):void
		{
			var step:Number = 33 / 1000;
			
			if (enabled)
			{
				totalTime += step;
				var birth:int = totalTime / birthTime;
				if (birth > lastBirth)
				{
					emitter.updateMatrix();
					var length:int = birth - lastBirth;
					for (var j:int = 0; j < length; j++) 
					{
						emit();
					}
					lastBirth = birth;
				}
			}
			
			var n:int = particles.length;
			for (var i:int = 0; i < n; i++) 
			{
				var particle:ParticleCell = particles[i] as ParticleCell;
				//風
				if (_wind)
				{
					_wind.updateParticle(particle);
				}
				//重力、回転、アルファ変化
				animator.updateParticle(particle);
				
				if (particle.time >= particle.life)
				{
					var p:ParticleCell = particles.splice(i, 1)[0];
					particleCache.push(p);
					i--;
					n--;
					continue;
				}
				
				particle.time += step;
			}
			
			super.update(context3D);
		}
		
		public function parse(xml:XML):void
		{
			x = XMLUtil.getAttrNumber(xml.position, "x", 0);
			y = XMLUtil.getAttrNumber(xml.position, "y", 0);
			z = XMLUtil.getAttrNumber(xml.position, "z", 0);
			rotationX = XMLUtil.getAttrNumber(xml.rotation, "x", 0);
			rotationY = XMLUtil.getAttrNumber(xml.rotation, "y", 0);
			rotationZ = XMLUtil.getAttrNumber(xml.rotation, "z", 0);
			particleWidth = XMLUtil.getAttrNumber(xml.cell, "width", 10);
			particleHeight = XMLUtil.getAttrNumber(xml.cell, "height", 10);
			birthRate = XMLUtil.getNodeNumber(xml.birthRate, 1);
			limit = int(XMLUtil.getNodeNumber(xml.limit, -1));
			
			var emitterClass:Class = ParticleEmitterType.getClass(xml.emitter[0].type);
			var animatorClass:Class = ParticleAnimatorType.getClass(xml.animator[0].type);
			if (xml.wind.length())
			{
				var windClass:Class = ParticleWindType.getClass(xml.wind[0].type);
				wind = new windClass();
				_wind.parse(xml.wind[0]);
			}
			else
			{
				wind = new ParticleWind();
			}
			emitter = new emitterClass();
			_emitter.parse(xml.emitter[0]);
			animator = new animatorClass();
			_animator.parse(xml.animator[0]);
		}
		
		public function toXML(nodeName:String):XML
		{
			var xml:XML = <{nodeName} />;
			xml.position.@x = x;
			xml.position.@y = y;
			xml.position.@z = z;
			xml.rotation.@x = rotationX;
			xml.rotation.@y = rotationY;
			xml.rotation.@z = rotationZ;
			xml.cell.@width = particleWidth;
			xml.cell.@height = particleHeight;
			xml.birthRate = _birthRate;
			xml.limit = limit;
			xml.emitter = _emitter.toXML();
			xml.animator = _animator.toXML();
			xml.wind = _wind.toXML();
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