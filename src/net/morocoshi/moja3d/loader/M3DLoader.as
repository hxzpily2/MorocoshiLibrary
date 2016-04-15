package net.morocoshi.moja3d.loader 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.view.ContextProxy;
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DLoader extends EventDispatcher
	{
		private var sprite:Sprite;
		private var parsers:Object;
		private var loadCount:int;
		private var context:ContextProxy;
		private var queue:Vector.<M3DLoadItem>;
		private var maxCount:int;
		
		public function M3DLoader() 
		{
			sprite = new Sprite();
			queue = new Vector.<M3DLoadItem>;
			parsers = { };
		}
		
		public function getLoadItem(id:String):M3DLoadItem
		{
			return parsers[id];
		}
		
		public function getParser(id:String):M3DParser
		{
			return parsers[id].parser;
		}
		
		public function register(id:String, data:ByteArray, container:Object3D = null):M3DLoadItem
		{
			parsers[id] = new M3DLoadItem(id, data, container);
			return parsers[id];
		}
		
		public function parse(context:ContextProxy):void
		{
			this.context = context;
			
			loadCount = 0;
			queue.length = 0;
			for (var key:String in parsers) 
			{
				loadCount++;
				queue.push(getLoadItem(key));
			}
			maxCount = loadCount;
			
			sprite.addEventListener(Event.ENTER_FRAME, tick);
		}
		
		private function tick(e:Event):void 
		{
			var time:int = getTimer();
			do
			{
				if (queue.length == 0)
				{
					sprite.removeEventListener(Event.ENTER_FRAME, tick);
					return;
				}
				
				var item:M3DLoadItem = queue.pop();
				item.parser.addEventListener(Event.COMPLETE, completeHandler);
				item.parser.parse(item.data, item.container);
			}
			while (getTimer() - time <= 33);
			
			trace((maxCount - queue.length) / maxCount);
		}
		
		private function completeHandler(e:Event):void 
		{
			var parser:M3DParser = e.currentTarget as M3DParser;
			parser.removeEventListener(Event.COMPLETE, completeHandler);
			if (context != null)
			{
				parser.upload(context, true);
			}
			
			loadCount--;
			if (loadCount > 0) return;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}