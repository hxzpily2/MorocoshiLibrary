package net.morocoshi.moja3d.resources 
{
	import flash.geom.Vector3D;
	
	/**
	 * ラインの頂点
	 * 
	 * @author tencho
	 */
	public class LinePoint 
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var r:Number;
		public var g:Number;
		public var b:Number;
		private var _color:uint;
		public var alpha:Number;
		
		/**
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	color
		 * @param	alpha
		 */
		public function LinePoint(x:Number, y:Number, z:Number, color:uint = 0xffffff, alpha:Number = 1) 
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.color = color;
			this.alpha = alpha;
		}
		
		public function getVector3D():Vector3D 
		{
			return new Vector3D(x, y, z);
		}
		
		public function setVector3D(v:Vector3D):void 
		{
			x = v.x;
			y = v.y;
			z = v.z;
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			r = (_color >> 16 & 0xff) / 0xff;
			g = (_color >> 8 & 0xff) / 0xff;
			b = (_color & 0xff) / 0xff;
		}
		
	}

}