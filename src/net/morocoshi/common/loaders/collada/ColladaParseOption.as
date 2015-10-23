package net.morocoshi.common.loaders.collada 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaParseOption 
	{
		public var exportPosition:Boolean = true;
		public var exportUV:Boolean = true;
		public var exportNormal:Boolean = true;
		public var exportTangent4:Boolean = true;
		public var exportVertexColor:Boolean = true;
		public var exportCamera:Boolean = true;
		public var exportLight:Boolean = true;
		public var exportModel:Boolean = false;
		public var exportAnimation:Boolean = false;
		public var removeEmptyObject:Boolean = false;
		/**ウェイトの数を最大4つにする*/
		public var halfWeight:Boolean = false;
		
		public function ColladaParseOption() 
		{
		}
		
	}

}