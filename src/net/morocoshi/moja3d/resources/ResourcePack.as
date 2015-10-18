package net.morocoshi.moja3d.resources 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.utils.ByteArray;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.resources.Resource;
	
	/**
	 * マテリアル画像をまとめたもの
	 * 
	 * @author tencho
	 */
	public class ResourcePack 
	{
		private var imageFile:Object;
		private var imagePath:Object;
		
		public function ResourcePack() 
		{
			imageFile = { };
			imagePath = { };
		}
		
		/**
		 * 登録した全ての画像を完全に破棄する。登録情報だけではなく画像データ自体がメモリから破棄される。
		 */
		public function dispose():void
		{
			for each(var ba:ByteArray in imageFile)
			{
				ba.clear();
			}
			for each(var bd:BitmapData in imagePath) 
			{
				bd.dispose();
			}
			imageFile = { };
			imagePath = { };
		}
		
		/**
		 * 画像の登録情報のみを破棄する。画像の元データ自体は破棄されない。
		 */
		public function clear():void
		{
			imageFile = { };
			imagePath = { };
		}
		
		/**
		 * 画像リソースをパスで登録する
		 * @param	path	マテリアルのフルパスもしくはファイル名のみ。拡張子は無視されるので書かなくてもいい。
		 * @param	image	登録する画像データ（BitmapData、Bitmap、ATFデータ）
		 * @param	resize	BitmapDataのサイズがもし2の累乗でなければリサイズする
		 */
		public function register(path:String, image:*, resize:Boolean = false):void
		{
			if (image is Bitmap) image = Bitmap(image).bitmapData;
			
			if (image is BitmapData && resize)
			{
				image = TextureUtil.correctSize(image);
			}
			
			imageFile[toFileID(path)] = image;
			imagePath[toPathID(path)] = image;
		}
		
		/**
		 * 拡張子を抜いたフォルダ+ファイル名を取得
		 * @param	path
		 * @return
		 */
		private function toPathID(path:String):String 
		{
			var list:Array = path.split("\\").join("/").split("/");
			
			var name:String = list.pop();
			if (name.indexOf(".") != -1)
			{
				var items:Array = name.split(".");
				items.pop();
				name = items.join(".");
			}
			
			var folder:String = list.join("/");
			if (folder != "") folder += "/";
			
			return folder + name;
		}
		
		/**
		 * 拡張子を抜いたフォルダ無しファイル名を取得
		 * @param	path
		 * @return
		 */
		private function toFileID(path:String):String 
		{
			var list:Array = path.split("\\").join("/").split("/");
			
			var name:String = list.pop();
			if (name.indexOf(".") != -1)
			{
				var items:Array = name.split(".");
				items.pop();
				name = items.join(".");
			}
			
			return name;
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
				
				var pathID:String = toPathID(externalTexture.path);
				var fileID:String = toFileID(externalTexture.path);
				var data:* = imagePath[pathID] || imageFile[fileID];
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