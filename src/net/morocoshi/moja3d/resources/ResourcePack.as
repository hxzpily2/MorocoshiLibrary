package net.morocoshi.moja3d.resources 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.utils.ByteArray;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.resources.Resource;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ResourcePack 
	{
		public var atf:Object;
		public var bitmap:Object;
		
		public function ResourcePack() 
		{
			atf = { };
			bitmap = { };
		}
		
		public function dispose():void
		{
			for each(var ba:ByteArray in atf)
			{
				ba.clear();
			}
			for each(var bd:BitmapData in bitmap) 
			{
				bd.dispose();
			}
			bitmap = { };
			atf = { };
		}
		
		public function registerATF(path:String, data:ByteArray):void
		{
			var id:String = toFileID(path);
			if (atf[id]) return;
			
			atf[id] = data;
		}
		
		public function registerBitmapData(path:String, image:BitmapData, resize:Boolean):void
		{
			var id:String = toFileID(path);
			if (bitmap[id]) return;
			
			if (resize)
			{
				image = TextureUtil.correctSize(image);
			}
			bitmap[id] = image;
		}
		
		/**
		 * 拡張子を抜いたファイル名を取得
		 * @param	path
		 * @return
		 */
		private function toFileID(path:String):String 
		{
			if (path.indexOf(".") == -1) return path;
			
			var items:Array = path.split(".");
			items.pop();
			return items.join(".");
		}
		
		/**
		 * 各種リソースにこのリソースパック内のファイルIDが一致するデータを渡す。
		 * @param	resources	Resourceの配列もしくはResource単体
		 * @param	upload	アップロードしたい場合はtrue。falseにした場合以降の引数は省略可能。
		 * @param	context3D
		 * @param	async
		 * @param	complete
		 */
		public function attachTo(resources:*, upload:Boolean, context3D:Context3D = null, async:Boolean = false, complete:Function = null):void 
		{
			if (resources is Resource) resources = [resources];
			var n:int = resources.length;
			for (var i:int = 0; i < n; i++)
			{
				var item:Resource = resources[i];
				var externalTexture:ExternalTextureResource = item as ExternalTextureResource;
				if (externalTexture == null) continue;
				
				var id:String = toFileID(externalTexture.path);
				var data:* = atf[id] || bitmap[id];
				if (data is BitmapData)
				{
					externalTexture.setBitmapResource(data, true);
				}
				if (data is ByteArray)
				{
					externalTexture.setATFResource(data);
				}
				if (upload)
				{
					externalTexture.upload(context3D, async, complete);
				}
			}
		}
		
	}

}