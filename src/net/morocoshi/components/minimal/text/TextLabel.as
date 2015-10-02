package net.morocoshi.components.minimal.text 
{
	import com.bit101.components.Label;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TextLabel extends Label 
	{
		
		public function TextLabel(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, text:String="") 
		{
			super(parent, xpos, ypos, text);
			
		}
		
		override public function get height():Number 
		{
			return textField.textHeight;
		}
		
	}

}