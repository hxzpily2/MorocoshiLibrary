package net.morocoshi.moja3d.loader 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.materials.ParserMaterial;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.resources.ResourceUploader;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * 複数のM3Dデータをまとめてパースします
	 * 
	 * @author tencho
	 */
	public class M3DLoader extends EventDispatcher
	{
		private var sprite:Sprite;
		private var parsers:Object;
		private var loadCount:int;
		private var maxCount:int;
		private var context:ContextProxy;
		private var queue:Vector.<M3DLoadItem>;
		private var resources:Vector.<Resource>;
		private var uploader:ResourceUploader;
		private var isLoading:Boolean;
		
		public function M3DLoader() 
		{
			isLoading = false;
			sprite = new Sprite();
			queue = new Vector.<M3DLoadItem>;
			resources = new Vector.<Resource>;
			parsers = { };
		}
		
		/**
		 * パース予定のM3Dデータを登録する
		 * @param	id			あとでM3Dデータにアクセスする為の識別ID
		 * @param	data		M3Dバイトデータ
		 * @param	includeTo	必要ならパース時にこのコンテナ内にオブジェクトを配置する
		 * @return
		 */
		public function register(id:String, data:ByteArray, includeTo:Object3D = null):M3DLoadItem
		{
			parsers[id] = new M3DLoadItem(id, data, includeTo);
			return parsers[id];
		}
		
		public function getLoadItem(id:String):M3DLoadItem
		{
			return parsers[id];
		}
		
		public function getParser(id:String):M3DParser
		{
			return parsers[id].parser;
		}
		
		/**
		 * 登録したM3Dモデルを一括でパースする
		 * @param	context	ContextProxyを設定すると、パース直後にリソースがuploadされる
		 */
		public function parse(context:ContextProxy):void
		{
			this.context = context;
			
			if (isLoading) return;
			
			isLoading = true;
			loadCount = 0;
			queue.length = 0;
			for (var key:String in parsers) 
			{
				loadCount++;
				queue.push(getLoadItem(key));
			}
			maxCount = loadCount;
			
			sprite.addEventListener(Event.ENTER_FRAME, tick);
			tick(null);
		}
		
		/**
		 * 複数IDに一致するモデルのParserMaterialをまとめて取得する
		 * @param	ids
		 * @return
		 */
		public function getMaterials(ids:Array):Vector.<ParserMaterial> 
		{
			var result:Vector.<ParserMaterial> = new Vector.<ParserMaterial>;
			for each(var id:String in ids)
			{
				result = result.concat(getParser(id).materials);
			}
			return result;
		}
		
		private function tick(e:Event):void 
		{
			var time:int = getTimer();
			do
			{
				if (queue.length == 0)
				{
					sprite.removeEventListener(Event.ENTER_FRAME, tick);
					return;
				}
				
				var item:M3DLoadItem = queue.pop();
				item.parser.addEventListener(Event.COMPLETE, completeHandler);
				item.parser.parse(item.data, item.includeTo);
				item.data.clear();
				item.data = null;
			}
			while (getTimer() - time <= 33);
			
			var scale:Number = context? 0.5 : 1;
			var progress:Number = (maxCount - queue.length) / maxCount * scale;
			notifyProgress(progress);
		}
		
		private function completeHandler(e:Event):void 
		{
			var parser:M3DParser = e.currentTarget as M3DParser;
			parser.removeEventListener(Event.COMPLETE, completeHandler);
			VectorUtil.attachListDiff(resources, parser.getResources());
			
			loadCount--;
			if (loadCount > 0) return;
			
			if (context != null && resources.length > 0)
			{
				uploader = new ResourceUploader();
				uploader.addEventListener(ProgressEvent.PROGRESS, uploader_progressHandler);
				uploader.addEventListener(Event.COMPLETE, uploader_completeHandler);
				uploader.upload(context, resources, true);
			}
			else
			{
				isLoading = false;
				notifyProgress(1);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function uploader_completeHandler(e:Event):void 
		{
			uploader.removeEventListener(ProgressEvent.PROGRESS, uploader_progressHandler);
			uploader.removeEventListener(Event.COMPLETE, uploader_completeHandler);
			uploader = null;
			
			isLoading = false;
			notifyProgress(1);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function uploader_progressHandler(e:ProgressEvent):void 
		{
			notifyProgress(e.bytesLoaded * 0.5 + 0.5);
		}
		
		private function notifyProgress(value:Number):void
		{
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, value, 1));
		}
		
	}

}