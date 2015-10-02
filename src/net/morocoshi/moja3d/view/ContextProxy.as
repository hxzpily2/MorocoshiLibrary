package net.morocoshi.moja3d.view 
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ContextProxy 
	{
		public var context3D:Context3D;
		public var stage3D:Stage3D;
		
		public function ContextProxy(stage3D:Stage3D) 
		{
			this.stage3D = stage3D;
		}
		
		public function request(renderMode:String = "auto", profile:String = "baseline"):void
		{
			if (stage3D.context3D == null)
			{
				stage3D.addEventListener(IOErrorEvent.IO_ERROR, stage3D_errorHandler);
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, stage3D_contextCreateHandler);
				stage3D.requestContext3D(renderMode, profile);
			}
			else
			{
				stage3D_contextCreateHandler(null);
			}
		}
		
		private function stage3D_errorHandler(e:IOErrorEvent):void 
		{
			trace(e.text);
		}
		
		private function stage3D_contextCreateHandler(e:Event):void 
		{
			
		}
		
	}

}