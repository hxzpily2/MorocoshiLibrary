package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3D;
	import flash.events.EventDispatcher;
	import net.morocoshi.moja3d.events.Event3D;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * リソースを一括でuploadする
	 * 
	 * @author tencho
	 */
	public class ResourceUploader extends EventDispatcher
	{
		private var count:int;
		private var total:int;
		private var completeCallback:Function;
		
		public function ResourceUploader() 
		{
		}
		
		public function upload(context3D:ContextProxy, resources:Vector.<Resource>, async:Boolean, complete:Function = null):void
		{
			completeCallback = complete;
			
			count = 0;
			var n:int = total = resources.length;
			for (var i:int = 0; i < n; i++)
			{
				var resource:Resource = resources[i];
				try
				{
					resource.upload(context3D, async, completeHandler);
				}
				catch (e:Error)
				{
					completeHandler(resource);
				}
			}
		}
		
		private function completeHandler(resource:Resource):void 
		{
			count++;
			if (count < total) return;
			
			if (completeCallback != null)
			{
				completeCallback();
			}
			completeCallback = null;
			dispatchEvent(new Event3D(Event3D.RESOURCE_UPLOADED));
		}
		
	}

}