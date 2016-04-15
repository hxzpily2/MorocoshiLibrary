package net.morocoshi.moja3d.loader 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.view.ContextProxy;
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DLoader extends EventDispatcher
	{
		private var parsers:Object;
		private var loadCount:int;
		private var context:ContextProxy;
		
		public function M3DLoader() 
		{
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
			for (var key:String in parsers) 
			{
				loadCount++;
				var item:M3DLoadItem = getLoadItem(key);
				item.parser.addEventListener(Event.COMPLETE, completeHandler);
				item.parser.parse(item.data, item.container);
			}
		}
		
		private function completeHandler(e:Event):void 
		{
			var parser:M3DParser = e.currentTarget as M3DParser;
			parser.removeEventListener(Event.COMPLETE, completeHandler);
			if (context != null)
			{
				parser.upload(context, false);
			}
			
			loadCount--;
			if (loadCount > 0) return;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}