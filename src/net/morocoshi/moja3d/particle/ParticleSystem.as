package net.morocoshi.moja3d.particle 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.particle.animators.ParticleAnimator;
	import net.morocoshi.moja3d.particle.animators.ParticleAnimatorType;
	import net.morocoshi.moja3d.particle.cells.Particle3D;
	import net.morocoshi.moja3d.particle.emitters.ParticleEmitter;
	import net.morocoshi.moja3d.particle.emitters.ParticleEmitterType;
	import net.morocoshi.moja3d.particle.wind.ParticleWind;
	import net.morocoshi.moja3d.particle.wind.ParticleWindType;
	
	/**
	 * パーティクル
	 * 
	 * @author tencho
	 */
	public class ParticleSystem extends Object3D
	{
		/**生成したパーティクルを配置するコンテナ*/
		public var container:Object3D;
		/**パーティクルオブジェクトリスト*/
		public var particleList:Vector.<Particle3D> = new Vector.<Particle3D>;
		/**エミッタが稼働しているか*/
		public var enabled:Boolean = true;
		/**パーティクルの幅*/
		public var particleWidth:Number = 10;
		/**パーティクルの高さ*/
		public var particleHeight:Number = 10;
		/**パーティクルマテリアル*/
		private var _material:Material;
		/**パーティクルの同時発生限界数（-1で無制限）*/
		public var limit:int = -1;
		
		private var particleCache:Vector.<Particle3D> = new Vector.<Particle3D>;
		private var _animator:ParticleAnimator;
		private var _emitter:ParticleEmitter;
		private var _wind:ParticleWind;
		private var _birthRate:Number = 1;
		private var totalTime:Number = 0;
		private var birthTime:Number = 1000;
		private var lastBirth:int;
		private var sprite:Sprite = new Sprite();
		private var materialID:int = 0;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function ParticleSystem(emitter:ParticleEmitter = null, animator:ParticleAnimator = null, wind:ParticleWind = null) 
		{
			super();
			if (emitter) this.emitter = emitter;
			if (animator) this.animator = animator;
			if (wind) this.wind = wind;
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
			birthTime = 1000 / _birthRate;
		}
		
		/**
		 * パーティクル用マテリアル
		 */
		public function get material():Material 
		{
			return _material;
		}
		
		public function set material(value:Material):void 
		{
			if (_material == value)
			{
				return;
			}
			_material = value;
			updateMaterial();
		}
		
		public function get wind():ParticleWind 
		{
			return _wind;
		}
		
		public function set wind(value:ParticleWind):void 
		{
			_wind = value;
		}
		
		public function updateMaterial():void 
		{
			materialID++;
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
		 * @param	animator
		 */
		public function setParticle(width:Number, height:Number, material:Material):void
		{
			particleWidth = width;
			particleHeight = height;
			this.material = material;
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
			update();
		}
		
		/**
		 * パーティクルを1個生成する
		 * @return
		 */
		public function emit():Particle3D
		{
			if (limit != -1 && particleList.length >= limit)
			{
				return null;
			}
			
			var particle:Particle3D;
			//もしキャッシュにパーティクルがあればそれを再利用する
			if (particleCache.length)
			{
				particle = particleCache.pop();
				///particle.width = particleWidth;
				///particle.height = particleHeight;
				//前回からマテリアルが変わっていれば貼り直す
				if (particle.materialID != materialID)
				{
					var nextMaterial:Material = _material.clone();
					particle.setParticleMaterial(nextMaterial);
				}
			}
			else
			{
				//キャッシュにない場合は新しく生成する
				var newMaterial:Material = (!_material)? null : _material.clone();
				particle = new Particle3D(particleWidth, particleHeight, newMaterial);
			}
			particle.materialID = materialID;
			particle.latestIndex = 0;
			particleList.push(particle);
			if (container)
			{
				container.addChild(particle);
			}
				
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
			while (particleList.length) 
			{
				var p:Particle3D = particleList.pop()
				p.remove();
				particleCache.push(p);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  更新
		//
		//--------------------------------------------------------------------------
		
		public function update():void
		{
			var step:int = 33;
			
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
			
			var n:int = particleList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var particle:Particle3D = particleList[i];
				//風
				if (_wind)
				{
					_wind.updateParticle(particle);
				}
				//重力、回転、アルファ変化
				animator.updateParticle(particle);
				
				if (particle.time >= particle.life)
				{
					var p:Particle3D = particleList.splice(i, 1)[0];
					particleCache.push(p);
					particle.remove();
					i--;
					n--;
					continue;
				}
				
				particle.time += step;
			}
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