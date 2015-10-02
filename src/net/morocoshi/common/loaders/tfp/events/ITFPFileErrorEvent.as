package net.morocoshi.common.loaders.tfp.events 
{
	import flash.net.URLLoader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public interface ITFPFileErrorEvent 
	{
		/**読み込みに使用したURLLoader*/
		function get loader():URLLoader;
		function set loader(value:URLLoader):void;
		
		/**ロード操作中に、既にロード済みのデータのバイト数を示します。*/
		function get bytesLoaded():uint;
		function set bytesLoaded(value:uint):void;
		
		/**ダウンロードデータの合計バイト数を示します。Content-Length ヘッダーがない場合、bytesTotal の値が不確定になります。*/
		function get bytesTotal():uint;
		function set bytesTotal(value:uint):void;
		
		/**読み込み時の生URL（TFP対象のファイルを読み込んだ場合はtfpファイルのパスになります。ハッシュがついている場合があります）*/
		function get actualUrl():String;
		function set actualUrl(value:String):void;
		
		/**HTTPステータスコード*/
		function get status():int;
		function set status(value:int):void;
		
		/**リロードに必要なURLのリスト（image/test.jpgを読もうとしてimage.tfpが読まれた時にエラーが出た場合、image.tfpではなく元のimage/test.jpgがリストに加わります。ハッシュはついていません。）*/
		function get reloadPathList():Vector.<String>;
		function set reloadPathList(value:Vector.<String>):void;
	}

}