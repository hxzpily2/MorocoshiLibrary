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
		/**<node>にidかnameどちらかの属性がある*/
		public var existID:Boolean;
		public var name:String;
		public var id:String;
		public var animation:Object;
		
		public function ColladaNode() 
		{
			
		}
		
		public function parse(xml:XML, collector:ColladaCollector):void
		{
			existID = xml.hasOwnProperty("@name") || xml.hasOwnProperty("@id");
			name = XMLUtil.getAttrString(xml, "name", "");
			id = XMLUtil.getAttrString(xml, "id", "");
		}
		
		public function addAnimationData(data:ColladaAnimationData):void
		{
			if (animation == null) animation = { };
			animation[data.type] = data;
		}
		
	}

}