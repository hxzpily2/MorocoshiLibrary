package net.morocoshi.common.debug 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TraceBox 
	{
		private var data:Object;
		private var padding:Number;
		public var sprite:Sprite;
		public var bg:Sprite;
		public var dataText:TextField;
		
		static private var _instance:TraceBox = new TraceBox();
		private var logText:String;
		
		public function TraceBox() 
		{
			padding = 5;
			data = { };
			logText = "";
			
			sprite = new Sprite();
			bg = new Sprite();
			bg.graphics.beginFill(0x000000, 1);
			bg.graphics.drawRect(0, 0, 100, 100);
			bg.graphics.endFill();
			bg.alpha = 0.6;
			
			dataText = new TextField();
			dataText.defaultTextFormat = new TextFormat("Arial", 14, 0xffffff);
			dataText.defaultTextFormat.leading = 10;
			dataText.autoSize = TextFieldAutoSize.LEFT;
			dataText.selectable = false;
			dataText.x = padding;
			dataText.y = padding;
			
			sprite.mouseChildren = false;
			sprite.mouseEnabled = false;
			//bg.mouseEnabled = true;
			//bg.mouseChildren = false;
			
			sprite.addChild(bg);
			sprite.addChild(dataText);
			
			setSize(350, 400);
			
			sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		static public function get instance():TraceBox
		{
			return _instance;
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			var str:String = "";
			for (var k:String in data) 
			{
				str += k + " = " + data[k] + "\n";
			}
			dataText.text = str;
		}
		
		public function setData(name:String, value:*):void
		{
			data[name] = value;
		}
		
		public function clearLog():void
		{
			logText = "";
		}
		
		public function log(...args):void
		{
			logText += args.join(", ") + "\n";
			setData("LOG", logText)
		}
		
		public function setSize(w:Number, h:Number):void
		{
			bg.width = w;
			bg.height = h;
			dataText.width = w - padding;
		}
		
		static public function traceObject(data:Object):void 
		{
			trace(JSON.stringify(data, null, "\t"));
		}
		
	}

}