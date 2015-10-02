package net.morocoshi.components.minimal.buttons 
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class AlignButton extends PushButton 
	{
		private var _align:String;
		
		public function AlignButton(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "", defaultHandler:Function = null) 
		{
			super(parent, xpos, ypos, label, defaultHandler);
			_align = TextFormatAlign.CENTER;
		}
		
		override public function draw():void 
		{
			super.draw();
			var l:Label = getChildAt(2) as Label;
			if (_align == TextFormatAlign.LEFT) l.x = 4;
			if (_align == TextFormatAlign.RIGHT) l.x = _width - l.width - 4;
		}
		
		public function get align():String 
		{
			return _align;
		}
		
		public function set align(value:String):void 
		{
			_align = value;
			draw();
		}
		
	}

}