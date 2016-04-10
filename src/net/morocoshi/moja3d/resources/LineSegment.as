package net.morocoshi.moja3d.resources 
{
	
	/**
	 * LineGeometryがもつ折れ線セグメント
	 * 
	 * @author tencho
	 */
	public class LineSegment 
	{
		public var thickness:Number;
		public var points:Vector.<LinePoint>;
		
		public function LineSegment(thickness:Number = 1) 
		{
			this.thickness = thickness;
			points = new Vector.<LinePoint>;
		}
		
		/**
		 * 頂点を追加する
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	color
		 * @param	alpha
		 * @return
		 */
		public function addPoint(x:Number, y:Number, z:Number, color:uint = 0xffffff, alpha:Number = 1):LinePoint 
		{
			var p:LinePoint = new LinePoint(x, y, z, color, alpha);
			points.push(p);
			return p;
		}
		
		/**
		 * 1番最初に追加したLinePointの参照を最後に追加することでパスを閉じる
		 */
		public function close():void 
		{
			if (points.length == 0) return;
			points.push(points[0]);
		}
		
		/**
		 * 追加済みの全頂点の色を一括設定する
		 * @param	value
		 */
		public function setColor(value:uint):void
		{
			for each(var p:LinePoint in points)
			{
				p.color = value;
			}
		}
		
		/**
		 * 追加済みの全頂点のアルファを一括設定する
		 * @param	value
		 */
		public function setAlpha(value:Number):void
		{
			for each(var p:LinePoint in points)
			{
				p.alpha = value;
			}
		}
		
	}

}