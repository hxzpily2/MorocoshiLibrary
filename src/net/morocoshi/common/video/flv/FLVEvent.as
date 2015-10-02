package net.morocoshi.common.video.flv
{
	import flash.events.Event;
	
	/**
	 * ...
	 * 
	 * @author	unknown
	 */
	public class FLVEvent extends Event
	{
		static public const LOAD_PROGRESS:String = "onLoadProgress";
		static public const LOAD_COMPLETE:String = "onLoadComplete";
		static public const PLAY_COMPLETE:String = "onPlayComplete";
		static public const ERROR:String = "onError";
		static public const METADATA:String = "onMetaData";
		static public const PLAYSTOP:String = "onPlayStop";
		static public const SEEK:String = "onSeek";
		
		public var progress:Number = 0;
		public var bytesLoaded:int = 0;
		public var bytesTotal:int = 0;
		public var data:FLVData;
		public var time:Number;
		
		public function FLVEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new FLVEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String
		{ 
			return formatToString("FLVEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}