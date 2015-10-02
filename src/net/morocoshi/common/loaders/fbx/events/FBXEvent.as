package net.morocoshi.common.loaders.fbx.events 
{
	import flash.events.Event;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXScene;
	
	/**
	 * FBXParser用
	 * 
	 * @author tencho
	 */
	public class FBXEvent extends Event 
	{
		static public const COMPLETE_PARSE_NODE:String = "completeParseNode";
		static public const COMPLETE_PARSE_SCENE:String = "completeParseScene";
		
		public var scene:FBXScene;
		public var node:FBXNode;
		
		public function FBXEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new FBXEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FBXEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}