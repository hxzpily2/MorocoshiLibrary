package net.morocoshi.components.minimal.layout 
{
	import com.bit101.components.Component;
	import flash.geom.Point;
	
	/**
	 * TableBoxで使うセル情報
	 * 
	 * @author tencho
	 */
	public class TableCell 
	{
		/**セル内にあるコンポーネント*/
		public var component:Component;
		/**columnインデックス位置*/
		public var x:int;
		/**rowインデックス位置*/
		public var y:int;
		/**オフセット位置*/
		public var offset:Point;
		/**横揃え*/
		public var alignX:String;
		/**縦揃え*/
		public var alignY:String;
		
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	component
		 * @param	alignX
		 * @param	alignY
		 */
		public function TableCell(x:int, y:int, component:Component, alignX:String, alignY:String)
		{
			this.x = x;
			this.y = y;
			offset = new Point();
			this.component = component;
			this.alignX = alignX;
			this.alignY = alignY;
		}
		
		public function removeChild():void 
		{
			if (component && component.parent)
			{
				component.parent.removeChild(component);
			}
			component = null;
		}
		
	}

}