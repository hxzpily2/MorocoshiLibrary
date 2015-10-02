package net.morocoshi.common.loaders.fbx 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXGlobal
	{
		
		public var ambientColor:uint = 0x000000;
		public var startTime:int = 0;
		public var endTime:int = 0;
		
		public function FBXGlobal(node:FBXNode = null)
		{
			if (node) parse(node);
		}
		
		public function parse(node:FBXNode):void 
		{
			if (node.Properties70)
			{
				var prop:Object = FBXParser.parseProperties(node.Properties70);
				ambientColor = prop.AmbientColor;
				startTime = prop.TimeSpanStart / FBXScene.MSEC_TO_FBX;
				endTime = prop.TimeSpanStop / FBXScene.MSEC_TO_FBX;
			}
		}
		
	}

}