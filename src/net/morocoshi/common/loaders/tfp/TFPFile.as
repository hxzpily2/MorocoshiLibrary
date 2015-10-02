package net.morocoshi.common.loaders.tfp 
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * TFPファイルデータ
	 * 
	 * @author tencho
	 */
	public class TFPFile 
	{
		/**アセットのファイル名（パスは含まない）*/
		public var name:String;
		/**アセットデータ*/
		public var asset:*;
		/**アセットのフルパス（パスとファイル名）*/
		public var path:String;
		/**アセットデータの各種インスタンス化に失敗したか*/
		public var error:Boolean = false;
		/**アセットのByteArrayデータ*/
		public var byteArray:ByteArray;
		/**アセットの種類*/
		public var type:String;
		public var local:String;
		
		/**
		 * TFP用ファイルデータ
		 * @param	name	ファイル名
		 * @param	byteArray	ファイルのByteArrayデータ
		 * @param	type	ファイルタイプ。TFPAssetTypeクラスで指定できる。省略でByteArrayタイプに。
		 */
		public function TFPFile(name:String = "", byteArray:ByteArray = null, type:String = "")
		{
			this.name = name;
			this.byteArray = byteArray;
			this.type = type || TFPAssetType.BYTEARRAY;
		}
		
		/**
		 * assetとbyteArrayのデータの中身を完全に破棄する。他で参照している場合は注意
		 */
		public function dispose():void 
		{
			if (byteArray) byteArray.clear();
			if (asset is ByteArray) ByteArray(asset).clear();
			if (asset is BitmapData) BitmapData(asset).dispose();
			byteArray = null;
			asset = null;
		}
		
	}

}