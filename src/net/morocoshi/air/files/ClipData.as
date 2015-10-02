package net.morocoshi.air.files
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	
	/**
	 * クリップボードの内容
	 * 
	 * @author	tencho
	 */
	public class ClipData
	{	
		/**テキスト*/
		public var text:String = null;
		/**ブラウザからドラッグした要素のHTMLタグ*/
		public var html:String = null;
		/**ブラウザからのURL（1つ）またはショートカットファイルのURL（複数）*/
		public var urlList:Array = [];
		/**ショートカットファイル以外のファイル*/
		public var fileList:Vector.<File> = new Vector.<File>();
		/**ブラウザからのHTML要素に含まれる画像ファイルパス*/
		public var imagePath:String = null;
		/**リッチテキスト？*/
		public var rtf:String = null;
		/**AIR間のドラッグのみ対応？*/
		public var bitmapData:BitmapData = null;
		
		public function ClipData()
		{
		}
		
	}
	
}