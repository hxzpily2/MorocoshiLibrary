package net.morocoshi.moja3d.view 
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	import net.morocoshi.moja3d.resources.Resource;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ContextProxy 
	{
		private var uploadItem:Dictionary;
		public var context:Context3D;
		public var driver:DriverInfo;
		
		public function ContextProxy() 
		{
			uploadItem = new Dictionary();
		}
		
		public function reupload():void
		{
			for (var key:* in uploadItem) 
			{
				var item:Resource = uploadItem[key];
				item.dispose();
				item.upload(this);
			}
		}
		
		public function addUploadItem(resource:Resource):void 
		{
			uploadItem[resource] = resource;
		}
		
		public function removeUploadItem(resource:Resource):void
		{
			delete uploadItem[resource];
		}
		
	}

}