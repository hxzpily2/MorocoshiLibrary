package net.morocoshi.moja3d.resources 
{
	import flash.display.BitmapData;
	import net.morocoshi.common.graphics.BitmapUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class TextureUtil 
	{
		
		public function TextureUtil() 
		{
		}
		
		/**
		 * BitmapDataのサイズがもし2の累乗でなければリサイズして返す。
		 * @param	image
		 * @return
		 */
		static public function correctSize(image:BitmapData):BitmapData
		{
			if (checkPow2(image.width, image.height) == false)
			{
				image = BitmapUtil.resize(image, toPow2(image.width), toPow2(image.height), true);
			}
			return image;
		}
		
		/**
		 * 縦横のサイズが両方2の累乗であればtrueを返す。
		 * @param	width
		 * @param	height
		 * @return
		 */
		static public function checkPow2(width:int, height:int):Boolean
		{
			var pw:Boolean = (width & (width - 1)) == 0;
			var ph:Boolean = (height & (height - 1)) == 0;
			return (pw && ph);
		}
		
		/**
		 * numberの値より大きく最も近い2の累乗値にする。
		 * @param	number
		 * @return
		 */
		static public function toPow2(number:int):int 
		{
			var size:int = 1;
			while (size < number)
			{
				size *= 2;
			}
			return size;
		}
		
	}

}