package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaNode 
	{
		public var name:String;
		public var id:String;
		
		public function ColladaNode() 
		{
			
		}
		
		public function parse(xml:XML, collector:ColladaCollector):void
		{
			name = XMLUtil.getAttrString(xml, "name", "");
			id = XMLUtil.getAttrString(xml, "id", "");
		}
		
	}

}