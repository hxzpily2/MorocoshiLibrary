package net.morocoshi.common.layout 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class Table extends Sprite 
	{
		public var id:String;
		private var tableChildren:Vector.<Table>
		
		public function Table() 
		{
			super();
			tableChildren = new Vector.<Table>;
		}
		
		public function getTableByID(id:String):Table
		{
			var n:int = tableChildren.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:Table = tableChildren[i];
				if (item.id == id)
				{
					return item;
				}
				var child:Table = item.getTableByID(id);
				if (child)
				{
					return child;
				}
			}
			return null;
		}
		
		public function create(id:String, ratios:Array, ids:Array, direction:String):void
		{
			//var target:Table = item.getTableByID(id);
			//target.separate();
		}
		
		public function separate(ratios:Array, ids:Array, direction:String):void
		{
			
		}
		
	}

}