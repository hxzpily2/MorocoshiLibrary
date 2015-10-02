package net.morocoshi.common.loaders.tfp 
{
	/**
	 * TFPフォルダデータ。フォルダ内にあるTFPファイルとTFPサブフォルダのリストを持つ。
	 * 
	 * @author tencho
	 */
	public class TFPFolder extends TFPFile
	{
		public var folders:Vector.<TFPFolder>;
		public var files:Vector.<TFPFile>;
		
		public function TFPFolder(name:String = "") 
		{
			super(name, null, TFPAssetType.FOLDER);
			folders = new Vector.<TFPFolder>;
			files = new Vector.<TFPFile>;
		}
		
		public function getFolder(name:String):TFPFolder
		{
			for each (var f:TFPFolder in folders) 
			{
				if (f.name == name) return f;
			}
			return null;
		}
		
		public function getFile(name:String):TFPFile
		{
			for each (var f:TFPFile in files) 
			{
				if (f.name == name) return f;
			}
			return null;
		}
	}

}