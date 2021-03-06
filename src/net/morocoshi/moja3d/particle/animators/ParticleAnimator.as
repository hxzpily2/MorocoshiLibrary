package net.morocoshi.moja3d.particle.animators 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.text.XMLUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.atlas.TextureAtlasItem;
	import net.morocoshi.moja3d.particle.ParticleEmitter;
	import net.morocoshi.moja3d.particle.cells.ParticleCell;
	import net.morocoshi.moja3d.resources.ImageTextureResource;
	import net.morocoshi.moja3d.resources.TextureAtlasResource;
	
	use namespace moja3d;
	
	/**
	 * パーティクルの動きを管理する基本クラス
	 * 
	 * @author tencho
	 */
	public class ParticleAnimator 
	{
		/***/
		public var type:String;
		/**最小初期スケール*/
		public var scaleMin:Number = 1;
		/**最大初期スケール*/
		public var scaleMax:Number = 1;
		/**最小寿命（秒）*/
		public var lifeMin:Number = 1;
		/**最大寿命（秒）*/
		public var lifeMax:Number = 1;
		/**最小初期角度（ラジアン）*/
		public var rotationMin:Number = 0;
		/**最大初期角度（ラジアン）*/
		public var rotationMax:Number = 0;
		/**最小回転速度（ラジアン）。パーティクルの角度が発生1秒後にこの数値分までオフセットされる*/
		public var spinSpeedMin:Number = 0;
		/**最大回転速度（ラジアン）。パーティクルの角度が発生1秒後にこの数値分までオフセットされる*/
		public var spinSpeedMax:Number = 0;
		/**最小スケーリング速度。パーティクルのスケールが発生1秒後にこの数値分までオフセットされる*/
		public var scaleSpeedMin:Number = 0;
		/**最大スケーリング速度。パーティクルのスケールが発生1秒後にこの数値分までオフセットされる*/
		public var scaleSpeedMax:Number = 0;
		/**空気抵抗係数。1で抵抗なし。0に近づくほど抵抗が強くなる。*/
		public var friction:Number = 1;
		/**初速ベクトル（速度のベクトルはxyz成分それぞれにおいてvelocityMin～velocityMaxの範囲でランダムに決定される）*/
		public var velocityMin:Vector3D = new Vector3D(0, 0, 0);
		/**初速ベクトル（速度のベクトルはxyz成分それぞれにおいてvelocityMin～velocityMaxの範囲でランダムに決定される）*/
		public var velocityMax:Vector3D = new Vector3D(0, 0, 0);
		/**重力加速度*/
		public var gravity:Vector3D = new Vector3D(0, 0, 0);
		/**アルファアニメーションをキーフレームで管理したもの。キーフレーム情報はaddAlphaKey()でも追加できます。キーフレーム数が0だとアルファは常に1になります。*/
		public var alphaKeyList:Vector.<AlphaKey> = new Vector.<AlphaKey>;
		
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
		
		moja3d function emitParticle(particle:ParticleCell, emitter:ParticleEmitter):void 
		{
			particle.initialScale = getEmitScale();
			particle.initialRotation = getEmitRotation();
			var velocity:Vector3D = getEmitVelocity(emitter);
			particle.vx = emitter.xAxis.x * velocity.x + emitter.yAxis.x * velocity.y + emitter.zAxis.x * velocity.z;
			particle.vy = emitter.xAxis.y * velocity.x + emitter.yAxis.y * velocity.y + emitter.zAxis.y * velocity.z;
			particle.vz = emitter.xAxis.z * velocity.x + emitter.yAxis.z * velocity.y + emitter.zAxis.z * velocity.z;
			particle.spinSpeed = getEmitSpinSpeed();
			particle.scaleSpeed = getEmitScaleSpeed();
			particle.time = 0;
			particle.life = getEmitLife();
		}
		
		/**
		 * パーティクル位置の更新
		 * @param	particle
		 */
		moja3d function updateParticle(particle:ParticleCell, atlas:TextureAtlasResource):void 
		{
			var t1:Number = particle.time;
			var t2:Number = particle.prevTime;
			var tt1:Number = t1 - t2;
			var tt2:Number = (t1 * t1) - (t2 * t2);
			var f:Number = (friction == 1)? 1 : Math.pow(friction, t1);
			particle.x += (particle.vx * tt1 + gravity.x * tt2) * f;
			particle.y += (particle.vy * tt1 + gravity.y * tt2) * f;
			particle.z += (particle.vz * tt1 + gravity.z * tt2) * f;
			if (atlas && atlas.numFrames > 0)
			{
				if (particle.frame != particle.lastFrame)
				{
					particle.lastFrame = particle.frame;
					var item:TextureAtlasItem = atlas.items[particle.frame % atlas.numFrames];
					var img:ImageTextureResource = item.resource as ImageTextureResource;
					if (img)
					{
						var w:int = img.width;
						var h:int = img.height;
						particle.u1 = item.x / w;
						particle.v1 = item.y / h;
						particle.u0 = (item.x + item.width) / w;
						particle.v0 = (item.y + item.height) / h;
					}
				}
			}
			else
			{
				particle.u0 = particle.v0 = 1;
				particle.u1 = particle.v1 = 0;
			}
			var scale:Number = (particle.initialScale + (particle.time) * particle.scaleSpeed) * 0.5;
			if (scale < 0) scale = 0;
			particle.width = particle.initialWidth * scale;
			particle.height = particle.initialHeight * scale;
			particle.rotation = particle.initialRotation + (particle.time) * particle.spinSpeed;
			particle.alpha = getCurrentAlpha(particle);
		}
		
		//--------------------------------------------------------------------------
		//
		//  パラメータ設定
		//
		//--------------------------------------------------------------------------
		
		/**
		 * パーティクルの初期スケールの最小値と最大値を設定する
		 * @param	min
		 * @param	max	省略するとminと同じになる
		 */
		public function setScale(min:Number, max:Number = NaN):void
		{
			scaleMin = min;
			scaleMax = isNaN(max)? min : max;
		}
		
		/**
		 * パーティクルの寿命（秒）の最小値と最大値を設定する
		 * @param	min
		 * @param	max	省略するとminと同じになる
		 */
		public function setLife(min:Number, max:Number = NaN):void 
		{
			lifeMin = min;
			lifeMax = isNaN(max)? min : max;
		}
		
		/**
		 * パーティクルの初期回転角（ラジアン）の最小値と最大値を設定する
		 * @param	min
		 * @param	max	省略するとminと同じになる
		 */
		public function setRotation(min:Number, max:Number = NaN):void 
		{
			rotationMin = min;
			rotationMax = isNaN(max)? min : max;
		}
		
		/**
		 * 回転速度（ラジアン）の最小値と最大値を設定する。パーティクルの角度が発生1秒後にこの数値分までオフセットされる
		 * @param	min
		 * @param	max	省略するとminと同じになる
		 */
		public function setSpinSpeed(min:Number, max:Number = NaN):void 
		{
			spinSpeedMin = min;
			spinSpeedMax = isNaN(max)? min : max;
		}
		
		/**
		 * スケーリング速度の最小値と最大値を設定する。パーティクルのスケールが発生1秒後にこの数値分までオフセットされる
		 * @param	min
		 * @param	max	省略するとminと同じになる
		 */
		public function setScaleSpeed(min:Number, max:Number = NaN):void 
		{
			scaleSpeedMin = min;
			scaleSpeedMax = isNaN(max)? min : max;
		}
		
		/**
		 * アルファ変化アニメーション用キーフレームを追加する
		 * @param	ratio	キーフレームの時間。パーティクル発生時(0)～パーティクル消滅時(1)の範囲で設定
		 * @param	value	アルファ値
		 */
		public function addAlphaKey(ratio:Number, value:Number):void
		{
			var key:AlphaKey = new AlphaKey(ratio, value);
			alphaKeyList.push(key);
			alphaKeyList.sort(keySort);
		}
		
		/**
		 * 全てのアルファアニメーション用キーフレームを削除する
		 */
		public function removeAllAlphaKey():void
		{
			alphaKeyList.length = 0;
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
		moja3d function getEmitSpinSpeed():Number 
		{
			return random(spinSpeedMin, spinSpeedMax);
		}
		
		moja3d function getEmitScaleSpeed():Number 
		{
			return random(scaleSpeedMin, scaleSpeedMax);
		}
		
		moja3d function getEmitRotation():Number 
		{
			return random(rotationMin, rotationMax);
		}
		
		/**
		 * パーティクル生成時の加速度を取得
		 * @return
		 */
		protected function getEmitVelocity(emitter:ParticleEmitter):Vector3D
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
		moja3d function getEmitLife():Number
		{
			return random(lifeMin, lifeMax);
		}
		
		/**
		 * パーティクル生成時のスケールを取得
		 * @return
		 */
		moja3d function getEmitScale():Number 
		{
			return random(scaleMin, scaleMax);
		}
		
		//--------------------------------------------------------------------------
		//
		//  時間経過によるパラメータ取得
		//
		//--------------------------------------------------------------------------
		
		moja3d function getCurrentScale(particle:ParticleCell):Number
		{
			var scale:Number = particle.initialScale + (particle.time) * particle.scaleSpeed;
			if (scale < 0) scale = 0;
			return scale;
		}
		
		moja3d function getCurrentAlpha(particle:ParticleCell):Number 
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
		
		moja3d function getCurrentRotation(particle:ParticleCell):Number 
		{
			return particle.initialRotation + (particle.time) * particle.spinSpeed;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function clone():ParticleAnimator 
		{
			var result:ParticleAnimator = new ParticleAnimator();
			cloneProperties(result);
			return result;
		}
		
		public function cloneProperties(target:ParticleAnimator):void
		{
			target.type = type;
			target.scaleMin = scaleMin;
			target.scaleMax = scaleMax;
			target.lifeMin = lifeMin;
			target.lifeMax = lifeMax;
			target.rotationMin = rotationMin;
			target.rotationMax = rotationMax;
			target.spinSpeedMin = spinSpeedMin;
			target.spinSpeedMax = spinSpeedMax;
			target.scaleSpeedMin = scaleSpeedMin;
			target.scaleSpeedMax = scaleSpeedMax;
			target.friction = friction;
			target.velocityMin = velocityMin.clone();
			target.velocityMax = velocityMax.clone();
			target.gravity = gravity.clone();
			target.alphaKeyList = new Vector.<AlphaKey>;
			var n:int = alphaKeyList.length;
			for (var i:int = 0; i < n; i++) 
			{
				target.alphaKeyList.push(alphaKeyList[i].clone());
			}
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
				addAlphaKey(ratio, value);
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