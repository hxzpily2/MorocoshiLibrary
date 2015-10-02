package net.morocoshi.common.loaders.asset
{
	import flash.events.Event;
	
	/**
	 * DataLoaderクラスのイベント
	 * @author	unknown
	 */
	public class AssetLoaderEvent extends Event
	{
		public var loader:AssetLoader;
		public var progress:Number = 0;
		public var datas:Vector.<AssetItem>;
		public var errorCount:int = 0;
		public var loadedCount:int = 0;
		public var totalCount:int = 0;
		public var successCount:int = 0;
		public var isSuccess:Boolean = false;
		public var text:String = "";
		
		static public const COMPLETE:String = "complete";
		static public const ERROR:String = "error";
		static public const PROGRESS:String = "progress";
		
		public function AssetLoaderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event
		{ 
			return new AssetLoaderEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String
		{ 
			return formatToString("DataLoadEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}