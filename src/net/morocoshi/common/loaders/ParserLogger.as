package net.morocoshi.common.loaders 
{
	/**
	 * まだ使ってない
	 * 
	 * @author tencho
	 */
	public class ParserLogger 
	{
		private var _logData:Object;
		
		public function ParserLogger() 
		{
			_logData = { };
		}
		
		public function clear():void
		{
			_logData = { };
		}
		
		public function log(id:String, ...args):void
		{
			var list:Array = _logData[id] || (_logData[id] = []);
			list.push(args.join(","));
		}
		
		public function getLogList(id:String):Array 
		{
			return _logData[id];
		}
		
	}

}