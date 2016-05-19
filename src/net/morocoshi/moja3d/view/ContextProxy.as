package net.morocoshi.moja3d.view 
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	import net.morocoshi.moja3d.moja3d;
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
			var resources:Array = [];
			for (var key:* in uploadItem) 
			{
				resources.push(uploadItem[key]);
			}
			var item:Resource;
			for each(item in resources)
			{
				item.dispose();
				item.upload(this);
			}
			item = null;
			resources = null;
		}
		
		moja3d function addUploadItem(resource:Resource):void 
		{
			uploadItem[resource] = resource;
		}
		
		moja3d function removeUploadItem(resource:Resource):void
		{
			delete uploadItem[resource];
		}
		
	}

}