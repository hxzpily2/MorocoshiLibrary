package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.moja3d;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MaskItem 
	{
		public var mask:uint;
		private var _color:uint;
		private var _density:Number;
		moja3d var constant:AGALConstant;
		
		public function MaskItem() 
		{
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			
			updateColor();
		}
		
		moja3d function updateColor():void 
		{
			if (constant)
			{
				constant.setRGB(_color);
				constant.x *= _density;
				constant.y *= _density;
				constant.z *= _density;
			}
		}
		
		public function get density():Number 
		{
			return _density;
		}
		
		public function set density(value:Number):void 
		{
			_density = value;
			
			updateColor();
		}
	}

}