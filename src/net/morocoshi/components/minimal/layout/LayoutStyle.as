package net.morocoshi.components.minimal.layout 
{
	/**
	 * フレームレイアウト用スタイル
	 * 
	 * @author tencho
	 */
	public class LayoutStyle 
	{
		public var separateSize:Number = 4;
		public var separateColor:uint = 0xFAFAFA;
		public var borderSize:Number = 1;
		public var borderColor:uint = 0xA0A0A0;
		public var resizingColor:uint = 0x000000;
		public var resizingAlpha:Number = 0.8;
		
		/**
		 * コンストラクタ
		 */
		public function LayoutStyle() 
		{
		}
		
		public function get size():Number
		{
			return borderSize * 2 + separateSize;
		}
		
	}

}