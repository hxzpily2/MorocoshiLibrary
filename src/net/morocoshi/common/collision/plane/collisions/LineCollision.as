package net.morocoshi.common.collision.plane.collisions
{
	import flash.geom.Point;
	
	/**
	 * 直線・線分コリジョン
	 * 
	 * @author	tencho
	 */
	public class LineCollision extends BaseCollision
	{
		
		/**始点*/
		public var origin:Point = new Point();
		/**終点*/
		public var end:Point = new Point();
		/**衝突判定する面*/
		public var surface:int;
		/**線分に垂直な正規化された法線ベクトル*/
		public var normal:Point = new Point();
		/**始点から終点に向かう正規化されたベクトル*/
		public var vector:Point = new Point();
		/**視点位置の円の判定が有効か（複数の線の先端が同一座標だった場合の処理の簡略化に使用）*/
		public var originKey:int;
		/**終点位置の円の判定が有効か（複数の線の先端が同一座標だった場合の処理の簡略化に使用）*/
		public var endKey:int;
		
		public function LineCollision(x1:Number, y1:Number, x2:Number, y2:Number, surface:int)
		{
			super();
			_type = CollisionType.LINE;
			origin.x = x1;
			origin.y = y1;
			end.x = x2;
			end.y = y2;
			treeData.setRect(Math.min(x1, x2), Math.min(y1, y2), Math.abs(x1 - x2), Math.abs(y1 - y2));
			this.surface = surface;
			updateRect();
		}
		
		private function updateRect():void 
		{
			//領域計算
			_rect.x = origin.x < end.x ? origin.x : end.x;
			_rect.y = origin.y < end.y ? origin.y : end.y;
			_rect.width = origin.x - end.x;
			_rect.height = origin.y - end.y;
			if (_rect.width < 0) _rect.width = -_rect.width;
			if (_rect.height < 0) _rect.height = -_rect.height;
			
			treeData.setRect(_rect.x, _rect.y, _rect.width, _rect.height);
			
			//法線計算
			normal.x = end.y - origin.y;
			normal.y = origin.x - end.x;
			normal.normalize(1);
			vector.x = end.x - origin.x;
			vector.y = end.y - origin.y;
			vector.normalize(1);
		}
		
	}

}