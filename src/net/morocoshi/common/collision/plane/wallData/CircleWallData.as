package net.morocoshi.common.collision.plane.wallData
{
	
	/**
	 * 円形の壁。
	 * 実装コストが高い場合は、このクラスの作成はペンディングする
	 * 
	 * @author	tencho
	 */
	public class CircleWallData implements IWallData
	{
		private var _type:int = WallType.CIRCLE;
		private var _x:Number;
		private var _y:Number;
		private var _radius:Number;
		
		/**
		 * コンストラクタ
		 * @param x:Number 中心点のX座標
		 * @param y:Number 中心点のY座標
		 * @param radius:Number 円の半径
		 */
		public function CircleWallData(x:Number, y:Number, radius:Number)
		{
			_x = x;
			_y = y;
			_radius = radius;
		}
		
		public function get type():int 
		{
			return _type;
		}
		
		/**
		 * 中心点のX座標
		 */
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
		}
		
		/**
		 * 中心点のY座標
		 */
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
		}
		
		/**
		 * 円の半径
		 */
		public function get radius():Number 
		{
			return _radius;
		}
		
		public function set radius(value:Number):void 
		{
			_radius = value;
		}
	}
}
