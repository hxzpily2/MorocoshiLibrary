package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaAssetNode extends ColladaNode
	{
		//座標軸[Z_UP]
		public var upAxis:String;
		public var unitScale:Number;
		public var author:String;
		
		public function ColladaAssetNode() 
		{
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
			
			upAxis = XMLUtil.getNodeString(xml.up_axis[0], "");
			collector.unitScale = unitScale = XMLUtil.getAttrNumber(xml.unit[0], "meter", 0.01) / 0.01;
			var contributor:XML = xml.contributor[0];
			if (contributor)
			{
				author = XMLUtil.getNodeString(contributor.author[0], "");
			}
		}
		
	}

}