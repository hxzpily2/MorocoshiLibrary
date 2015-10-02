package net.morocoshi.components.minimal.grid 
{
	import com.bit101.components.Component;
	import flash.events.Event;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class DataGridEvent extends Event 
	{
		public static const CHANGE:String = "datagrid_change";
		public var item:DataGridItem;
		public var cell:Component;
		
		public function DataGridEvent(type:String, item:DataGridItem = null, cell:Component = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			this.item = item;
			this.cell = cell;
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new DataGridEvent(type, item, cell, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DataGridEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}