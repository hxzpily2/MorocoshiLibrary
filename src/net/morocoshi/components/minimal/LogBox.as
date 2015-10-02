package net.morocoshi.components.minimal
{
	import com.bit101.components.TextArea;
	import flash.display.DisplayObjectContainer;
	import net.morocoshi.timers.FrameTimer;
	
	/**
	 * ログを表示するテキストエリア
	 * 
	 * @author tencho
	 */
	public class LogBox extends TextArea
	{
		
		public function LogBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, text:String = "")
		{
			super(parent, xpos, ypos, text);
		}
		
		public function log(... args):void
		{
			var str:String = args.join(",");
			text += str + "\n";
			FrameTimer.setTimer(1, timesUp);
		}
		
		public function clear():void 
		{
			text = "";
		}
		
		private function timesUp():void 
		{
			textField.scrollV = textField.maxScrollV;
		}
	
	}

}