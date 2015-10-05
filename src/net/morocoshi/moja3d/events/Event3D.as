package net.morocoshi.moja3d.events 
{
	import flash.events.Event;
	
	/**
	 * Moja3Dイベント
	 * 
	 * @author tencho
	 */
	public class Event3D extends Event 
	{
		/**レンダリング直前に呼ばれる*/
		static public const PRE_RENDER:String = "preRender";
		/**レンダリング直後に呼ばれる*/
		static public const POST_RENDER:String = "postRender";
		/**リソースの種類が確定した時（ATFの種類など）*/
		static public const RESOURCE_PARSED:String = "resourceParsed";
		/**リソースの一括アップロードの成功時*/
		static public const RESOURCE_UPLOADED:String = "resourceUploaded";
		
		/**レンダリング中のContext3D.clear()直後に呼ばれる。主にStarlingを最背面に描画したい時に使う。*/
		static public const CONTEXT_POST_CLEAR:String = "contextPostClear";
		/**レンダリング中のContext3D.present()直前に呼ばれる。主にStarlingを最前面に描画したい時に使う。*/
		static public const CONTEXT_PRE_PRESENT:String = "contextPrePresent";
		
		public function Event3D(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{ 
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event 
		{ 
			return new Event3D(type, bubbles, cancelable);
		}
		
		public override function toString():String 
		{ 
			return formatToString("Event3D", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
	
}