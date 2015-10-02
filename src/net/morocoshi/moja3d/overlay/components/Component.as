package net.morocoshi.moja3d.overlay.components
{
	import net.morocoshi.moja3d.overlay.objects.Object2D;
	public class Component extends Object2D
	{
		public var extra:*;
		public var data:*;
		
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		public function Component()
		{
			super();
		}
		
		public function getForm():Form
		{
			var current:Object2D = parent;
			while(current)
			{
				if(current is Form)
				{
					return current as Form;
				}
				current = current.parent;
			}
			return null;
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function set width(value:Number):void 
		{
			_width = value;
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function set height(value:Number):void 
		{
			_height = value;
		}
	}
}