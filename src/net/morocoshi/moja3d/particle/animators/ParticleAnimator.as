package net.morocoshi.moja3d.particle.animators 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.particle.cells.Particle3D;
	import net.morocoshi.moja3d.particle.ParticleSystem;
	
	/**
	 * パーティクルの動きを管理する基本クラス
	 * 
	 * @author tencho
	 */
	public class ParticleAnimator 
	{
		public var system:ParticleSystem;
		
		public var type:String;
		public var scaleMin:Number = 1;
		public var scaleMax:Number = 1;
		public var velocityMin:Vector3D = new Vector3D(0, 0, 0);
		public var velocityMax:Vector3D = new Vector3D(0, 0, 0);
		public var lifeMin:Number = 1000;
		public var lifeMax:Number = 1000;
		public var alphaKeyList:Vector.<AlphaKey> = new Vector.<AlphaKey>;
		public var rotationMin:Number = 0;
		public var rotationMax:Number = 0;
		public var spinSpeedMin:Number = 0;
		public var spinSpeedMax:Number = 0;
		public var scaleSpeedMin:Number = 0;
		public var scaleSpeedMax:Number = 0;
		public var gravity:Vector3D = new Vector3D(0, 0, 0);
		public var friction:Number = 1;
		
		/**アニメーター更新時にパーティクルの数だけ呼ばれる。引数はParticle3D。ここでパーティクルの動きを弄れる*/
		public var onUpdate:Function;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function ParticleAnimator() 
		{
			type = ParticleAnimatorType.BASIC;
		}
		
		//--------------------------------------------------------------------------
		//
		//  パーティクル生成時の処理
		//
		//--------------------------------------------------------------------------
		
		public function emitParticle(particle:Particle3D):void 
		{
			particle.initialScale = getEmitScale();
			particle.initialRotation = getEmitRotation();
			particle.velocity = getEmitVelocity();
			particle.spinSpeed = getEmitSpinSpeed();
			particle.scaleSpeed = getEmitScaleSpeed();
			particle.time = 0;
			particle.life = getEmitLife();
		}
		
		//--------------------------------------------------------------------------
		//
		//  パラメータ設定
		//
		//--------------------------------------------------------------------------
		
		public function setScale(min:Number, max:Number):void
		{
			scaleMin = min;
			scaleMax = max;
		}
		
		public function setLife(min:Number, max:Number):void 
		{
			lifeMin = min;
			lifeMax = max;
		}
		
		public function setRotation(min:Number, max:Number):void 
		{
			rotationMin = min;
			rotationMax = max;
		}
		
		public function setSpinSpeed(min:Number, max:Number):void 
		{
			spinSpeedMin = min;
			spinSpeedMax = max;
		}
		
		public function setScaleSpeed(min:Number, max:Number):void 
		{
			scaleSpeedMin = min;
			scaleSpeedMax = max;
		}
		
		public function removeAllAlphaKey():void
		{
			alphaKeyList.length = 0;
		}
		
		public function addAlphaKey(ratio:Number, value:Number, sort:Boolean):void
		{
			var key:AlphaKey = new AlphaKey(ratio, value);
			alphaKeyList.push(key);
			if (sort)
			{
				alphaKeyList.sort(keySort);
			}
		}
		
		private function keySort(a:AlphaKey, b:AlphaKey):int 
		{
			return int(a.ratio > b.ratio) - int(a.ratio < b.ratio);
		}
		
		//--------------------------------------------------------------------------
		//
		//  パーティクル生成時のパラメータ取得
		//
		//--------------------------------------------------------------------------
		
		/**
		 * パーティクル生成時の回転速度を取得
		 * @return
		 */
		public function getEmitSpinSpeed():Number 
		{
			return random(spinSpeedMin, spinSpeedMax);
		}
		
		public function getEmitScaleSpeed():Number 
		{
			return random(scaleSpeedMin, scaleSpeedMax);
		}
		
		public function getEmitRotation():Number 
		{
			return random(rotationMin, rotationMax);
		}
		
		/**
		 * パーティクル生成時の加速度を取得
		 * @return
		 */
		public function getEmitVelocity():Vector3D
		{
			var vx:Number = random(velocityMin.x, velocityMax.x);
			var vy:Number = random(velocityMin.y, velocityMax.y);
			var vz:Number = random(velocityMin.z, velocityMax.z);
			return new Vector3D(vx, vy, vz);
		}
		
		/**
		 * パーティクル生成時のライフを取得
		 * @return
		 */
		public function getEmitLife():Number
		{
			return random(lifeMin, lifeMax);
		}
		
		/**
		 * パーティクル生成時のスケールを取得
		 * @return
		 */
		public function getEmitScale():Number 
		{
			return random(scaleMin, scaleMax);
		}
		
		//--------------------------------------------------------------------------
		//
		//  時間経過によるパラメータ取得
		//
		//--------------------------------------------------------------------------
		
		public function getCurrentScale(particle:Particle3D):Number
		{
			var scale:Number = particle.initialScale + (particle.time / 1000) * particle.scaleSpeed;
			if (scale < 0) scale = 0;
			return scale;
		}
		
		public function getCurrentAlpha(particle:Particle3D):Number 
		{
			if (!alphaKeyList.length) return 1;
			if (alphaKeyList.length == 1)
			{
				return alphaKeyList[0].value;
			}
			
			var n:int = alphaKeyList.length;
			var alphaMin:AlphaKey = alphaKeyList[0];
			var alphaMax:AlphaKey = alphaKeyList[n - 1];
			
			var ratio:Number = particle.progress;
			if (ratio <= alphaMin.ratio) return alphaMin.value;
			if (ratio >= alphaMax.ratio) return alphaMax.value;
			
			var start:int = particle.latestIndex;
			for (var i:int = start; i < n - 1; i++) 
			{
				var key0:AlphaKey = alphaKeyList[i];
				var key1:AlphaKey = alphaKeyList[i + 1];
				if (ratio >= key0.ratio && ratio < key1.ratio)
				{
					particle.latestIndex = i;
					var per:Number = (ratio - key0.ratio) / (key1.ratio - key0.ratio);
					return (key1.value - key0.value) * per + key0.value;
				}
			}
			
			return alphaMax.value;// particle.initialAlpha * (1 - particle.progress);
		}
		
		public function getCurrentRotation(particle:Particle3D):Number 
		{
			return particle.initialRotation + (particle.time / 1000) * particle.spinSpeed;
		}
		
		//--------------------------------------------------------------------------
		//
		//  更新処理
		//
		//--------------------------------------------------------------------------
		
		public function updateParticle(particle:Particle3D):void 
		{
			particle.velocity.incrementBy(gravity);
			particle.velocity.x *= friction;
			particle.velocity.y *= friction;
			particle.velocity.z *= friction;
			particle.x += particle.velocity.x;
			particle.y += particle.velocity.y;
			particle.z += particle.velocity.z;
			particle.scaleX = particle.scaleY = particle.scaleZ = getCurrentScale(particle);
			particle.alpha = getCurrentAlpha(particle);
			//particle.rotation = getCurrentRotation(particle);
			
			if (onUpdate != null) onUpdate(particle);
		}
		
		public function parse(xml:XML):void
		{
			gravity.x = XMLUtil.getAttrNumber(xml.gravity, "x", 0);
			gravity.y = XMLUtil.getAttrNumber(xml.gravity, "y", 0);
			gravity.z = XMLUtil.getAttrNumber(xml.gravity, "z", 0);
			friction = XMLUtil.getNodeNumber(xml.friction, 1);
			velocityMin.x = XMLUtil.getAttrNumber(xml.velocityMin, "x", 0);
			velocityMin.y = XMLUtil.getAttrNumber(xml.velocityMin, "y", 0);
			velocityMin.z = XMLUtil.getAttrNumber(xml.velocityMin, "z", 0);
			velocityMax.x = XMLUtil.getAttrNumber(xml.velocityMax, "x", 0);
			velocityMax.y = XMLUtil.getAttrNumber(xml.velocityMax, "y", 0);
			velocityMax.z = XMLUtil.getAttrNumber(xml.velocityMax, "z", 0);
			scaleMin = XMLUtil.getAttrNumber(xml.scale, "min", 0);
			scaleMax = XMLUtil.getAttrNumber(xml.scale, "max", 0);
			rotationMin = XMLUtil.getAttrNumber(xml.rotation, "min", 0);
			rotationMax = XMLUtil.getAttrNumber(xml.rotation, "max", 0);
			lifeMin = XMLUtil.getAttrNumber(xml.life, "min", 0);
			lifeMax = XMLUtil.getAttrNumber(xml.life, "max", 0);
			spinSpeedMin = XMLUtil.getAttrNumber(xml.spinSpeed, "min", 0);
			spinSpeedMax = XMLUtil.getAttrNumber(xml.spinSpeed, "max", 0);
			scaleSpeedMin = XMLUtil.getAttrNumber(xml.scaleSpeed, "min", 0);
			scaleSpeedMax = XMLUtil.getAttrNumber(xml.scaleSpeed, "max", 0);
			
			removeAllAlphaKey();
			for each(var node:XML in xml.alpha.key) 
			{
				var ratio:Number = XMLUtil.getAttrNumber(node, "ratio", 0);
				var value:Number = XMLUtil.getAttrNumber(node, "value", 1);
				addAlphaKey(ratio, value, false);
			}
			alphaKeyList.sort(keySort);
		}
		
		public function toXML():XML
		{
			var xml:XML = <animator />;
			xml.type = type;
			xml.gravity.@x = gravity.x;
			xml.gravity.@y = gravity.y;
			xml.gravity.@z = gravity.z;
			xml.friction = friction;
			xml.velocityMin.@x = velocityMin.x;
			xml.velocityMin.@y = velocityMin.y;
			xml.velocityMin.@z = velocityMin.z;
			xml.velocityMax.@x = velocityMax.x;
			xml.velocityMax.@y = velocityMax.y;
			xml.velocityMax.@z = velocityMax.z;
			xml.scale.@min = scaleMin;
			xml.scale.@max = scaleMax;
			xml.rotation.@min = rotationMin;
			xml.rotation.@max = rotationMax;
			xml.life.@min = lifeMin;
			xml.life.@max = lifeMax;
			xml.spinSpeed.@min = spinSpeedMin;
			xml.spinSpeed.@max = spinSpeedMax;
			xml.scaleSpeed.@min = scaleSpeedMin;
			xml.scaleSpeed.@max = scaleSpeedMax;
			xml.appendChild(<alpha />);
			for (var i:int = 0; i < alphaKeyList.length; i++) 
			{
				var alphaKey:AlphaKey = alphaKeyList[i];
				var alphaNode:XML = <key />;
				alphaNode.@ratio = alphaKey.ratio;
				alphaNode.@value = alphaKey.value;
				xml.alpha.appendChild(alphaNode);
			}
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