package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3D;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Context3Dにuploadするリソース
	 * 
	 * @author tencho
	 */
	public class Resource extends EventDispatcher
	{
		public var name:String;
		public var isUploaded:Boolean;
		public var isReady:Boolean;
		
		public function Resource() 
		{
			isUploaded = false;
			isReady = false;
		}
		
		public function clone():Resource
		{
			var resource:Resource = new Resource();
			return resource;
		}
		
		public function upload(context3D:Context3D, async:Boolean, complete:Function = null):void
		{
			isUploaded = true;
		}
		
		public function dispose():void 
		{
			isUploaded = false;
		}
		
		override public function toString():String 
		{
			return "[" + getQualifiedClassName(this).split("::")[1] + " " + name + "," + isUploaded + "]";
		}
		
	}

}