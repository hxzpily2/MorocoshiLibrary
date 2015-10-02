package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColladaMaterialNode extends ColladaNode
	{
		public var effectID:String = null;
		
		public function ColladaMaterialNode() 
		{
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
			
			effectID = XMLUtil.getAttrString(xml.instance_effect[0], "url", "");
		}
		
	}

}