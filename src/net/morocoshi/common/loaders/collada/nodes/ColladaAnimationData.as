package net.morocoshi.common.loaders.collada.nodes 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColladaAnimationData 
	{
		/**キーフレーム位置（秒単位？）*/
		public var times:Array;
		/**キーフレーム値*/
		public var values:Array;
		/**ベジェ用ハンドルデータ*/
		public var inTangent:Array;
		/**ベジェ用ハンドルデータ*/
		public var outTangent:Array;
		/**補完タイプ。まだLINEARにしか対応してない*/
		public var tangents:Array;
		/**matrixとか*/
		public var type:String;
		
		public function ColladaAnimationData() 
		{
		}
		
	}

}