package net.morocoshi.moja3d.resources 
{
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * リソースを一括でuploadする
	 * 
	 * @author tencho
	 */
	public class ResourceUploader extends EventDispatcher
	{
		private var sprite:Sprite;
		private var total:int;
		private var queue:Vector.<Resource>;
		private var context:ContextProxy;
		
		public function ResourceUploader() 
		{
			sprite = new Sprite();
			queue = new Vector.<Resource>;
		}
		
		/**
		 * 
		 * @param	context3D
		 * @param	resources
		 * @param	async
		 */
		public function upload(context:ContextProxy, resources:Vector.<Resource>, async:Boolean):void
		{
			if (async)
			{
				this.context = context;
				queue = resources.concat();
				total = queue.length;
				sprite.addEventListener(Event.ENTER_FRAME, tick);
				tick(null);
				return;
			}
			
			var n:int = resources.length;
			for (var i:int = 0; i < n; i++)
			{
				resources[i].upload(context);
			}
		}
		
		private function tick(e:Event):void 
		{
			var time:int = getTimer();
			do
			{
				if (queue.length == 0)
				{
					sprite.removeEventListener(Event.ENTER_FRAME, tick);
					dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 1, 1));
					dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
				
				queue.pop().upload(context);
			}
			while (getTimer() - time < 33);
			
			var progress:Number = (total - queue.length) / total;
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, progress, 1));
		}
		
	}

}