package net.morocoshi.common.loaders.rss {
	/**
	 * ...
	 * @author tencho
	 */
	public class RSSFeed 
	{
		public var title:String;
		public var author:String;
		public var link:String;
		public var links:Object;
		public var items:Vector.<RSSItem>;
		
		static public const AUTHOR_UNKNOWN:String = "???";
		static public const NAMESPACE_DC:String = "http://purl.org/dc/elements/1.1/";
		static public const NAMESPACE_RSS1:String = "http://purl.org/rss/1.0/";
		static public const NAMESPACE_ATOM:String = "http://www.w3.org/2005/Atom";
		
		public function RSSFeed(xml:XML = null) 
		{
			title = "---";
			author = AUTHOR_UNKNOWN;
			items = new Vector.<RSSItem>;
			links = { };
			
			if (xml)
			{
				parse(xml);
			}
		}
		
		public function parse(xml:XML):void 
		{
			items.length = 0;
			
			var local:String = xml.localName().toLowerCase();
			switch(local)
			{
				case "rdf":	parseRss1(xml); break;
				case "feed": parseAtom(xml); break;
				default: parseRss2(xml);
			}
		}
		
		private function parseAtom(xml:XML):void 
		{
			default xml namespace = new Namespace(NAMESPACE_ATOM);
			
			title = xml.title;
			try
			{
				link = xml.link.hasOwnProperty("@rel")? xml.link.(@rel=="alternate").@href : xml.link.@href;
			}
			catch (e:Error)
			{
				link = "";
			}
			
			var node:XML;
			for each(node in xml.link)
			{
				if (node.hasOwnProperty("@rel") == false) continue;
				links[node.@rel] = node.@href;
			}
			
			author = xml.author.name;;
			if (!author && xml..entry.length() >= 1)
			{
				author = xml..entry[0].author.name;
			}
			author = author || AUTHOR_UNKNOWN;
			
			for each(node in xml..entry)
			{
				var item:RSSItem = new RSSItem();
				item.parseAtom(node);
				items.push(item);
			}
		}
		
		public function getLastUpdate():Number 
		{
			if (items.length == 0) return 0;
			
			var latest:Number = 0;
			for each(var item:RSSItem in items)
			{
				var date:Number = item.date.getTime();
				if (latest < date) latest = date;
			}
			return latest;
		}
		
		public function getGUIDs():Array 
		{
			var result:Array = [];
			for each(var item:RSSItem in items)
			{
				result.push(item.guid);
			}
			return result;
		}
		
		private function parseRss2(xml:XML):void
		{
			title = xml.channel.title;
			link = xml.channel.link[0];
			links = { };
			
			var dc:Namespace = new Namespace(NAMESPACE_DC);
			author = xml.channel.managingEditor || xml.channel.dc::creator;
			if (!author && xml.channel.item.length() >= 1)
			{
				author = xml.channel.item[0].dc::creator;
			}
			author = author || AUTHOR_UNKNOWN;
			
			for each(var node:XML in xml..item)
			{
				var item:RSSItem = new RSSItem();
				item.parseRSS2(node);
				items.push(item);
			}
		}
		
		private function parseRss1(xml:XML):void 
		{
			default xml namespace = new Namespace(NAMESPACE_RSS1);
			title = xml.channel.title;
			links = { };
			
			var dc:Namespace = new Namespace(NAMESPACE_DC);
			author = xml.channel.dc::creator;
			if (!author && xml.item.length() >= 1)
			{
				author = xml.item[0].dc::creator;
			}
			author = author || AUTHOR_UNKNOWN;
			
			for each(var node:XML in xml.item)
			{
				var item:RSSItem = new RSSItem();
				item.parseRSS1(node);
				items.push(item);
			}
		}
		
	}

}