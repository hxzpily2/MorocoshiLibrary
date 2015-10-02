package net.morocoshi.common.loaders.fbx 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class FBXParseOption 
	{
		public var autoMaterialRepeat:Boolean = true;
		public var repeatMargin:Number = 0.001;
		public var simpleTangent4:Boolean = false;
		public var addAnimation:Boolean = true;
		
		public var deleteTangent4:Boolean = false;
		public var deleteUV:Boolean = false;
		public var deleteNormal:Boolean = false;
		public var deleteVertexColor:Boolean = false;
		
		public function FBXParseOption() 
		{
		}
		
	}

}