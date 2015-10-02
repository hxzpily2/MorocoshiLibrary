package net.morocoshi.air.application 
{
	import flash.desktop.NativeApplication;
	
	/**
	 * アプリケーション記述ファイル(application.xml)の情報をまとめるクラス
	 * 
	 * @author tencho
	 */
	public class ApplicationData 
	{
		public var name:String;
		public var version:String;
		public var description:String;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function ApplicationData() 
		{
			parse(NativeApplication.nativeApplication.applicationDescriptor);
		}
		
		/**
		 * application.xmlを渡して必要な情報をまとめる
		 * @param	xml
		 */
		public function parse(xml:XML):void 
		{
			var ns:Namespace = xml.namespace();
			name = xml.ns::name;
			version = xml.ns::versionNumber;
			description = xml.ns::description;
		}
		
		/**
		 * タイトル＋バージョンの文字列を取得
		 * @return
		 */
		public function getTitleAndVersion():String 
		{
			return name + " " + version;
		}
		
	}

}