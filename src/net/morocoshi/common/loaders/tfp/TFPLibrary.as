package net.morocoshi.common.loaders.tfp 
{
	
	/**
	 * TFPデータをAMF化したり、復元したりするためのデータ。rootにTFPフォルダを1つ持つ。
	 * TFPParserでパースした際に全ファイル、全フォルダへの参照が配列に格納される。
	 * 
	 * @author tencho
	 */
	public class TFPLibrary 
	{
		/**AMFファイル判別用ID（変更禁止）*/
		public const CLASS_NAME:String = "net.morocoshi.core.loader.tfp.TFPLibrary";
		/**ルートフォルダ*/
		public var root:TFPFolder;
		/**全ファイルデータリスト*/
		public var files:Vector.<TFPFile>;
		/**全フォルダデータリスト*/
		public var folders:Vector.<TFPFolder>;
		
		public function TFPLibrary() 
		{
			root = new TFPFolder();
			files = new Vector.<TFPFile>;
			folders = new Vector.<TFPFolder>;
		}
	}

}