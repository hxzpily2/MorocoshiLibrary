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
		/**補完タイプ。まだLINEARにしか対応してない*/
		public var tangents:Array;
		/**まだmatrixにしか対応してない*/
		public var type:String;
		
		public function ColladaAnimationData() 
		{
		}
		
	}

}