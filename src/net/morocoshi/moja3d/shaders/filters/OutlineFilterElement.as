package net.morocoshi.moja3d.shaders.filters 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class OutlineFilterElement 
	{
		public var mask:uint;
		public var color:uint;
		public var alpha:Number;
		public var id:String;
		public var constant:AGALConstant;
		
		public function OutlineFilterElement(mask:uint, color:uint, alpha:Number) 
		{
			this.color = color;
			this.alpha = alpha;
			this.mask = mask;
		}
		
		public function getKey():String
		{
			return mask + "," + color + "," + alpha;
		}
		
	}

}