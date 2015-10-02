package net.morocoshi.common.collision.solid.units 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.collision.solid.Collision3DWorld;
	import net.morocoshi.common.collision.solid.results.Collision3DResult;
	import net.morocoshi.common.collision.solid.units.SphereUnit3D;
	import net.morocoshi.common.math.geom.Vector3DUtil;
	import net.morocoshi.common.math.transform.AngleUtil;
	
	/**
	 * 球形移動コリジョンに重力と水平方向の移動を加えたもの。
	 * キャラクターの移動に特化した壁ずり処理をするため水平と垂直で壁ずり割合が違う。
	 * 
	 * @author tencho
	 */
	public class CharacterUnit3D extends SphereUnit3D
	{
		/**重力の大きさ*/
		public var gravity:Vector3D;
		/**水平方向の加速度*/
		public var hVelocity:Vector3D;
		/**垂直方向の加速度*/
		public var gravityVelocity:Vector3D;
		/**空気抵抗*/
		public var airFriction:Vector3D;
		/**交差判定直前の位置。壁にぶつかった時の加速度を調整するための。*/
		private var prevPosition:Vector3D;
		/**ジャンプさせるか*/
		private var jumpOrder:Boolean;
		/**ジャンプ速度*/
		private var jumpVector:Vector3D;
		/**接地すると数値が一定量まで増え、毎ステップ減算される。設置後一定時間はジャンプできるようにするため。*/
		private var touchGroundCount:int;
		private var hDisplace:Vector3D;
		private var vDisplace:Vector3D;
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function CharacterUnit3D() 
		{
			super();
			
			touchGroundCount = 0;
			hDisplace = new Vector3D();
			vDisplace = new Vector3D();
			hVelocity = new Vector3D();
			airFriction = new Vector3D(0.9, 0.9, 0.99);
			prevPosition = new Vector3D();
			jumpVector = new Vector3D();
			gravityVelocity = new Vector3D();
			gravity = new Vector3D(0, 0, -2);
		}
		
		//--------------------------------------------------------------------------
		//
		//  ユニット操作
		//
		//--------------------------------------------------------------------------
		
		public function addVelocityXYZ(x:Number, y:Number, z:Number):void 
		{
			hVelocity.x += x;
			hVelocity.y += y;
			hVelocity.z += z;
			//trace(x, y, z, hVelocity.length);
		}
		
		public function addVelocity(value:Vector3D):void 
		{
			hVelocity.incrementBy(value);
		}
		
		public function jump(x:Number, y:Number, z:Number):void 
		{
			if (touchGroundCount < 5) return;
			jumpOrder = true;
			if (Math.max(jumpVector.x) < x) jumpVector.x = x;
			if (Math.max(jumpVector.y) < y) jumpVector.y = y;
			if (Math.max(jumpVector.z) < z) jumpVector.z = z;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 毎フレーム更新
		 */
		override public function update(world:Collision3DWorld):void 
		{
			//重力
			gravityVelocity.incrementBy(gravity);
			
			//ジャンプ処理
			if (jumpOrder && touchGroundCount > 0)
			{
				gravityVelocity.copyFrom(jumpVector);
				jumpVector.setTo(0, 0, 0);
				touchGroundCount = 0;
			}
			jumpOrder = false;
			if (touchGroundCount > 0)
			{
				touchGroundCount--;
			}
			
			//水平に減速
			hVelocity.x *= airFriction.x;
			hVelocity.y *= airFriction.y;
			hVelocity.z *= airFriction.z;
			
			hDisplace.incrementBy(hVelocity);
			vDisplace.incrementBy(gravityVelocity);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 衝突判定時
		 * @param	world
		 */
		override public function collide(world:Collision3DWorld):void 
		{
			//水平方向にユニットを加速
			displace.incrementBy(hDisplace);
			hDisplace.setTo(0, 0, 0);
			frictionAngleMin = 0;
			frictionAngleMax = 0;
			super.collide(world);
			
			if (collisionList.length)
			{
				//衝突していたら次の移動量を制限する
				limitVerocity(hVelocity, position.subtract(prevPosition));
			}
			prevPosition.copyFrom(position);
			
			//重力は別処理
			displace.incrementBy(vDisplace);
			vDisplace.setTo(0, 0, 0);
			frictionAngleMin = 50;
			frictionAngleMax = 70;
			super.collide(world);
			
			if (collisionList.length)
			{
				//接地確認
				var minAngle:Number = Number.MAX_VALUE;
				for each (var col:Collision3DResult in collisionList) 
				{
					var angle:Number = Vector3DUtil.getAngleUnit(col.normal, Vector3D.Z_AXIS);
					if (angle < minAngle) minAngle = angle;
				}
				//接地判定
				if (minAngle < AngleUtil.TO_RADIAN * 45)
				{
					touchGroundCount = 6;
				}
				//衝突していたら次の移動量を制限する
				limitVerocity(gravityVelocity, position.subtract(prevPosition));
			}
			prevPosition.copyFrom(position);
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * vectorの長さをdiffで制限する
		 * @param	vector
		 * @param	diff
		 */
		private function limitVerocity(vector:Vector3D, diff:Vector3D):void 
		{
			var rawLength:Number = vector.length;
			vector.normalize();
			var length:Number = vector.dotProduct(diff);
			if (length < 0) length = 0;
			if (rawLength > length) rawLength = length;
			
			vector.scaleBy(rawLength);
		}
		
	}

}