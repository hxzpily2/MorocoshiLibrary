package net.morocoshi.common.collision.plane
{
	import net.morocoshi.common.collision.plane.collisions.BaseCollision;
	import net.morocoshi.common.collision.plane.units.CollisionUnit;
	
	/**
	 * 衝突点の情報をまとめたクラス
	 * 1回の処理で同じ壁に複数回衝突した時の処理を軽くする為にも使う
	 * 
	 * @author	tencho
	 */
	public class CollideData 
	{
		static public const LINE:int = 0;
		static public const CIRCLE:int = 1;
		
		/**この衝突点を保持しているユニット*/
		public var unit:CollisionUnit;
		/**計算上の衝突点X*/
		public var x:Number;
		/**計算上の衝突点Y*/
		public var y:Number;
		/**衝突点までの距離*/
		public var distance:Number;
		/**衝突点の形状*/
		public var type:int;
		/**衝突点の形状が円だった時の中心点X*/
		public var centerX:Number;
		/**衝突点の形状が円だった時の中心点Y*/
		public var centerY:Number;
		/**衝突対象コリジョン*/
		public var collision:BaseCollision;
		/**衝突点から伸びる法線X*/
		public var normalX:Number;
		/**衝突点から伸びる法線Y*/
		public var normalY:Number;
		/**壁ずり方向X*/
		public var vx:Number;
		/**壁ずり方向Y*/
		public var vy:Number;
		/**見た目上の衝突点X*/
		public var collideX:Number;
		/**見た目上の衝突点Y*/
		public var collideY:Number;
		
		public function CollideData(unit:CollisionUnit, collision:BaseCollision, type:int, x:Number, y:Number, distance:Number) 
		{
			this.unit = unit;
			this.collision = collision;
			this.type = type;
			this.x = x;
			this.y = y;
			this.distance = distance;
		}
		
		/**
		 *　見た目上の衝突点を計算する
		 */
		public function calculateCollidePoint():void
		{
			var dd:Number = normalX * normalX + normalY * normalY;
			if (dd != 1)
			{
				var d:Number = Math.sqrt(dd);
				normalX /= d;
				normalY /= d;
			}
			collideX = x - normalX * unit.radius;
			collideY = y - normalY * unit.radius;
		}
		
	}

}