package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaImageNode extends ColladaNode
	{
		public var path:String = "";
		
		public function ColladaImageNode() 
		{
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
			
			path = XMLUtil.getNodeString(xml.init_from[0], "");
		}
		
	}

}