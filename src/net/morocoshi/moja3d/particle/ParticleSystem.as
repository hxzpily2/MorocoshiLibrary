package net.morocoshi.moja3d.particle 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.timers.Stopwatch;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Particle3D;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	import net.morocoshi.moja3d.particle.cells.ParticleData;
	import net.morocoshi.moja3d.particle.wind.ParticleWind;
	
	use namespace moja3d;
	
	/**
	 * パーティクルを管理するクラス。パーティクルが表示されるコンテナの役割も果たす。
	 * 
	 * @author tencho
	 */
	public class ParticleSystem extends Particle3D
	{
		/**パーティクルの同時発生限界数（-1で無制限）*/
		public var limit:int = -1;
		
		public var emitters:Vector.<ParticleEmitter> = new Vector.<ParticleEmitter>;
		public var wind:ParticleWind;
		private var _enabled:Boolean;
		
		private var sprite:Sprite = new Sprite();
		private var prevTime:Number = -1;
		public var timer:Stopwatch;
		
		/**
		 * 
		 * @param	material
		 */
		public function ParticleSystem(material:Material = null) 
		{
			super(material);
			timer = new Stopwatch();
			timer.start();
			_enabled = true;
		}
		
		public function addEmiter(emitter:ParticleEmitter):void
		{
			emitters.push(emitter);
		}
		
		public function removeEmiter(emitter:ParticleEmitter):void
		{
			VectorUtil.deleteItem(emitters, emitter);
		}
		
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
		
		/**
		 * パーティクルを全削除して全てのエミッタを停止する。
		 */
		public function disposeParticles():void
		{
			for each (var emitter:ParticleEmitter in emitters) 
			{
				emitter.enabled = false;
			}
			stopAutoUpdate();
			removeAllParticles();
			particleCache.length = 0;
		}
		
		/**
		 * 全てのパーティクルを削除する
		 */
		public function removeAllParticles():void 
		{
			while (particleList.root) 
			{
				var item:ParticleData = particleList.root;
				particleList.remove(item);
				particleCache.add(item);
			}
		}
		
		/**
		 * パーティクルを1個生成する
		 * @return
		 */
		private function emit(time:Number):ParticleCell
		{
			if (limit != -1 && particleList.length >= limit)
			{
				return null;
			}
			
			var particle:ParticleCell;
			if (particleCache.root)
			{
				particle = particleCache.root as ParticleCell;
				particleCache.remove(particleCache.root);
			}
			else
			{
				particle = new ParticleCell();
			}
			particle.latestIndex = 0;
			particle.prevTime = 0;
			particle.initTime = time;
			particleList.add(particle);
			
			return particle;
		}
		
		override public function update():void
		{
			var time:Number = timer.time / 1000;
			if (prevTime == -1)
			{
				prevTime = time;
			}
			
			var i:int;
			var n:int;
			var particle:ParticleCell;
			
			n = emitters.length;
			for (i = 0; i < n; i++) 
			{
				var emitter:ParticleEmitter = emitters[i];
				var birth:int = time / emitter.birthTime;
				
				if (emitter.enabled == false)
				{
					emitter.lastBirth = birth;
					continue;
				}
				
				if (birth > emitter.lastBirth)
				{
					emitter.updateMatrix(this);
					var length:int = birth - emitter.lastBirth;
					for (var j:int = 0; j < length; j++) 
					{
						var per:Number = (j + 1) / length;
						particle = emit(time * (1 - per) + prevTime * per);
						if (particle == null) continue;
						
						particle.initialWidth = emitter.particleWidth;
						particle.initialHeight = emitter.particleHeight;
						emitter._range.setRandomPosition(particle, emitter);
						particle.animator = emitter._animator;
						particle.wind = emitter._wind || wind;
						emitter._animator.emitParticle(particle, emitter);
					}
					emitter.lastBirth = birth;
				}
			}
			
			particle = particleList.root as ParticleCell;
			while (particle) 
			{
				particle.time = time - particle.initTime;
				particle.animator.updateParticle(particle);
				if (particle.wind) particle.wind.updateParticle(particle);
				
				if (particle.time >= particle.life)
				{
					var next:ParticleCell = particle.next as ParticleCell;
					particleList.remove(particle);
					particleCache.add(particle);
					particle = next;
					continue;
				}
				
				particle.prevTime = particle.time;
				particle = particle.next as ParticleCell;
			}
			
			super.update();
			prevTime = time;
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			update();
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
		/*
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
			
			var emitterClass:Class = ParticleRangeType.getClass(xml.emitter[0].type);
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
		*/
		
	}

}