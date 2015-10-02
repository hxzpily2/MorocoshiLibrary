package net.morocoshi.common.loaders.tfp 
{
	/**
	 * どの拡張子をどのファイルタイプとして扱うかを管理するクラス
	 * 
	 * @author tencho
	 */
	public class TFPExtention 
	{
		/**TFP拡張子*/
		public var tfp:String = "tfp";
		
		/**画像拡張子リスト*/
		public var image:Array = ["png", "jpg", "gif"];
		/**サウンド拡張子リスト*/
		public var sound:Array = ["mp3"];
		/**XML拡張子リスト*/
		public var xml:Array = ["xml", "dae"];
		/**テキスト拡張子リスト*/
		public var text:Array = ["txt"];
		/**ビデオ拡張子リスト（現在未対応）*/
		private var video:Array = [""];
		/**SWF拡張子リスト（現在未対応）*/
		private var swf:Array = [""];
		
		public function TFPExtention()
		{
		}
		
		/**
		 * 拡張子からファイルタイプを判別する。各種タイプの文字列はTFPAssetTypeクラスを参照。
		 * @param	extension
		 * @return
		 */
		public function getTypeByExtension(extension:String):String
		{
			if (!extension) return TFPAssetType.BYTEARRAY;
			var ext:String = extension.toLowerCase();
			if (ext == tfp) return TFPAssetType.TFP;
			
			if (image.indexOf(ext) != -1) return TFPAssetType.IMAGE;
			if (sound.indexOf(ext) != -1) return TFPAssetType.SOUND;
			if (text.indexOf(ext) != -1) return TFPAssetType.TEXT;
			if (xml.indexOf(ext) != -1) return TFPAssetType.XML;
			if (video.indexOf(ext) != -1) return TFPAssetType.VIDEO;
			if (swf.indexOf(ext) != -1) return TFPAssetType.SWF;
			return  TFPAssetType.BYTEARRAY;
		}
		
		/**
		 * ファイル名からファイルタイプを判別する。各種タイプの文字列はTFPAssetTypeクラスを参照。
		 * @param	name
		 */
		public function getTypeByFileName(name:String):String 
		{
			return getTypeByExtension(name.split(".").pop());
		}
		
	}

}