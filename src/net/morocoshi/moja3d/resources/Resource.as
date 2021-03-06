package net.morocoshi.moja3d.resources 
{
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * Context3Dにuploadするリソース
	 * 
	 * @author tencho
	 */
	public class Resource extends EventDispatcher
	{
		static public var uploadEnabled:Boolean = true;
		
		private var context3D:ContextProxy;
		public var name:String;
		public var isUploaded:Boolean;
		public var isReady:Boolean;
		/**Object3D.dispose()を実行した時などの一括disposeの対象にするかどうか。*/
		public var autoDispose:Boolean;
		
		public function Resource() 
		{
			isUploaded = false;
			isReady = false;
			autoDispose = true;
		}
		
		public function cloneProperties(target:Resource):void 
		{
			target.name = name;
			target.autoDispose = autoDispose;
		}
		
		public function clone():Resource
		{
			var resource:Resource = new Resource();
			cloneProperties(resource);
			return resource;
		}
		
		/**
		 * 
		 * @param	context3D
		 * @return
		 */
		public function upload(context3D:ContextProxy):Boolean
		{
			if (uploadEnabled == false || isUploaded == true) return false;
			
			dispose();
			isUploaded = true;
			this.context3D = context3D;
			context3D.addUploadItem(this);
			
			return true;
		}
		
		/**
		 * Context3Dにuploadしたリソースをdispose()しつつ、関連する画像データなども破棄する。画像リソースは二度とuploadできなくなるので注意。
		 */
		public function clear():void 
		{
			dispose();
		}
		
		/**
		 * Context3Dにuploadしたリソースをdispose()する。関連する画像データなどは破棄しない。
		 */
		public function dispose():void 
		{
			isUploaded = false;
			if (context3D)
			{
				context3D.removeUploadItem(this);
			}
		}
		
		override public function toString():String 
		{
			return "[" + getQualifiedClassName(this).split("::")[1] + " " + name + "," + isUploaded + "]";
		}
		
	}

}