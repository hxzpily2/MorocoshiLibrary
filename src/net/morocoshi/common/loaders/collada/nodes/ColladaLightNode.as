package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaLightNode extends ColladaNode
	{
		
		public function ColladaLightNode() 
		{
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
		}
		
	}

}