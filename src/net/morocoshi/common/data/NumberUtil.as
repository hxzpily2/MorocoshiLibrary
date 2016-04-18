package net.morocoshi.common.data 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class NumberUtil 
	{
		
		static public function getRatio(min:Number, max:Number, position:Number):Number
		{
			return (position - min) / (max - min);
		}
		
		static public function getPosition(min:Number, max:Number, ratio:Number):Number
		{
			return min + (max - min) * ratio;
		}
		
	}

}