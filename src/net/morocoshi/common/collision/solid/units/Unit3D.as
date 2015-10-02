package net.morocoshi.common.collision.solid.units 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.collision.solid.bounds.AABB3D;
	import net.morocoshi.common.collision.solid.Collision3DWorld;
	import net.morocoshi.common.collision.solid.results.Collision3DResult;
	import net.morocoshi.common.math.geom.Vector3DUtil;
	import net.morocoshi.common.partitioning.cell2.Cell2DItem;
	
	/**
	 * 移動コリジョンの基本
	 * 
	 * @author tencho
	 */
	public class Unit3D 
	{
		/**AABB*/
		public var aabb:AABB3D;
		/**衝突計算に使用*/
		public var remainTime:Number = 1;
		/**ユニット自身の移動量*/
		public var displace:Vector3D = new Vector3D();
		/**壁ずり割合*/
		public var slide:Number = 1;
		/***/
		public var frictionAngleMin:Number = 0;
		/***/
		public var frictionAngleMax:Number = 0;
		/**初期移動量*/
		private var initDisplace:Vector3D = new Vector3D();
		/**過剰移動量（内部計算用）*/
		private var overDisplace:Vector3D = new Vector3D();
		/**現在位置*/
		public var position:Vector3D = new Vector3D();
		/**衝突点（面）の情報*/
		public var collisionList:Vector.<Collision3DResult>;
		/**交差判定後の最終的な壁ずり加速度*/
		public var finalVelocity:Vector3D = new Vector3D();
		
		public var cellItem:Cell2DItem;
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function Unit3D() 
		{
			aabb = new AABB3D();
			cellItem = new Cell2DItem();
			cellItem.data = this;
			collisionList = new Vector.<Collision3DResult>;
		}
		
		/**
		 * Collision3DWorldから呼ばれる。ユニットに加わる力の更新など。
		 * @param	collision3DWorld
		 */
		public function update(world:Collision3DWorld):void 
		{
		}
		
		/**
		 * Collision3DWorldから呼ばれる。ワールド内コリジョンとの衝突判定。
		 * @param	world
		 */
		public function collide(world:Collision3DWorld):void
		{
			world.collideUnit(this);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 最初に1回だけ実行しておく
		 */
		public function ready():void 
		{
			remainTime = 1;
			initDisplace.copyFrom(displace);
			collisionList.length = 0;
		}
		
		/**
		 * 加速度による移動量も含めたAABBを計算する
		 */
		public function updateAABB():void 
		{
			//cellItem.resize(aabb.xMin, aabb.yMin, aabb.xMax - aabb.xMin, aabb.yMax - aabb.yMin);
		}
		
		/**
		 * 最後に衝突したコリジョン情報を取得する
		 */
		public function getFinalCollision():Collision3DResult 
		{
			var n:int = collisionList.length;
			return n? collisionList[n - 1] : null;
		}
		
		/**
		 * 全ての交差判定を終わらせる時
		 */
		public function finish():void 
		{
			position.incrementBy(displace);
			finalVelocity.copyFrom(displace);
			displace.setTo(0, 0, 0);
		}
		
		/**
		 * 強制停止
		 */
		public function stop():void 
		{
			finalVelocity.setTo(0, 0, 0);
			displace.setTo(0, 0, 0);
		}
		
		private var smoothMode:Boolean = false;
		
		/**
		 * 三角ポリとの交差結果をユニット座標と加速度に反映させる
		 * @param	collision	
		 */
		public function applyCollision(collision:Collision3DResult):void 
		{
			if (!smoothMode && collision.thrust)
			{
				position.incrementBy(collision.thrustVector);
			}
			
			//衝突位置まで動かす
			if (collision.time)
			{
				position.x += displace.x * collision.time;
				position.y += displace.y * collision.time;
				position.z += displace.z * collision.time;
			}
			
			if (slide == 0)
			{
				if (collision.thrust && smoothMode) setThrust(collision);
				else displace.setTo(0, 0, 0);
				return;
			}
			
			var angleRate:Number = getAngleRate(collision);
			if (angleRate <= 0)
			{
				if (collision.thrust && smoothMode) setThrust(collision);
				else displace.setTo(0, 0, 0);
				return;
			}
			//過剰加速度の割合（衝突の度に減っていく）
			remainTime *= (1 - collision.time) * slide * angleRate;
			if (isNaN(remainTime))
			{
				throw new Error([collision.time, slide, angleRate].join("@"));
			}
			//動くポリゴン側から接触してきて、なおかつ同じ方向に進む場合
			if (collision.reverse)
			{
				if (collision.thrust && smoothMode) addThrust(collision);
				return;
			}
			
			//壁ずりベクトルを求めて、衝突後の加速度にする（※要最適化）
			
			//衝突時の壁ずり加速度
			overDisplace.x = initDisplace.x * remainTime;
			overDisplace.y = initDisplace.y * remainTime;
			overDisplace.z = initDisplace.z * remainTime;
			var l:Number = -overDisplace.dotProduct(collision.normal);
			displace.x = overDisplace.x + collision.normal.x * l;
			displace.y = overDisplace.y + collision.normal.y * l;
			displace.z = overDisplace.z + collision.normal.z * l;
			if (isNaN(displace.x))
			{
				throw new Error([l, remainTime, initDisplace, collision.normal, overDisplace].join("@"));
			}
			
			if (collision.thrust && smoothMode) addThrust(collision);
		}
		
		/**
		 * 無限平面との交差結果をユニット座標と加速度に反映させる
		 * @param	collision
		 */
		public function applyInfinitePlane(collision:Collision3DResult):void 
		{
			var finalCollision:Collision3DResult = getFinalCollision();
			
			if (!finalCollision)
			{
				//ここにはこないはず
				throw new Error("★おかしい:直前に交差判定してない？");
				return;
			}
			
			if (!smoothMode && collision.thrust)
			{
				position.incrementBy(collision.thrustVector);
			}
			
			if (!slide)
			{
				if (collision.thrust && smoothMode) setThrust(collision);
				else displace.setTo(0, 0, 0);
				return;
			}
			
			//衝突位置まで動かす
			if (collision.time)
			{
				position.x += displace.x * collision.time;
				position.y += displace.y * collision.time;
				position.z += displace.z * collision.time;
			}
			
			var angleRate:Number = getAngleRate(collision);
			if (angleRate <= 0)
			{
				if (collision.thrust && smoothMode) setThrust(collision);
				else displace.setTo(0, 0, 0);
				return;
			}
			
			//過剰加速度の割合（衝突の度に減っていく）
			remainTime *= (1 - collision.time) * slide * angleRate;
			
			if (collision.reverse)
			{
				if (collision.thrust && smoothMode) addThrust(collision);
				return;
			}
			
			//2つの無限平面に挟まれながらずれる向き
			var slideVector:Vector3D = collision.normal.crossProduct(finalCollision.normal);
			slideVector.normalize();
			
			//衝突時の壁ずり加速度
			overDisplace.x = initDisplace.x * remainTime;
			overDisplace.y = initDisplace.y * remainTime;
			overDisplace.z = initDisplace.z * remainTime;
			
			var l:Number = overDisplace.dotProduct(slideVector);
			displace.x = slideVector.x * l;
			displace.y = slideVector.y * l;
			displace.z = slideVector.z * l;
			
			if (isNaN(displace.x))
			{
				throw new Error([l, remainTime, initDisplace, collision.normal, overDisplace].join("@"));
			}
			
			if (collision.thrust && smoothMode) addThrust(collision);
		}
		
		private function addThrust(collision:Collision3DResult):void
		{
			///trace("★加算★", collision.thrustVector);
			displace.x += collision.thrustVector.x;
			displace.y += collision.thrustVector.y;
			displace.z += collision.thrustVector.z;
			frictionAngleMin = 0;
			frictionAngleMax = 0;
		}
		
		private function setThrust(collision:Collision3DResult):void 
		{
			///trace("★設定★", collision.thrustVector);
			displace.x = collision.thrustVector.x;
			displace.y = collision.thrustVector.y;
			displace.z = collision.thrustVector.z;
			frictionAngleMin = 0;
			frictionAngleMax = 0;
		}
		
		private function getAngleRate(collision:Collision3DResult):Number
		{
			var angleRate:Number;
			if (frictionAngleMin == 0 && frictionAngleMax == 0)
			{
				angleRate = 1;
			}
			else
			{
				var angle:Number = 180 - Vector3DUtil.getAngle(initDisplace, collision.normal) * 180 / Math.PI;
				if (isNaN(angle)) angle = 0;
				angleRate = (angle - frictionAngleMin) / (frictionAngleMax - frictionAngleMin);
				if (angleRate > 1) angleRate = 1;
			}
			return angleRate;
		}
		
		/**
		 * Unit3D同士を衝突判定させる
		 * @param	unit
		 * @param	count
		 */
		public function hit(unit:Unit3D, count:int):void 
		{
		}
		
	}

}