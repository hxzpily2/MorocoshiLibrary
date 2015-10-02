package net.morocoshi.components.minimal.style 
{
	import com.bit101.components.Style;
	
	/**
	 * カラー設定
	 * 
	 * @author tencho
	 */
	public class Coloration 
	{
		static public const STYLE_LIGHT:int = 0;
		static public const STYLE_DARK:int = 1;
		
		static public var WINDOW_BACKGROUND:uint = 0xffffff;
		static public var SEPARATOR_COLOR:uint = 0xFAFAFA;
		static public var SEPARATOR_SHADOW:uint = 0xA0A0A0;
		static public var SEPARATOR_RESIZE:uint = 0x000000;
		static public var TAB_BORDER:uint = 0x808080;
		static public var TAB_ACTIVATE:uint = 0xF0F0F0;
		static public var TAB_DEACTIVATE:uint = 0xA0A0A0;
		static public var TAB_LABEL:uint = 0x222222;
		static public var TAB_BACKGROUND_ENABLED:Boolean = true;
		static public var TAB_BACKGROUND_TOP:uint = 0x555555;
		static public var TAB_BACKGROUND_BOTTOM:uint = 0x333333;
		
		public function Coloration() 
		{
		}
		
		static public function setStyle(style:int = 0):void
		{
			Style.fontName = "Arial";
			Style.fontSize = 12;
			Style.embedFonts = false;
			switch (style)
			{
				case STYLE_LIGHT:
					Style.INPUT_TEXT = 0xFFFFFF;
					Style.LABEL_TEXT = 0x000000;
					Style.BACKGROUND = 0x444444;
					WINDOW_BACKGROUND = 0xf0f0f0;
					break;
				case STYLE_DARK:
					Style.INPUT_TEXT = 0xFFFFFF;
					Style.LABEL_TEXT = 0xf0f0f0;
					Style.BACKGROUND = 0x222222;
					Style.BUTTON_FACE = 0x78825D;
					Style.BUTTON_DOWN = 0x5F6748;
					Style.DROPSHADOW = 0x282B1B;
					Style.PANEL = 0x282B1B;
					WINDOW_BACKGROUND = 0x5F6748;
					SEPARATOR_COLOR = 0x78825D;
					SEPARATOR_SHADOW = 0x282B1B;
					SEPARATOR_RESIZE = 0x81A8CF;
					break;
			}
			
		}
		
	}

}