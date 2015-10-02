package net.morocoshi.common.loaders.tfp 
{
	/**
	 * 各ファイルがTFP化されるかどうかの解析結果
	 * 
	 * @author tencho
	 */
	public class TFPAnalysisResult
	{
		/**TFPファイルの情報（TFPファイルパスをキーにもつ）*/
		public var tfpRequest:Object;
		/**TFP化されるファイルのリスト*/
		public var packedFiles:Vector.<String>;
		/**TFP化されないファイルのリスト*/
		public var rawFiles:Vector.<String>;
		
		public function TFPAnalysisResult() 
		{
			tfpRequest = { };
			packedFiles = new Vector.<String>;
			rawFiles = new Vector.<String>;
		}
		
		/**
		 * 結果を文字列で取得
		 * @return
		 */
		public function getStats():String 
		{
			var result:String = "";
			var requests:Array = [];
			for (var key:String in tfpRequest)
			{
				requests.push(key + " (" + tfpRequest[key].length + ")");
			}
			result += "-----------------------------\n";
			result += "TFPで読み込まれるファイル数: " + packedFiles.length + "\n";
			if (packedFiles.length > 0)
			{
				result += packedFiles.join("\n") + "\n";
			}
			result += "-----------------------------\n";
			result += "そのまま読み込まれるファイル数: " + rawFiles.length + "\n";
			if (rawFiles.length > 0)
			{
				result += rawFiles.join("\n") + "\n";
			}
			result += "-----------------------------\n";
			result += "TFPファイル数: " + requests.length + "\n";
			if (requests.length > 0)
			{
				result += requests.join("\n") + "\n";
			}
			result += "-----------------------------\n";
			return result;
		}
		
	}

}