package net.morocoshi.common.math.random 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Random 
	{
		
		public function Random() 
		{
		}
		
		static public function number(min:Number, max:Number):Number
		{
			return Math.random() * (max - min) + min;
		}
		
		static public function integer(min:int, max:int):int
		{
			return int(Math.random() * (max - min + 1)) + min;
		}
		
		static public function pick(list:*):* 
		{
			return list[int(Math.random() * list.length)];
		}
		
	}

}