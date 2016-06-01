package net.morocoshi.moja3d.resources 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import net.morocoshi.common.loaders.tfp.TFPHolder;
	import net.morocoshi.common.loaders.tfp.TFPLoader;
	import net.morocoshi.common.loaders.tfp.events.TFPErrorEvent;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TextureResourceLoader extends EventDispatcher
	{
		private var context3D:ContextProxy;
		private var resourceList:Vector.<Resource>;
		private var basePath:String;
		private var asset:TFPHolder;
		
		public function TextureResourceLoader() 
		{
			resourceList = new Vector.<Resource>;
		}
		
		public function upload(basePath:String, context3D:ContextProxy, resources:Vector.<Resource>, cacheEnabled:Boolean):void
		{
			basePath = basePath.split("\\").join("/");
			if (basePath != "" && basePath.charAt(basePath.length - 1) != "/")
			{
				basePath += "/";
			}
			this.basePath = basePath;
			this.context3D = context3D;
			resourceList.length = 0;
			var pathList:Vector.<String> = new Vector.<String>;
			asset = new TFPHolder();
			var loader:TFPLoader = new TFPLoader(asset);
			loader.cacheEnabled = cacheEnabled;
			
			var n:int = resources.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:Resource = resources[i];
				var externalTexture:ExternalTextureResource = item as ExternalTextureResource;
				if (externalTexture == null) continue;
				
				resourceList.push(externalTexture);
				pathList.push(correntPath(externalTexture.path));
			}
			loader.addEventListener(ProgressEvent.PROGRESS, loader_progressHandler);
			loader.addEventListener(TFPErrorEvent.LOAD_ERROR, loader_errorHandler);
			loader.addEventListener(Event.COMPLETE, loader_completeHandler);
			loader.load(pathList);
		}
		
		private function loader_errorHandler(e:TFPErrorEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function loader_progressHandler(e:ProgressEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function loader_completeHandler(e:Event):void 
		{
			var n:int = resourceList.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:ExternalTextureResource = resourceList[i] as ExternalTextureResource;
				var ext:String = item.path.split(".").pop();
				if (ext == "atf")
				{
					var atf:ByteArray = asset.getByteArray(correntPath(item.path));
					if (atf == null) continue;
					
					item.setATFResource(atf);
				}
				else
				{
					var image:BitmapData = asset.getBitmapData(correntPath(item.path));
					if (image == null) continue;
					
					item.setBitmapResource(TextureUtil.correctSize(image), true);
				}
				item.upload(context3D);
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function correntPath(path:String):String 
		{
			return basePath + path;
		}
		
		private function complete():void 
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}

}