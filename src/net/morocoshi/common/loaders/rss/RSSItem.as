package net.morocoshi.common.loaders.rss {
	/**
	 * ...
	 * @author tencho
	 */
	public class RSSItem 
	{
		public var pubDate:String;
		public var guid:String;
		public var title:String;
		public var author:String;
		public var link:String;
		public var date:Date;
		/**ソート用*/
		public var time:Number;
		public var description:String;
		
		public function RSSItem() 
		{
			title = "";
			description = "";
			link = "";
			guid = "";
			author = "";
			date = new Date();
		}
		
		public function parseRSS1(xml:XML):void
		{
			default xml namespace = new Namespace("http://purl.org/rss/1.0/");
			var dc:Namespace = new Namespace("http://purl.org/dc/elements/1.1/");
			title = xml.title[0];
			link = xml.link[0];
			author = xml.dc::creator[0];
			pubDate = xml.dc::date[0];
			if (pubDate)
			{
				var times:Array = pubDate.split("-");
				date.fullYear = parseInt(times[0], 10);
				date.month = parseInt(times[1], 10) - 1;
				var date2:Array = times[2].split("T");
				date.date = parseInt(date2[0], 10);
				var hms:Array = date2[1].split("+")[0].split(":");
				date.hours = parseInt(hms[0], 10);
				date.minutes = parseInt(hms[1], 10);
				date.seconds = parseInt(hms[2], 10);
				time = date.getTime();
			}
		}
		
		public function parseRSS2(xml:XML):void
		{
			//Sat, 31 Aug 2013 02:12:15 +0000
			
			pubDate = xml.pubDate || xml.description;
			guid = xml.guid[0];
			if (pubDate)
			{
				var times:Array = pubDate.split(" ");
				date.fullYear = int(times[3]);
				date.month = toMonth(times[2]) - 1;
				date.date = int(times[1]);
				var hms:Array = times[4].split(":");
				date.hours = parseInt(hms[0], 10);
				date.minutes = parseInt(hms[1], 10);
				date.seconds = parseInt(hms[2], 10);
				time = date.getTime();
			}
			
			title = xml.title;
			link = xml.link;
			author = xml.author;
			description = xml.pubDate? unescape(xml.description) : "---";
		}
		
		public function parseAtom(xml:XML):void 
		{
			default xml namespace = new Namespace("http://www.w3.org/2005/Atom");
			guid = xml.id;
			title = xml.title;
			link = xml.link.hasOwnProperty("@rel")? xml.link.(@rel=="alternate").@href : xml.link.@href;
			description = xml.content;
			author = xml.author.name;
			//2014-10-16T07:40:01.000Z
			pubDate = xml.published;
			if (pubDate)
			{
				var times:Array = pubDate.split("T");
				var dates:Array = times[0].split("-");
				var hms:Array = times[1].split(".")[0].split(":");
				date.fullYear = parseInt(dates[0], 10);
				date.month = parseInt(dates[1], 10) - 1;
				date.date = parseInt(dates[2], 10);
				date.hours = parseInt(hms[0], 10);
				date.minutes = parseInt(hms[1], 10);
				date.seconds = parseInt(hms[2], 10);
				time = date.getTime();
			}
		}
		
		private function toMonth(text:String):int 
		{
			switch(text.toLowerCase())
			{
				case "jan": return 1;
				case "feb": return 2;
				case "mar": return 3;
				case "apr": return 4;
				case "may": return 5;
				case "jun": return 6;
				case "jul": return 7;
				case "aug": return 8;
				case "sep": return 9;
				case "oct": return 10;
				case "nov": return 11;
				case "dec": return 12;
			}
			return 0;
		}
		
		private function toDay(text:String):int 
		{
			switch(text.toLowerCase())
			{
				case "sun": return 6;
				case "sat": return 5;
				case "fri": return 4;
				case "tue": return 3;
				case "wed": return 2;
				case "thu": return 1;
				case "mon": return 0;
			}
			return -1;
		}
		
	}

}